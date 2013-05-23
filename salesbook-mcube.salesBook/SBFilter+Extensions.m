//
//  SBFilter+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 25.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBFilter+Extensions.h"
#import "SBFilterLevel+Extensions.h"

#import "SBCustomField+Extensions.h"

#import "NSManagedObject+CustomFields.h"
#import "SAGFilterManager.h"

@implementation SBFilter (Extensions)

+ (NSArray *)availableFiltersForEntity:(NSString *)targetEntity
{
    return [SBFilter MR_findAllSortedBy:@"name" ascending:@YES withPredicate:[NSPredicate predicateWithFormat:@"targetEntity == %@", targetEntity]];
}

+ (SBFilter *)filterWithTargetEntity:(NSString *)targetEntity andName:(NSString *)name
{
    if (!name)
    {
        name = [NSDate nowAsLocalizedString];
    }
    
    if (!targetEntity || [NSEntityDescription entityForName:targetEntity inManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]] == nil)
    {
        DDLogError(@"TargetEntity invalid or not set!");
        return nil;
    }
    
    SBFilter *filter = [SBFilter MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name == %@ AND targetEntity == %@", name, targetEntity]];
    
    if (!filter)
    {
        filter = [SBFilter MR_createEntity];
        filter.name = name;
        filter.targetEntity = targetEntity;
        
        filter.uniqueID = [NSString generateUniqueID]; //generateUniqueID
        filter.creationDate = [NSDate date]; //Anlage Datum aufheben
    }
    
    return filter;
}

#pragma mark - Kontrolle von aussen

- (void)removeFilter
{
    [self MR_deleteEntity];
    
    //TODO: Den Filter auf dem Server löschen! Dafür muss das XML allerdings noch lernen wie man mit NSArray und NSDictionarys umgeht!
    //[self prepareForDelete];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationFilterEdited object:self];
    
    [self.managedObjectContext MR_saveOnlySelfAndWait];
}

- (void)refreshFilter
{
    [self performSelector:@selector(clearCache) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    [self executeAllFilterLevels];
}

- (void)saveFilter
{
    //[self saveForBatchTransfer]; //TODO: Den Filter auf dem Server speichern! Dafür muss das XML allerdings noch lernen wie man mit NSArray und NSDictionarys umgeht!
    [self.managedObjectContext MR_saveOnlySelfAndWait];
}

- (bool)executeAllFilterLevels
{
    [self.levels enumerateObjectsUsingBlock:^(SBFilterLevel *filterLevel, NSUInteger idx, BOOL *stop) {
        
        [self performSelector:@selector(executeFilter:) onThread:[NSThread currentThread] withObject:filterLevel waitUntilDone:YES];
    }];
    
    return YES;
}

- (void)clearCache
{
    self.cache = nil;
    
    self.active = [NSNumber numberWithBool:NO];
    
    [self.levels enumerateObjectsUsingBlock:^(SBFilterLevel *level, NSUInteger idx, BOOL *stop) {
        
        level.cache = nil;
    }];
    
    DDLogInfo(@"Cache cleared!");
}

#pragma mark - Auswahl einschränken

- (bool)setObjectToFilter:(NSManagedObject *)managedObject
{
    return [self setObjectsToFilter:[NSSet setWithObject:managedObject]];
}

- (bool)setObjectsToFilter:(NSSet *)managedObjects
{
    [self clearCache]; //Cache löschen
    
    NSDate *startDate = [NSDate date];
    
    if (managedObjects.count == 0)
    {
        DDLogInfo(@"Nothing to do!");
        return YES;
    }
    
    NSManagedObject *aObject = [[managedObjects allObjects] objectAtIndex:0]; //Wir nehmen einfach irgendein Object...

    if (![aObject isKindOfClass:[NSManagedObject class]])
    {
        DDLogError(@"Sorry: %@ is not a NSManagedObject!", [[aObject class] description]);
        return NO;
    }
    
    if ([aObject.entity.name isEqualToString:self.targetEntity])
    {
        NSMutableArray *objectURIs = [NSMutableArray new];
        
        __block NSArray *allObjects = managedObjects.allObjects;
        
        [allObjects enumerateObjectsUsingBlock:^(NSManagedObject *object, NSUInteger idx, BOOL *stop) {
            
            [objectURIs addObject:[[object objectID] URIRepresentation]];
        }];
        
        self.cache = [NSKeyedArchiver archivedDataWithRootObject:objectURIs];

        DDLogInfo(@"********************************************************************");
        DDLogInfo(@"*** Task:   SetObjectsToFilter");
        DDLogInfo(@"*** Found:  %i", managedObjects.count);
        DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
        DDLogInfo(@"********************************************************************");
        
        return [self executeAllFilterLevels]; //Alle filter aktivieren!
    }
    
    NSString *relationShipName = [self findRelationShipBetweeen:self.targetEntity andEntity:aObject.entity.name]; //Und schauen ob es eine Verbindung gibt...
    
    if (!relationShipName)
    {
        DDLogError(@"Sorry can´t find no relationShip between %@ and %@!", aObject.entity.name, self.targetEntity);
        return NO;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K in %@", relationShipName, managedObjects];

    NSFetchRequest *fetchRequest = [self createFetchRequestWithEntity:self.targetEntity andResultType:NSManagedObjectIDResultType andPredicate:predicate];
    
    NSArray *result = [self executeFetchRequest:fetchRequest];
    
    if (!result)
    {
        DDLogError(@"No results found!");
        self.cache = nil;
        
        return NO;
    }
    
    self.cache = [self cacheFromFetchResult:result]; //Cache wegschreiben
    
    DDLogInfo(@"********************************************************************");
    DDLogInfo(@"*** Task:   SetObjectsToFilter");
    DDLogInfo(@"*** Found:  %i", result.count);
    DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
    DDLogInfo(@"********************************************************************");
    
    return [self executeAllFilterLevels]; //Alle filter aktivieren!
}

- (NSArray *)getResult
{
    return [self getResultWithEntity:nil];
}

- (NSArray *)getResultWithEntity:(NSString *)entityOrNil
{
    NSDate *startDate = [NSDate date];
    
    if (!self.active.boolValue) //Sicherstellen das alle Filter aktiv sind!
    {
        [self performSelector:@selector(executeAllFilterLevels) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    }
    
    NSArray *managedObjects = [self managedObjectsFromCache:[[[self levels] lastObject] cache]];
    
    if (self.levels.count == 0)
    {
        managedObjects = [self managedObjectsFromCache:self.cache];
    }
    
    if (managedObjects.count == 0) managedObjects = [NSArray array];//Damit die Predicates nicht um die Ohren fliegen!
        
    if (entityOrNil == nil || [entityOrNil isEqualToString:self.targetEntity])
    {
        DDLogInfo(@"********************************************************************");
        DDLogInfo(@"*** Task:   getResultWithEntity -> %@", self.targetEntity);
        DDLogInfo(@"*** Found:  %i", managedObjects.count);
        DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
        DDLogInfo(@"********************************************************************");
        
        return managedObjects;
    }
    
    NSString *relationShipName = [self findRelationShipBetweeen:entityOrNil andEntity:self.targetEntity]; //Und schauen ob es eine Verbindung gibt...
    
    if (!relationShipName)
    {
        DDLogError(@"Sorry can´t find no relationShip between %@ and %@!", self.targetEntity, entityOrNil);
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY %K in %@", relationShipName, managedObjects];
    
    NSFetchRequest *fetchRequest = [self createFetchRequestWithEntity:entityOrNil andResultType:NSManagedObjectResultType andPredicate:predicate];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSArray *result = [self executeFetchRequest:fetchRequest];
    
    DDLogInfo(@"********************************************************************");
    DDLogInfo(@"*** Task:   getResultWithEntity -> %@", entityOrNil);
    DDLogInfo(@"*** Found:  %i", result.count);
    DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
    DDLogInfo(@"********************************************************************");
    
    if (result.count == 0) result = [NSArray array]; //Damit die Predicates nicht um die Ohren fliegen!

    return result;
}

#pragma mark - addFilter

- (bool)addFilterLevelWithValue:(id)value andKey:(NSString *)key
{
    return [self addFilterLevelWithValues:[NSArray arrayWithObject:value] andKey:key];
}

- (bool)addFilterLevelWithValues:(NSArray *)values andKey:(NSString *)key
{
    SBFilterLevel *filterLevel = [self filterlevelforKey:key];
    
    if (!filterLevel)
    {
        NSString *entityToFetch;
        NSString *relationShipName;
        
        if ([self targetEntityContainsKey:key])
        {
            entityToFetch = self.targetEntity;
        }
        else if ([self targetEntityHasAttributes])
        {
            entityToFetch = @"SBAttribute";
            
            relationShipName = [self findRelationShipBetweeen:entityToFetch andEntity:self.targetEntity];
        }
        else
        {
            DDLogError(@"Key: %@ not found in Entity: %@", key, self.targetEntity);
            return NO;
        }
        
        filterLevel = [SBFilterLevel MR_createEntity];
        
        filterLevel.targetEntity = entityToFetch;
        filterLevel.theKey = key;
        filterLevel.theValue = values;
        filterLevel.relationshipKey = relationShipName;
        filterLevel.level = [NSNumber numberWithInt:self.levels.count];
        
        [filterLevel setFilter:self];
    }
    else
    {
        if (![values isEqualToArray:filterLevel.theValue])
        {
            filterLevel.theValue = values;
            filterLevel.type = nil;
            filterLevel.cache = nil;
            
            [self reorderFilterLevelInvalidateFromIndex:filterLevel.level.unsignedIntValue];
        }
    }
    
    if (filterLevel.cache == nil)
    {
        return [self executeFilter:filterLevel];
    }
    
    DDLogInfo(@"********************************************************************");
    DDLogInfo(@"*** Task:   Skip execution of filter: %@ -> %@", filterLevel.theKey, [filterLevel.theLabels componentsJoinedByString:@","]);
    DDLogInfo(@"*** Reason: Cached result available");
    DDLogInfo(@"********************************************************************");
    
    return NO;
}

- (void)removeFilterAtLevel:(int)level
{
    if (self.levels.count < level)
    {
        DDLogInfo(@"********************************************************************");
        DDLogInfo(@"*** Task:   Can not remove filter at level: %u", level);
        DDLogInfo(@"*** Reason: Level does not exist!");
        DDLogInfo(@"********************************************************************");
        
        return;
    }
    
    SBFilterLevel *filterToRemove = [self.levels objectAtIndex:level];
    
    if (!filterToRemove)
    {
        return;
    }
    
    DDLogInfo(@"********************************************************************");
    DDLogInfo(@"*** Task:   Removing filter: %@ -> %@", filterToRemove.theKey, [filterToRemove.theLabels componentsJoinedByString:@","]);
    DDLogInfo(@"********************************************************************");
    
    NSUInteger oldIndex = filterToRemove.level.unsignedIntValue;
    
    [self removeLevelsObject:filterToRemove];
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
    
    [self reorderFilterLevelInvalidateFromIndex:oldIndex];
}

- (void)removeLastFilterLevel
{
    SBFilterLevel *filterToRemove = self.levels.lastObject;
    
    [self removeFilterAtLevel:filterToRemove.level.intValue];
}

#pragma mark - management

- (NSArray *)distinctValuesForKey:(NSString *)key
{
    if (!self.active.boolValue) //Sicherstellen das alle Filter aktiv sind!
    {
        [self performSelector:@selector(executeAllFilterLevels) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
    }
    
    SBCustomField *customfield = [SBCustomField getCustomFieldWithTargetEntity:self.targetEntity andKey:key];
    
    NSString *language = @"";
    
    if (customfield.customFieldType.intValue == SAGCustomFieldTypeText) //TODO:  && customfield.isMultiLanguage.boolValue
    {
        language = [[SAGSettingsManager sharedManager] itemDisplayLanguage];
    }
    
    NSDate *startDate = [NSDate date];
    
    NSString *entityToFetch;
    NSString *propertyToFetch;
    NSString *relationShipName;
    
    NSArray *objectsToFilter;
    
    SBFilterLevel *ownFilterLevel = [self filterlevelforKey:key];
    
    if (ownFilterLevel) //Es werden immer alle Distinct Values über dem eigenen Filterlevel ausgegeben!
    {
        if (ownFilterLevel.level.intValue == 0)
        {
            objectsToFilter = [self managedObjectsFromCache:self.cache];
        }
        else
        {
            objectsToFilter = [self managedObjectsFromCache:[[self.levels objectAtIndex:ownFilterLevel.level.intValue - 1] cache]];
        }
    }
    else
    {
        objectsToFilter = [self managedObjectsFromCache:[self.levels.lastObject cache]];
    }
    
    if (self.levels.count == 0)
    {
        objectsToFilter = [self managedObjectsFromCache:self.cache];
    }
    
    NSPredicate *predicate;
    
    if ([self targetEntityContainsKey:key])
    {
        entityToFetch = self.targetEntity;
        propertyToFetch = key;
        predicate = nil;
    }
    else if ([self targetEntityHasAttributes])
    {
        entityToFetch = @"SBAttribute";
        propertyToFetch = @"theValue";
        
        relationShipName = [self findRelationShipBetweeen:entityToFetch andEntity:self.targetEntity];
    
        if (objectsToFilter.count != 0)
        {
            predicate = [NSPredicate predicateWithFormat:@"theKey == %@ AND language == %@", key, language];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"%K != nil AND theKey == %@ AND language == %@", relationShipName, key, language];
        }
    }
    else
    {
        DDLogError(@"Key: %@ not found in Entity: %@", key, self.targetEntity);
        return nil;
    }

    if (objectsToFilter != 0) //Zwei abfragen ausführen
    {
        if ([entityToFetch isEqualToString:@"SBAttribute"])
        {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"%K in %@", relationShipName, objectsToFilter], predicate, nil]];
        }
        else
        {
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"self in %@", objectsToFilter], predicate, nil]];
        }
    }
    
    NSFetchRequest *fetchRequest = [self createFetchRequestWithEntity:entityToFetch propertyToFetch:propertyToFetch andPredicate:predicate];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:propertyToFetch ascending:YES]]]; //Ergebnis sortieren....
    
    NSArray *result = [self executeFetchRequest:fetchRequest];
    
    result = [self removeDictionaryOverheadFromResult:result];
    
    DDLogInfo(@"********************************************************************");
    DDLogInfo(@"*** Task:   distinctValuesForKey -> %@", key);
    DDLogInfo(@"*** Found:  %i", result.count);
    DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
    DDLogInfo(@"********************************************************************");
    
    NSMutableArray *newResult = [NSMutableArray new];
    
    for (id object in result)
    {
        if (customfield.customFieldType.intValue == SAGCustomFieldTypeSelect)
        {
            SBSelectionOption *selectionOption = [customfield selectionOptionWithOptionCode:object];
            
            [newResult addObject:@{@"value": object, @"label": [selectionOption denotationWithLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]]}];
        }
        else
        {
            [newResult addObject:@{@"value": object, @"label": [SBCustomField stringValueWithObject:object]}];
        }
    }
    
    return newResult;
}

- (bool)executeFilter:(SBFilterLevel *)filter
{
    NSDate *startDate = [NSDate date];
    
    NSArray *objectsToFilter;
    
    if (filter.level.intValue == 0)
    {
        objectsToFilter = [self managedObjectsFromCache:self.cache];
    }
    else
    {
        objectsToFilter = [self managedObjectsFromCache:[[[self levels] objectAtIndex:filter.level.intValue - 1] cache]];
    }
    
    if (objectsToFilter.count > 0)
    {
        if (filter.theValues.count == 0)
        {
            DDLogError(@"Level with key %@ has no values! -> Remove level!", filter.theKey);
            
            [self removeFilterAtLevel:filter.level.intValue];
            return NO;
        }
        
        BOOL singleValue = (filter.theValues.count == 1);
        
        id value = [filter.theValues objectAtIndex:0];
        
        NSPredicate *predicate;
        
        if ([filter.targetEntity isEqualToString:self.targetEntity])
        {
            if (singleValue)
            {
                predicate = [NSPredicate predicateWithFormat:@"%K == %@", filter.theKey, value];
            }
            else
            {
                predicate = [NSPredicate predicateWithFormat:@"%K in %@", filter.theKey, filter.theValues];
            }
        }
        else
        {
            if (objectsToFilter.count != 0)
            {
                if (singleValue)
                {
                    predicate = [NSPredicate predicateWithFormat:@"theKey == %@ AND theValue == %@", filter.theKey, value];
                }
                else
                {
                    predicate = [NSPredicate predicateWithFormat:@"theKey == %@ AND theValue in %@", filter.theKey, filter.theValues];
                }
            }
            else
            {
                if (singleValue)
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K != nil AND theKey == %@ AND theValue == %@", filter.relationshipKey, filter.theKey, value];
                }
                else
                {
                    predicate = [NSPredicate predicateWithFormat:@"%K != nil AND theKey == %@ AND theValue in %@", filter.relationshipKey, filter.theKey, filter.theValues];
                }
            }
        }
        
        NSFetchRequest *fetchRequest;
        
        if ([filter.targetEntity isEqualToString:@"SBAttribute"])
        {
            if (objectsToFilter.count != 0) //Zwei abfragen ausführen
            {
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"%K in %@", filter.relationshipKey, objectsToFilter], predicate, nil]];
            }
            
            fetchRequest = [self createFetchRequestWithEntity:filter.targetEntity propertyToFetch:filter.relationshipKey andPredicate:predicate];
        }
        else
        {
            if (objectsToFilter.count != 0) //Zwei abfragen ausführen
            {
                predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"self in %@", objectsToFilter], predicate, nil]];
            }
            
            fetchRequest = [self createFetchRequestWithEntity:filter.targetEntity andResultType:NSManagedObjectIDResultType andPredicate:predicate];
        }
        
        NSArray *objectsMatchingKey = [self executeFetchRequest:fetchRequest];
        
        if (!objectsMatchingKey)
        {
            DDLogError(@"No results found!");
            return NO;
        }
        
        NSArray *result;
        
        if (![self.targetEntity isEqualToString:filter.targetEntity])
        {
            result = [self removeDictionaryOverheadFromResult:objectsMatchingKey];
        }
        else
        {
            result = objectsMatchingKey;
        }
        
        filter.cache = [self cacheFromFetchResult:result]; //Cache wegschreiben
        
        filter.type = [NSNumber numberWithInt:result.count]; //Anzahl der Ergebnisse
        
        DDLogInfo(@"********************************************************************");
        DDLogInfo(@"*** Task:   executeFetch: %@ -> %@", filter.theKey, [filter.theValues componentsJoinedByString:@","]);
        DDLogInfo(@"*** Found:  %i", result.count);
        DDLogInfo(@"*** Active: %d", self.active.boolValue);
        DDLogInfo(@"*** Time:   %@", [NSString stringAsDetailedTimeSinceDate:startDate]);
        DDLogInfo(@"********************************************************************");
    }
    else
    {
        filter.cache = nil;
        filter.type = @0;
        
        DDLogInfo(@"********************************************************************");
        DDLogInfo(@"*** Task:   Skip execution of filter: %@ -> %@", filter.theKey, [filter.theLabels componentsJoinedByString:@","]);
        DDLogInfo(@"*** Reason: No objects to filter!");
        DDLogInfo(@"********************************************************************");
    }
    
    if ([filter isEqual:self.levels.lastObject]) //Alle Filter aktiv!
    {
        self.active = [NSNumber numberWithBool:YES];
    }
    
    return YES;
}

- (NSArray *)availableKeys
{    
    return [SBCustomField getFilterableKeysForEntity:self.targetEntity];
}

#pragma mark - internal

- (void)moveFilterLevelAtIndex:(NSUInteger)sourceIndex toIndex:(NSUInteger)destination
{
    NSMutableOrderedSet *rearrangedLevels = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.levels];
    
    [rearrangedLevels moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:sourceIndex] toIndex:destination];
    
    [self setLevels:rearrangedLevels];
    
    [self reorderFilterLevelInvalidateFromIndex:destination];
}

- (SBFilterLevel *)filterlevelforKey:(NSString *)key
{
    return [SBFilterLevel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"theKey == %@ AND filter == %@", key, self]];
}

- (void)reorderFilterLevelInvalidateFromIndex:(NSUInteger)invalidate
{
    int idx = 0;
    
    for (SBFilterLevel *filterLevel in self.levels)
    {
        filterLevel.level = [NSNumber numberWithUnsignedInt:idx];
        
        //DDLogInfo(@"%@ -> %u", filterLevel.theKey, filterLevel.level.unsignedIntValue);
        
        if (filterLevel.level.unsignedIntValue != idx || idx >= invalidate)
        {
            //DDLogInfo(@"Renew: %u %@", filterLevel.level.unsignedIntValue, filterLevel.theKey);
            
            filterLevel.type = nil;
            filterLevel.cache = nil;
            
            [self executeFilter:filterLevel];
        }

        idx++;
    }
}

- (NSArray *)executeFetchRequest:(NSFetchRequest *)fetchRequest
{
    return [NSManagedObject MR_executeFetchRequest:fetchRequest];
}

- (NSFetchRequest *)createFetchRequestWithEntity:(NSString *)entityName andResultType:(NSFetchRequestResultType)resultType andPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setResultType:resultType];
    [fetchRequest setReturnsDistinctResults:YES];
    
    return fetchRequest;
}

- (NSFetchRequest *)createFetchRequestWithEntity:(NSString *)entityName propertyToFetch:(NSString *)property andPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:property]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    return fetchRequest;
}

- (NSString *)findRelationShipBetweeen:(NSString *)target andEntity:(NSString *)entity
{
    NSArray *relationShips = [[NSEntityDescription entityForName:target inManagedObjectContext:self.managedObjectContext] relationshipsWithDestinationEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    
    if (relationShips.count == 0)
    {
        return nil;
    }
    
    NSRelationshipDescription *relationShipDescription = [relationShips objectAtIndex:0];
    
    return relationShipDescription.name;
}

- (bool)targetEntityContainsKey:(NSString *)key
{
    return [[[[NSEntityDescription entityForName:self.targetEntity inManagedObjectContext:self.managedObjectContext] attributesByName] allKeys] containsObject:key];
}

- (bool)targetEntityHasAttributes
{
    return [[[[NSEntityDescription entityForName:self.targetEntity inManagedObjectContext:self.managedObjectContext] relationshipsByName] allKeys] containsObject:@"attributes"];
}

#pragma mark - cache

- (NSData *)cacheFromFetchResult:(NSArray *)fetchResult
{
    if (!fetchResult) return nil;
    
    NSMutableArray *objectURIs = [NSMutableArray new];
    
    [fetchResult enumerateObjectsUsingBlock:^(NSManagedObjectID *objID, NSUInteger idx, BOOL *stop) {
        
        [objectURIs addObject:[objID URIRepresentation]];
    }];
    
    return [NSKeyedArchiver archivedDataWithRootObject:objectURIs];
}

- (NSArray *)managedObjectsFromCache:(NSData *)cache
{
    if (!cache) return nil;
    
    NSArray *objectURIs = [NSKeyedUnarchiver unarchiveObjectWithData:cache];
    
    NSMutableArray *objectIDs = [NSMutableArray new];
    
    [objectURIs enumerateObjectsUsingBlock:^(NSURL *objURI, NSUInteger idx, BOOL *stop) {
        
        [objectIDs addObject:[self.managedObjectContext objectWithID:[self.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:objURI]]];
    }];
    
    return objectIDs;
}

- (NSArray *)removeDictionaryOverheadFromResult:(NSArray *)foundObjects
{
    NSMutableArray *result = [NSMutableArray new];
    
    [foundObjects enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        
         [result addObjectsFromArray:[dict allValues]];
     }];
    
    return result;
}

#pragma mark - bugfix

- (void)removeLevelsObject:(SBFilterLevel *)value
{
    // Create a mutable set with the existing objects, add the new object, and set the relationship equal to this new mutable ordered set
    NSMutableOrderedSet *levels = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.levels];
    [levels removeObjectAtIndex:[levels indexOfObject:value]];
    self.levels = levels;
}

#pragma mark - test 

+ (BOOL)testFilterWithEntity:(NSString *)entityToFetch numberOfTests:(int)numberOfTests
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (int testNo = 0; testNo < numberOfTests; testNo++)
    {
        NSString *filterName = [NSString stringWithFormat:@"TEST #%i", testNo];
        
        SBFilter *filter = [SBFilter filterWithTargetEntity:entityToFetch andName:filterName];
        
        [filter setObjectsToFilter:[NSSet setWithArray:[NSClassFromString(entityToFetch) MR_findAll]]];
        
        NSArray *availableKeys = [filter availableKeys];
        
        if (availableKeys.count == 0)
        {
            DDLogError(@"No Available Keys!");
            return NO;
        }
        
        NSUInteger numberOfFetches = arc4random() % [availableKeys count];
        
        for (int i = 0; i < numberOfFetches; i++)
        {
            NSDictionary *key = [availableKeys objectAtIndex:arc4random() % [availableKeys count]];
            
            NSString *currentKey = [key valueForKey:@"key"];
            
            NSArray *disctinctValues = [filter distinctValuesForKey:currentKey];
            
            if (disctinctValues.count == 0) continue;
            
            NSUInteger numberOfValues = arc4random() % disctinctValues.count;
            
            NSMutableArray *objectsToFilter = [NSMutableArray new];
            
            for (int v = 0; v < numberOfValues; v++)
            {
                [objectsToFilter addObject:[disctinctValues objectAtIndex:v]];
            }
            
            if (objectsToFilter.count == 0) continue;
            
            [filter addFilterLevelWithValues:objectsToFilter andKey:currentKey];
            
            SBFilterLevel *newFilter = [filter filterlevelforKey:currentKey];
        
            if (newFilter.type.intValue == 0)
            {
                [filter removeFilterAtLevel:newFilter.level.intValue];
            }
        }
        
        [filter saveFilter];
        
        NSArray *ergebnis = [filter getResult];
        
        [result addObject:@{@"name": filterName, @"entity": entityToFetch, @"levels": [NSNumber numberWithUnsignedInt:filter.levels.count],  @"result": [NSNumber numberWithUnsignedInt:ergebnis.count]}];
    }
    
    DDLogInfo(@"%@", result);
    
    return YES;
}

@end
