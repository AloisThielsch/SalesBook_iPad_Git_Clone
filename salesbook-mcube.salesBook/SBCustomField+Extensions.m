//
//  SBCustomField+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 28.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBCustomField+Extensions.h"
#import "NSManagedObject+CustomFields.h"

#import "SAGSyncManager.h"

@implementation SBCustomField (Extensions)

+ (SBCustomField *)createNewCustomField
{
    SBCustomField *customField = [SBCustomField MR_createEntity];
    
    customField.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    customField.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return customField;
}

+ (SBCustomField *)getCustomFieldWithUniqueID:(NSString *)uniqueID
{
    return [SBCustomField MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (SBCustomField *)getCustomFieldWithTargetEntity:(NSString *)targetEntity andKey:(NSString *)key
{
    return [SBCustomField MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"targetEntity = %@ AND textFromKey = %@", targetEntity, key]];
}

+ (void)prepageForImport
{
    [self MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"uniqueID != nil"]];
}

#pragma mark - Update

+ (BOOL)updateDocumentFromDictionary:(NSDictionary *)dict
{
    NSString *uniqueID = [dict valueForKey:[self webserviceUniqueID]];
    
    if (uniqueID.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description], [self webserviceUniqueID]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    NSString *newTransferDate = [dict valueForKey:[self webserviceTransferDate]];
    
//    if (newTransferDate.length == 0)
//    {
//        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description],[self webserviceTransferDate]];
//        
//        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
//        
//        return NO;
//    }

    SBCustomField *customField = [self getCustomFieldWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (customField) //Falls das Dokument schon exisitert!
        {
            [customField MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!customField)
    {
        customField = [self createNewCustomField]; //Neues Dokument anlegen
        customField.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [customField MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    [customField setAttributesfromDictionary:[dict valueForKey:@"customFieldLabels"]]; //Sprachabhängige Daten wegschreiben!
    
    [SBSelectionOption setAttributesfromDictionary:[dict valueForKey:@"selectBoxField"] forCustomField:customField];
    
    customField.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    customField.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    customField.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Custom Fields", @"SBCustomFields"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetCustomFieldDefinitions";
}

+ (NSString *)webserviceDelete
{
    return nil;
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"uniqueID";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"50";
}

+ (NSString *)webserviceDataBlock
{
    return @"customFieldDefinitions";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"customFieldDefinitionsDeleted";
}

+ (BOOL)shouldRemoveDataBeforeImport
{
    return YES;
}

#pragma mark - customFields

+ (BOOL)setDefaultValuesWithObject:(NSManagedObject *)targetObject
{
    for (SBCustomField *customField in [SBCustomField MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"targetEntity = %@ AND isMandatory = %@", targetObject.entity.name, @YES]]) //TODO: Nicht nur SelectBoxen, sondern alle mit isMandatory!
    {
        if (customField.customFieldType.intValue == SAGCustomFieldTypeSelect) //Handelt es sich um eine Selectbox, wird hier der Text zum Optioncode ermittelt.
        {
            [customField setValue:[[customField defaultOption] optionCode] withObject:targetObject andLangauge:nil];
        }
        else
        {
            DDLogWarn(@"HIER MÜSSTEN NOCH DEFAULT WERTE GESETZ WERDEN! %@", customField.uniqueID);
        }
    }
    
    return YES;
}

+ (NSArray *)getVisibleDataWithObject:(NSManagedObject *)targetObject withCustomFieldDetailLevel:(enum SAGCustomFieldDetailLevel)level limitResultsTo:(NSUInteger)maxNumberOfResults
{
    NSMutableArray *visibleData = [NSMutableArray new];
    
    NSString *language = [[SAGSettingsManager sharedManager] itemDisplayLanguage]; //Die Sprache aus den AppSettings übernehmen.
    
    NSPredicate *predicate;
    
    switch (level) {
        case SAGCustomFieldDetailDetail:
            predicate = [NSPredicate predicateWithFormat:@"targetEntity == %@ AND isVisibleInDetails = %@", targetObject.entity.name, @YES];
            break;
        case SAGCustomFieldDetailList:
            predicate = [NSPredicate predicateWithFormat:@"targetEntity == %@ AND isVisibleInList = %@", targetObject.entity.name, @YES];
            break;
        default:
            predicate = [NSPredicate predicateWithFormat:@"targetEntity == %@", targetObject.entity.name];
            break;
    }

    NSArray *results = [[SBCustomField MR_findAllWithPredicate:predicate] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];

    for (SBCustomField *customField in results)
    {
        NSDictionary *result = [customField getDictionaryWithTargetObject:targetObject andLanguage:language];
        
        if (result == nil) continue;
        
        [visibleData addObject:result];
        
        if (maxNumberOfResults != 0 && maxNumberOfResults == visibleData.count)
        {
            return visibleData;
        }
    }
    
    return visibleData;
}

+ (NSArray *)getEditableDataWithObject:(NSManagedObject *)targetObject
{
    NSMutableArray *editableData = [NSMutableArray new];
    
    NSString *language = [[SAGSettingsManager sharedManager] itemDisplayLanguage]; //Die Sprache aus den AppSettings übernehmen.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"targetEntity = %@ AND isEditable = %@", targetObject.entity.name, @YES];
    
    NSArray *results = [[SBCustomField MR_findAllWithPredicate:predicate] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
    
    for (SBCustomField *customField in results)
    {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[customField getDictionaryWithTargetObject:targetObject andLanguage:language]];
        
        [result setValuesForKeysWithDictionary:@{@"uniqueID": customField.uniqueID, @"label": customField.label, @"regExRule": customField.regExRule, @"isMandatory": customField.isMandatory, @"isMultiSelect": @NO, @"SAGCustomFieldType": customField.customFieldType}];
        
        [editableData addObject:result];
    }
    
    return editableData;
}

+ (NSArray *)getFilterableKeysForEntity:(NSString *)entityName
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (SBCustomField *customField in [SBCustomField MR_findAllSortedBy:@"sortOrder" ascending:@YES withPredicate:[NSPredicate predicateWithFormat:@"targetEntity = %@ AND isFilterable = %@", entityName, @YES]])
    {
        NSString *key = customField.textFromKey; //Wie heist der Key der gefiltert werden soll?
        
        if (customField.targetField.length > 0) key = customField.targetField;
        
        [result addObject:@{@"uniqueID": customField.uniqueID, @"key": key, @"label": customField.label}];
    }
    
    if (result.count == 0) return nil;
    
    return result;
}

+ (NSArray *)getSearchableKeysForEntity:(NSString *)entityName
{
    NSMutableArray *result = [NSMutableArray new];
    
    for (SBCustomField *customField in [SBCustomField MR_findAllSortedBy:@"sortOrder" ascending:@YES withPredicate:[NSPredicate predicateWithFormat:@"targetEntity = %@ AND isSearchable = %@", entityName, @YES]])
    {
        NSString *key = customField.textFromKey; //Wie heist der Key der gefiltert werden soll?
        
        if (customField.targetField.length > 0) key = customField.targetField;
        
        [result addObject:@{@"uniqueID": customField.uniqueID, @"key": key, @"label": customField.label}];
    }
    
    if (result.count == 0) return nil;
    
    return result;
}

#pragma mark - getterOrSetter...

- (void)setValue:(id)value withObject:(NSManagedObject *)object andLangauge:(NSString *)language
{
    NSString *key = self.textFromKey;
    
    if (self.targetField.length > 0)
    {
        key = self.targetField;
    }
    
    if (self.customFieldType.intValue == SAGCustomFieldTypeSelect) //Sicherstellen das hier nur der OptionCode gesetzt wird nicht die DenotationValue der Selectbox!
    {
        if (![self isValidOptionCode:[SBCustomField stringValueWithObject:value]])
        {
            DDLogError(@"%@ is no valid OptionCode!", value);
            return;
        }
    }
    
    if ([object entityContainsKey:key]) //Prüfen ob das Object den Key enthällt
    {
        [object setValue:value forKey:key];
    }
    else if ([object hasAttributes]) //Ansonsten muss es ein CustomField sein
    {
        if (self.isMultiLanguage && self.customFieldType.intValue != SAGCustomFieldTypeSelect) //Wenn es als Mehrsprachig deklariert ist, muss die Sprache berücksichtigt werden. Selectboxen sind hier eine ausnahme, denn die haben einen Sprachunabhängigen ActionCode.
        {
            [object setAttribute:value withKey:key andLanguage:language];
        }
        else
        {
            [object setAttribute:value withKey:key andLanguage:nil];
        }
    }
}

- (NSString *)getValueForKey:(NSString *)key withObject:(NSManagedObject *)object andLanguage:(NSString *)language
{
    if ([object respondsToSelector:NSSelectorFromString(self.textFromKey)] && ![self.textFromKey isEqualToString:@"description"]) //Das Objekt selber abfragen...
    {
        id obj = [object valueForKey:self.textFromKey];
        
        if (obj)
        {
            return [SBCustomField stringValueWithObject:obj];
        }
    }
    
    if ([object entityContainsKey:key]) //Prüfen ob das Object den Wert enthällt
    {
        return [SBCustomField stringValueWithObject:[object valueForKey:key]];
    }
    else if ([object hasAttributes]) //Es muss in dem Fall ein CustomField sein
    {
        if (self.isMultiLanguage && self.customFieldType.intValue != SAGCustomFieldTypeSelect) //Wenn es als Mehrsprachig deklariert ist, muss die Sprache berücksichtigt werden. Selectboxen sind hier eine ausnahme, denn die haben einen Sprachunabhängigen ActionCode.
        {
            return [object stringValueForAttribute:key andLanguage:language];
        }
        else
        {
            return [object stringValueForAttribute:key andLanguage:nil];
        }
    }
    
    return nil;
}

#pragma mark - internal Stuff

- (NSString *)label
{
    NSString *theLabel = [self stringValueForAttribute:self.textFromKey andLanguage:[[SAGSettingsManager sharedManager] itemDisplayLanguage]];
    
    if (theLabel.length == 0) //Fallback auf theKey...
    {
        theLabel = [NSString stringWithFormat:@"(%@)", self.textFromKey];
    }
    
    return theLabel;
}

- (NSString *)getTextFromEntityWithTargetObject:(NSManagedObject *)targetObject withLanguage:(NSString *)language
{
    if (self.textFromEntity.length == 0) return nil; //Wenn keine textFromEntity spezifiert wurde nix tun!

    if ([targetObject hasToManyRelationshipWithEntity:self.textFromEntity]) //Es können keine to-many objekte referenziert werden...
    {
        DDLogError(@"Sorry! %@ and %@ have a to-many relationship!", targetObject.entity.name, self.textFromEntity);
        return nil;
    }
    
    NSString *relationShip = [targetObject findInverseRelationshipWithEntity:self.textFromEntity]; //Herausfinden wir die Objekte in beziehung stehen!
    
    if (relationShip.length == 0) //Wenn die Objekte keine Beziehung haben nix tun...
    {
        DDLogError(@"Sorry can´t find no relationShip between %@ and %@!", targetObject.entity.name, self.textFromEntity);
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.textFromEntity];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", relationShip, targetObject]];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSManagedObject *textFromEntity = [NSManagedObject MR_executeFetchRequestAndReturnFirstObject:fetchRequest];
    
    if (textFromEntity == nil)
    {
        DDLogError(@"Sorry something went wrong!");
        return nil;
    }
    
    if ([textFromEntity respondsToSelector:NSSelectorFromString(self.textFromKey)]) //Das Objekt selber abfragen...
    {
        id obj = [textFromEntity valueForKey:self.textFromKey];
        
        if (obj)
        {
            return [SBCustomField stringValueWithObject:obj];
        }
    }
    
    return [self getValueForKey:self.textFromKey withObject:textFromEntity andLanguage:language]; //Hier wird IMMER der textFromKey abgefragt!
}

- (NSDictionary *)getDictionaryWithTargetObject:(NSManagedObject *)targetObject andLanguage:(NSString *)language
{
    NSString *theKey = self.textFromKey;
    NSString *theValue; //Nach diesem Wert wird gesucht, dafür gibt es feste Regeln!
    
    if (self.targetField.length > 0)
    {
        theKey = self.targetField;
        theValue = [self getValueForKey:theKey withObject:targetObject andLanguage:language]; //1. Das ürsprüngliche Objekt nach dem TargetField fragen!
    }
    else if (self.textFromEntity.length > 0)
    {
        theValue = [self getTextFromEntityWithTargetObject:targetObject withLanguage:language]; //2. Das in TextFromEntity angegebene Objekt nach dem TextFromKey fragen!
    }
    else
    {
        theValue = [self getValueForKey:theKey withObject:targetObject andLanguage:language]; //3. Das ürsprüngliche Objekt nach dem TextFromKey fragen!
    }
    
    if (theValue.length == 0) //Es werden nur Werte ausgegeben die nicht LEER sind.
    {
        return nil;
    }
    
    if (self.customFieldType.intValue == SAGCustomFieldTypeSelect) //Handelt es sich um eine Selectbox, wird hier der Text zum Optioncode ermittelt.
    {
        NSString *optionCodeDenotation = [[self selectionOptionWithOptionCode:theValue] denotationWithLanguage:language];
        
        if (optionCodeDenotation.length > 0) //Notwendig falls der Text nicht gefunden wird...
        {
            theValue = optionCodeDenotation;
        }
    }
    
    return @{@"uniqueID": self.uniqueID, @"value": theValue, @"label": self.label};
}

#pragma mark - selection

- (SBSelectionOption *)defaultOption
{
    NSArray *result = [[self.seletionOptions filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isDefault == %@", [NSNumber numberWithBool:YES]]] allObjects];
    
    if (result.count > 0)
    {
        return [result objectAtIndex:0];
    }
    
	return nil;
}

- (SBSelectionOption *)selectionOptionWithOptionCode:(NSString *)optionCode
{
    NSArray *result = [[self.seletionOptions filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"optionCode == %@", optionCode]] allObjects];
    
    if (result.count > 0)
    {
        return [result objectAtIndex:0];
    }
    
	return nil;
}

- (bool)isValidOptionCode:(NSString *)optionCode
{
    SBSelectionOption *test = [self selectionOptionWithOptionCode:optionCode];
    
    if (test != nil)
    {
        return YES;
    }
    
    return NO;
}

- (NSArray *)visibleSelectionOptions
{
    return [[[self.seletionOptions objectsPassingTest:^BOOL(SBSelectionOption *selectionOption, BOOL *stop)
              {
                  return selectionOption.isVisible.boolValue;
                  
              }] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]]];
}

+ (NSString *)stringValueWithObject:(id)obj
{
    if (obj == nil || obj == [NSNull null])
    {
        return nil;
    }
    else if ([obj isKindOfClass:[NSString class]])
    {
        return obj;
    }
    else if ([obj isKindOfClass:[NSDate class]])
    {
        return [obj asCustomFieldDate];
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        return [obj stringWithLocalizedNumberStyle];
    }
    
    return [obj stringValue];
}

@end
