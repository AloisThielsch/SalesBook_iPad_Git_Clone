//
//  SBShoppingCart+Extensions.h
//  SalesBook
//
//  Created by Julian Knab on 08.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SBShoppingCart.h"

#import "SBAttribute+Extensions.h"
#import "SBDocumentPosition+Extensions.h"
#import "SBVariant+Extensions.h"

@interface SBShoppingCart (Extensions)

+ (SBShoppingCart *)createNewCart;
+ (SBShoppingCart *)createNewCartWithName:(NSString *)cartName;

+ (SBShoppingCart *)getCartWithName:(NSString *)cartName;

- (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd;
+ (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd toCart:(SBShoppingCart *)cartToAddTo;

- (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber;
+ (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber toCart:(SBShoppingCart *)cartToAddTo;

- (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd forDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)addItemVariant:(SBVariant *)variantToAdd forDeliveryDate:(NSDate *)deliveryDate toCart:(SBShoppingCart *)cartToAddTo;

- (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)addItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate toCart:(SBShoppingCart *)cartToAddTo;

- (void)removeItemVariant:(SBVariant *)variantToRemove;
+ (void)removeItemVariant:(SBVariant *)variantToRemove fromCart:(SBShoppingCart *)cartToRemoveFrom;

- (void)removeItemVariantWithNumber:(NSString *)variantNumber;
+ (void)removeItemVariantWithNumber:(NSString *)variantNumber fromCart:(SBShoppingCart *)cartToRemoveFrom;

- (void)removeItemVariant:(SBVariant *)variantToRemove forDeliveryDate:(NSDate *)deliveryDate;
+ (void)removeItemVariant:(SBVariant *)variantToRemove forDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToRemoveFrom;

- (void)removeItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate;
+ (void)removeItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToRemoveFrom;

- (void)removeDocumentPosition:(SBDocumentPosition *)documentPosition;
+ (void)removeDocumentPosition:(SBDocumentPosition *)documentPosition fromCart:(SBShoppingCart *)cartToRemoveFrom;

- (SBDocumentPosition *)getPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)getPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom;

- (SBDocumentPosition *)getPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)getPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom;

+ (int)getTotalNumberFromAllShoppingCartsForItemVariantWithNumber:(NSString *)variantNumber betweenDeliveryDate:(NSDate *)deliveryDate1 andDeliveryDate:(NSDate *)deliveryDate2;

- (int)getNumberOfPositions;
- (int)getTotalNumberOfVariantsFromAllPositions;

- (NSDate *)getEarliestDeliveryDate;
- (NSDate *)getLatestDeliveryDate;

- (double)getTotalPrice;
- (double)getTotalPriceWithRebate;

- (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariant:(SBVariant *)itemVariant forDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariant:(SBVariant *)itemVariant forDeliveryDate:(NSDate *)deliveryDate inCart:(SBShoppingCart *)cartToSetIn;

- (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate;
+ (SBDocumentPosition *)setAmount:(int)amountToSet ofItemVariantWithNumber:(NSString *)variantNumber forDeliveryDate:(NSDate *)deliveryDate inCart:(SBShoppingCart *)cartToSetIn;

- (SBDocumentPosition *)setAmount:(int)amountToSet ofDocumentPosition:(SBDocumentPosition *)documentPosition;

- (SBDocumentPosition *)increaseAmountOfDocumentPosition:(SBDocumentPosition *)documentPosition by:(int)amountToIncrease;
- (SBDocumentPosition *)decreaseAmountOfDocumentPosition:(SBDocumentPosition *)documentPosition by:(int)amountToDecrease;

- (void)deleteCart;
+ (void)deleteCart:(SBShoppingCart *)cartToDelete;
+ (void)deleteCartWithName:(NSString *)cartName;

- (void)renameCartToNewName:(NSString *)newName;
+ (void)renameCartWithName:(NSString *)cartName toNewName:(NSString *)newName;

- (SBShoppingCart *)cloneCart;
+ (SBShoppingCart *)cloneCart:(SBShoppingCart *)cartToClone;

- (NSArray *)splitCartAtIndex:(int)index;
+ (NSArray *)splitCart:(SBShoppingCart *)cartToSplit atIndex:(int)index;

@end