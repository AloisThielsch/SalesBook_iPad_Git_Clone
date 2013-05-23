//
//  SBDocument+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SBDocument+Extensions.h"

#import "SAGSyncManager.h"
#import "SBCustomer+Extensions.h"

@implementation SBDocument (Extensions)

+ (SBDocument *)createNewDocument
{
    SBDocument *document = [SBDocument MR_createEntity];
    
    document.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    document.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return document;
}

+ (SBDocument *)getDocumentWithUniqueID:(NSString *)uniqueID
{
    return [SBDocument MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (void)renewReferences //Nicht referenzierte Objekte zuordnen
{
    NSArray *notReferencedObjects = [SBDocument MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"customer == nil"]];
    
    if (notReferencedObjects)
    {
        [notReferencedObjects enumerateObjectsUsingBlock:^(SBDocument *document, NSUInteger idx, BOOL *stop) {
            
            document.customer = [SBCustomer MR_findFirstByAttribute:@"customerNumber" withValue:document.customerNumber];
        
        }];
    }
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
    
    if (newTransferDate.length == 0)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"Can´t update %@ from Dictionary! Reason: %@ is missing!", [[self class] description],[self webserviceTransferDate]];
        
        [[SAGSyncManager sharedClient] addErrorWithMessage:errorMessage andUserInfo:dict];
        
        return NO;
    }
    
    SBDocument *document = [self getDocumentWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (document) //Falls das Dokument schon exisitert!
        {
            [document MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!document)
    {        
        document = [self createNewDocument]; //Neues Dokument anlegen
        document.uniqueID = uniqueID; //Generierte UUID überschreiben
    }

    [document MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    [document setAttributesfromDictionary:[dict valueForKey:@"customFieldValues"]]; //CustomFields
    
    document.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    document.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    document.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Documents", @"SBDocuments"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetDocuments";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetDocumentsDeleted";
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
    return @"documents";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"documentsDeleted";
}

#pragma mark - reference

- (void)setCustomerNumber:(NSString *)customerNumber
{    
    [self willChangeValueForKey:@"customerNumber"];
    [self setPrimitiveValue:customerNumber forKey:@"customerNumber"];
    [self didChangeValueForKey:@"customerNumber"];
    
    [self setCustomer:[SBCustomer getCustomerWithCustomerNumber:customerNumber]];
}

- (void)setCustomer:(SBCustomer *)customer
{
    if (self.customerNumber.length == 0 || ![self.customerNumber isEqualToString:customer.customerNumber])
    {
        [self willChangeValueForKey:@"customerNumber"];
        [self setPrimitiveValue:customer.customerNumber forKey:@"customerNumber"];
        [self didChangeValueForKey:@"customerNumber"];
    }
    
    [self willChangeValueForKey:@"customer"];
    [self setPrimitiveValue:customer forKey:@"customer"];
    [self didChangeValueForKey:@"customer"];
}

#pragma mark - class methods

+ (NSArray *)numberOfDocumentsGroupByDocumentTypeWithCustomer:(SBCustomer *)customer
{
    // Create an expression for the key path.
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"documentType"];
    
    // Create an expression to represent the minimum value at the key path 'creationDate'
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:" arguments:@[keyPathExpression]];
    
    // Create an expression description using the minExpression and returning a date.
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    
    // The name is the key that will be used in the dictionary for the return value.
    [expressionDescription setName:@"numberOfDocuments"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    
    NSFetchRequest *fetch = [SBDocument MR_createFetchRequest];
    
    if (customer)
    {
        fetch.predicate = [NSPredicate predicateWithFormat:@"customer = %@ OR customer = nil", customer];
    }
    
    fetch.resultType = NSDictionaryResultType;
    
    fetch.propertiesToFetch = @[@"documentType", expressionDescription];
    fetch.propertiesToGroupBy = @[@"documentType"];
    fetch.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"documentType" ascending:@YES]];
    
    return [SBDocument MR_executeFetchRequest:fetch];
}

+ (NSArray *)getDocumentsOfDocumentType:(NSInteger)documentType withCustomer:(SBCustomer *)customer
{
	NSFetchRequest *request = [SBDocument MR_createFetchRequest];
	NSPredicate *predicate;
	
	NSPredicate *typePredicate = [NSPredicate predicateWithFormat:@"documentType = %d", documentType];
	
	if (customer) {
		NSPredicate *customerPredicate = [NSPredicate predicateWithFormat:@"customer = %@ or customer == nil", customer];
		predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[ typePredicate, customerPredicate ]];
	} else {
		predicate = typePredicate;
	}
	
	request.predicate = predicate;
	
	return [SBDocument MR_executeFetchRequest:request];
}

@end
