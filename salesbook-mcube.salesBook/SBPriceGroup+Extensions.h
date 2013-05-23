//
//  SBPriceGroup+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 11.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBPriceGroup.h"

@interface SBPriceGroup (Extensions)

+ (SBPriceGroup *)getPriceGroupWithPriceGroupNumber:(NSString *)priceGroupNumber;

+ (bool)existsPriceGroupWithPriceGroupNumber:(NSString *)priceGroupNumber;

@end
