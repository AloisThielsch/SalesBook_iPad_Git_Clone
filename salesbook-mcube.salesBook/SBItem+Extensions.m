//
//  SBItem+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 28.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBItem+Extensions.h"

#import "SAGSyncManager.h"

#import "SBVariant+Extensions.h"
#import "SBItemGroup+Extensions.h"

#import "SBAttribute+Extensions.h"
#import "SBStock+Extensions.h"

@implementation SBItem (Extensions)

+ (SBItem *)createNewItem
{
    SBItem *item = [SBItem MR_createEntity];
    
    item.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    item.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return item;
}

+ (SBItem *)getItemWithUniqueID:(NSString *)uniqueID
{
    return [SBItem MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

+ (SBItem *)getItemWithItemNumber:(NSString *)itemNumber
{
    return [SBItem MR_findFirstByAttribute:@"itemNumber" withValue:itemNumber];
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
    
    SBItem *item = [self getItemWithUniqueID:uniqueID];
    
    if ([[dict valueForKey:[self webserviceActionState]] intValue] == SAGActiveStateDeleted) //Prüfen ob gelöscht werden muss!
    {
        if (item) //Falls das Dokument schon exisitert!
        {
            [item MR_deleteEntity]; //Das bestehende Dokument löschen!
        }
        return YES;
    }
    
    if (!item)
    {
        item = [self createNewItem]; //Neues Dokument anlegen
        item.uniqueID = uniqueID; //Generierte UUID überschreiben
    }
    
    [item MR_importValuesForKeysWithObject:dict]; //MR_importValuesForKeysWithObject füllt alle Daten in die entsprechenden Felder wenn in UserInfo "mappedKeyName" eingetragen ist!
    
    item.transferDate = [newTransferDate fromISO8601FormatedString]; //Timestamp
    item.documentState = [NSNumber numberWithInt:SAGDocumentStateCommited]; //Datensatz wurde vom mCube bestätigt !!!
    item.alternationDate = [NSDate date]; //Aktualisierung speichern
    
    return YES;
}

#pragma mark - Webservice Settings

+ (NSString *)localizedClassName
{
    return NSLocalizedString(@"Items", @"SBItem"); //Plural
}

+ (NSString *)webserviceUpdate
{
    return @"V3GetItem";
}

+ (NSString *)webserviceDelete
{
    return @"V3GetItemDeleted";
}

+ (NSString *)webserviceActionState
{
    return @"actionFlag";
}

+ (NSString *)webserviceUniqueID
{
    return @"itemNumber";
}

+ (NSString *)webserviceTransferDate
{
    return @"ts";
}

+ (NSString *)webserviceBlockSize
{
    return @"250";
}

+ (NSString *)webserviceDataBlock
{
    return @"items";
}

+ (NSString *)webserviceDataBlockDeleted
{
    return @"itemsDeleted";
}

#pragma mark - Allgemein

- (SBVariant *)getDefaultVariant
{
    return [SBVariant MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"owningItem = %@", self] sortedBy:@"displayPriority" ascending:@YES];
}

- (NSDate *)earliestDeliveryDateWithMatrix2Value:(NSString *)value
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"matrixValueFor2ndDimension == %@", value];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"earliestDeliveryDate" ascending:YES]; //TODO: Test
    
    for (SBVariant *variant in [[self.variants filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]])
    {
        return variant.earliestDeliveryDate;
    }
    
    return nil;
}

- (NSDate *)latestDeliveryDateWithMatrix2Value:(NSString *)value
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"matrixValueFor2ndDimension == %@", value];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"latestDeliveryDate" ascending:NO]; //TODO: Test
    
    for (SBVariant *variant in [[self.variants filteredSetUsingPredicate:predicate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]])
    {
        return variant.latestDeliveryDate;
    }
    
    return nil;
}

#pragma mark - matrixVarianteFinden

- (SBVariant *)getVariantWithMatrixKey1:(NSString *)key1 andMatrixKey2:(NSString *)key2
{
    if (key1 == nil) key1 = @"";
    if (key2 == nil) key2 = @"";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"matrixValueFor1stDimension = %@ AND matrixValueFor2ndDimension = %@", key1, key2];
    
    NSArray *foundVariants = [[self.variants filteredSetUsingPredicate:predicate] allObjects];
    
    if (foundVariants.count > 0)
    {
        return [foundVariants objectAtIndex:0];
    }
    
    return nil;
}

- (SBVariant *)getVariantWithMatrixKey1:(NSString *)key1 andMatrixKey2:(NSString *)key2 andMatrixKey3:(NSString *)key3
{
    if (key1 == nil) key1 = @"";
    if (key2 == nil) key2 = @"";
    if (key3 == nil) key3 = @"";

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"matrixValueFor1stDimension = %@ AND matrixValueFor2ndDimension = %@ AND matrixValueFor3rdDimension = %@", key1, key2, key3];

    NSArray *foundVariants = [[self.variants filteredSetUsingPredicate:predicate] allObjects];

    if (foundVariants.count > 0)
    {
        return [foundVariants objectAtIndex:0];
    }

    return nil;
}

#pragma mark - matrixWerte

- (NSArray *)getMatrixItemsFor2ndDimension
{
    if (self.variants.count == 1) //TODO: Abklären ob das der richtige Weg ist! Sonst gehen keine Einzelartikel!
    {
        return self.variants.allObjects;
    }
    
    NSArray *matix1stDimension = [self getMatrixKey1Values];
    NSArray *matix2stDimension = [self getMatrixKey2Values];
    
    NSMutableArray *foundVariants = [NSMutableArray new];
    
    SBVariant *variant;
    NSString *matixValueFor1stDimension = [matix1stDimension objectAtIndex:0];
    
    for (NSString *matrix2ndDimenstion in matix2stDimension)
    {
        variant = [self getVariantWithMatrixKey1:matixValueFor1stDimension andMatrixKey2:matrix2ndDimenstion];
        
        if (variant == nil) continue;
        
        [foundVariants addObject:variant];
    }
    
    if (foundVariants.count == 0) return nil;
    
    return foundVariants;
}

- (NSArray *)getMatrixKey1Values
{
    return [self getMatrixKey:@"matrixValueFor1stDimension" withSortBy:@"matrixSortOrderFor1stDimension"];
}

- (NSArray *)getMatrixKey2Values
{
    return [self getMatrixKey:@"matrixValueFor2ndDimension" withSortBy:@"matrixSortOrderFor2ndDimension"];
}

- (NSArray *)getMatrixKey3Values
{
    return [self getMatrixKey:@"matrixValueFor3rdDimension" withSortBy:@"matrixSortOrderFor3rdDimension"];
}

- (NSArray *)getMatrixKey:(NSString *)matrixKey withSortBy:(NSString *)sortBy
{
    NSMutableSet *result = [NSMutableSet new];
    
    for (SBVariant *variant in [self.variants sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:YES]]])
    {
        NSString *value = [variant valueForKey:matrixKey];
        
        if (value != nil)
        {
            [result addObject:value];
        }
    }
    
    if (result.count== 0) return nil;
    
    return result.allObjects;
}

#pragma mark - referenzen

- (void)setItemGroupNumber:(NSString *)itemGroupNumber
{
    [self willChangeValueForKey:@"itemGroupNumber"];
    [self setPrimitiveValue:itemGroupNumber forKey:@"itemGroupNumber"];
    [self didChangeValueForKey:@"itemGroupNumber"];
    
    [self setItemGroup:[SBItemGroup getItemGroupWithItemGroupNumber:itemGroupNumber]];
}

#pragma mark - baseColorImages

- (NSArray *)baseColorImages
{
    __block NSMutableSet *colors = [NSMutableSet new];
    
    [[self.variants valueForKey:@"baseColorNumber"] enumerateObjectsUsingBlock:^(NSString *baseColor, NSUInteger idx, BOOL *stop) {
        
        [colors addObject:baseColor];
    }];
    
    if (colors.count == 0) return nil;
    
    __block NSMutableArray *result = [NSMutableArray new];
    
    [[colors.allObjects sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] enumerateObjectsUsingBlock:^(NSString *baseColor, NSUInteger idx, BOOL *stop) {
        
        UIImage *img = [[SBMedia MR_findFirstByAttribute:@"colorNumber" withValue:baseColor] getImage];
        
        if (img) [result addObject:img];
    }];
    
    return result;
}

- (UIImage *)getSignalLightImage
{
    return [[SBStock MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"variant in %@", self.variants] sortedBy:@"availabilityState" ascending:NO] getSignalLightImage];
}

- (UIImage *)renderBaseColorImagesWithMaximumWidthOf:(NSUInteger)totalWidth
{
    if (self.baseColorImages.count == 0) return nil;
    
    static int WIDTH = 10, HEIGHT = 10, SPACE = 4;
    
    int number = (totalWidth - SPACE) / (WIDTH + SPACE);
    
    BOOL includeDots = self.baseColorImages.count > number;

    int count = includeDots ? number - 1 : self.baseColorImages.count;
    
    int offset = (totalWidth - (count * WIDTH + (count - 1) * SPACE)) / 2;
    
    UIGraphicsBeginImageContext(CGSizeMake(totalWidth, HEIGHT));
    
    for (int i = 0; i < count; i++)
    {
        UIImage *image = self.baseColorImages[i];
    
        CGFloat pos = i * (WIDTH + SPACE) + offset;
        
        [image drawInRect:CGRectMake(pos, 0, WIDTH, HEIGHT)];
    }
    
    if (includeDots)
    {
        CGFloat pos = count * (WIDTH + SPACE) + offset;
        
        [[[NSAttributedString alloc] initWithString:@"+" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor]}] drawAtPoint:CGPointMake(pos, -4)];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end