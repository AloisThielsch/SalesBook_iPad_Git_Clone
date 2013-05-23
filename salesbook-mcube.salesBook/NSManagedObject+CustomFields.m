//
//  NSManagedObject+CustomFields.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "NSManagedObject+CustomFields.h"

#import "NSManagedObject+XML.h"
#import "SBCustomField+Extensions.h"
#import "SBAttribute.h"

#import "SBFilter+Extensions.h"

#import "SAGSyncManager.h"

@implementation NSManagedObject (CustomFields)

- (void)setAttribute:(id)value withKey:(NSString *)key andLanguage:(NSString *)language
{
    SBAttribute *newAttribute = [self attributeWithLangauge:language andKey:key];
    
    if (newAttribute)
    {
        newAttribute.theValue = value;
        return;
    }
    
    [self insertAttribute:value withKey:key andLanguage:language];
}

- (void)insertAttribute:(id)value withKey:(NSString *)key andLanguage:(NSString *)language
{
    if (value == [NSNull null])
    {
        DDLogError(@"### Error: Can´t set NULL value for Key: %@ andLanguage: %@", key, language);
        return;
    }
    
    SBAttribute *newAttribute = [SBAttribute MR_createEntity];
    newAttribute.theKey = key;
    newAttribute.language = language;
    newAttribute.theValue = value;
    
    [self performSelector:@selector(addAttributesObject:) withObject:newAttribute];
}

- (void)deleteAttributeWithKey:(NSString *)key andLanguage:(NSString *)language
{
    [[self attributeWithLangauge:language andKey:key] MR_deleteEntity];
}

- (id)valueForAttribute:(NSString *)key andLanguage:(NSString *)language
{
    return [[self attributeWithLangauge:language andKey:key] theValue];
}

#pragma mark - magic transformer

- (NSString *)stringValueForAttribute:(NSString *)key andLanguage:(NSString *)language
{
    return [SBCustomField stringValueWithObject:[self valueForAttribute:key andLanguage:language]];
}

#pragma mark - default customFieldValues setzen

- (bool)setDefaultValues
{
    return [SBCustomField setDefaultValuesWithObject:self];
}

- (NSArray *)getVisibleData
{
    return [SBCustomField getVisibleDataWithObject:self withCustomFieldDetailLevel:SAGCustomFieldDetailAll limitResultsTo:0];
}

- (NSArray *)getVisibleDataList
{
    return [SBCustomField getVisibleDataWithObject:self withCustomFieldDetailLevel:SAGCustomFieldDetailList limitResultsTo:16];
}

- (NSArray *)getVisibleDataDetail
{
    return [SBCustomField getVisibleDataWithObject:self withCustomFieldDetailLevel:SAGCustomFieldDetailDetail limitResultsTo:4];
}

- (NSArray *)getEditableData
{
    return [SBCustomField getEditableDataWithObject:self];
}

- (NSArray *)getVisibleDataWithCustomFieldDetailLevel:(enum SAGCustomFieldDetailLevel)level limitResultsTo:(NSUInteger)maxNumberOfResults
{
    return [SBCustomField getVisibleDataWithObject:self withCustomFieldDetailLevel:level limitResultsTo:maxNumberOfResults];
}

- (void)setAttributesfromDictionary:(NSDictionary *)attributes
{
    if ([attributes isEqual:[NSNull null]]) //Theoretisch kann es auch leer sein...
    {
        return;
    }
    
    if (![self hasAttributes])
    {
        DDLogError(@"%@ hat keine Attribute!", [self.class description]);
        return;
    }
    
    NSSet *myAttributes = [self valueForKey:@"attributes"];
    
    bool isInitial = myAttributes.count == 0;
    
    for (NSDictionary *attribute in attributes)
    {
        if ([[attribute valueForKey:@"actionFlag"] intValue] == SAGActiveStateDeleted)
        {
            [self deleteAttributeWithKey:[attribute valueForKey:@"fieldName"] andLanguage:[attribute valueForKey:@"language"]];
        }
        else
        {
            NSString *theKey = [attribute valueForKey:@"fieldName"];
            NSString *language = [attribute valueForKey:@"language"];
            id theValue = [attribute valueForKey:@"value"];
            
            if (isInitial)
            {
                [self insertAttribute:theValue withKey:theKey andLanguage:language];
            }
            else
            {
                [self setAttribute:theValue withKey:theKey andLanguage:language];
            }
        }
    }
}

- (void)deleteAttributesWithLanguage:(NSString *)language
{
    NSSet *attributes = [self performSelector:@selector(attributes)];
    
    NSArray *foundObjects = [[attributes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"language == %@", language]] allObjects];
    
    for (SBAttribute *attribute in foundObjects)
    {
        [attribute MR_deleteEntity];
    }
}

#pragma mark - internal Functions

- (SBAttribute *)attributeWithLangauge:(NSString *)language andKey:(NSString *)key
{
    NSArray *foundObjects = [self attributesWithKey:key andLanguage:language];
    
    if (foundObjects.count == 1)
    {
        return [foundObjects objectAtIndex:0];
    }
    
    return nil;
}

- (NSArray *)attributesWithKey:(NSString *)key andLanguage:(NSString *)language
{
    NSSet *attributes = [self valueForKey:@"attributes"];
    
    return [[attributes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"theKey = %@ AND language = %@", key, language]] allObjects];
}

- (bool)hasAttributes
{
    return [[self.entity.relationshipsByName allKeys] containsObject:@"attributes"];
}

- (bool)entityContainsKey:(NSString *)key
{
    return [[self.entity.attributesByName allKeys] containsObject:key];
}

- (NSString *)findInverseRelationshipWithEntity:(NSString *)entity
{
    NSArray *relationShips = [[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext] relationshipsWithDestinationEntity:self.entity];
    
    if (relationShips.count == 0)
    {
        return nil;
    }
    
    NSRelationshipDescription *relationShipDescription = [relationShips objectAtIndex:0];
    
    if (relationShipDescription.isToMany)
    {
        return nil;
    }
    
    return relationShipDescription.name;
}

- (bool)hasToManyRelationshipWithEntity:(NSString *)entity
{
    NSArray *relationShips = [[NSEntityDescription entityForName:self.entity.name inManagedObjectContext:self.managedObjectContext] relationshipsWithDestinationEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    
    if (relationShips.count == 0)
    {
        return NO;
    }
    
    NSRelationshipDescription *relationShipDescription = [relationShips objectAtIndex:0];
    
    return relationShipDescription.isToMany;
}

- (NSData *)getXMLforDelete:(bool)deleteXML
{
   return [[self toXMLforDelete:deleteXML] dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)saveToMCube
{
    [[SAGSyncManager sharedClient] push:self];
}

- (void)saveForBatchTransfer
{
    [[SAGSyncManager sharedClient] saveForTransfer:self];
}

- (void)prepareForDelete
{
    [[SAGSyncManager sharedClient] prepareForDelete:self];
}

@end
