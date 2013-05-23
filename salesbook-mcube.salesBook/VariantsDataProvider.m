//
//  FilteredVariantsDataProvider.m
//  SalesBook
//
//  Created by Julian Knab on 26.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "VariantsDataProvider.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

#import "UIImage+ImageWithUIView.h"

@implementation VariantsDataProvider

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBVariant *variant = [self getItemAtIndexPath:indexPath];

    UIImage *image = [self prepareImageForSmallCardCellAtIndexPath:indexPath withVariant:variant];

    return image;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBVariant *variant = [self getItemAtIndexPath:indexPath];
    
    UIImage *image = [self prepareImageForLongRowCellAtIndexPath:indexPath withVariant:variant];
    
    return image;
}

@end