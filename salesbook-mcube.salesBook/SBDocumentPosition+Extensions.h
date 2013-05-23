//
//  SBDocumentPosition+Extensions.h
//  SalesBook
//
//  Created by Julian Knab on 11.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBDocumentPosition.h"

#import "SBShoppingCart+Extensions.h"

@interface SBDocumentPosition (Extensions)

- (SBDocumentPosition *)clonePosition;
+ (SBDocumentPosition *)clonePosition:(SBDocumentPosition *)positionToClone;

+ (SBDocumentPosition *)getDocumentPositionForItemVariant:(SBVariant *)itemVariant andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom;
+ (SBDocumentPosition *)getDocumentPositionForItemVariantWithNumber:(NSString *)variantNumber andDeliveryDate:(NSDate *)deliveryDate fromCart:(SBShoppingCart *)cartToGetFrom;

- (void)setAmountWithInt:(int)amount;

- (double)getSinglePiecePrice;
- (double)getSinglePiecePriceWithRebate;
- (double)getTotalPrice;

@end