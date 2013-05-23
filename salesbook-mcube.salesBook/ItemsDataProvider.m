//
//  VariantDataProvider.m
//  SalesBook
//
//  Created by Julian Knab on 25.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemsDataProvider.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

#import "UIImage+ImageWithUIView.h"

@implementation ItemsDataProvider

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBItem *item = [self getItemAtIndexPath:indexPath];
    SBVariant *variant = [item getDefaultVariant];
        
    UIImage *image = [self prepareImageForSmallCardCellAtIndexPath:indexPath withVariant:variant];
    
    return image;
}

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath withVariant:(SBVariant *)variant
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(180,270), NO, [[UIScreen mainScreen] scale]);

    [[UIColor whiteColor] setFill];

    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,180,270)] fill];


    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;

    NSString *redString = [variant price2];

    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};

    [[variant getVisibleDataDetail] enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {

        [[[NSAttributedString alloc] initWithString:[dict objectForKey:@"value"] attributes:attributes] drawInRect:CGRectMake(10, 179 + (idx * 19), 160, 21)];

        *stop = ((idx == 2 && redString.length > 0) || idx > 2);
    }];

    if (redString.length > 0)
    {
        NSDictionary *redAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor redColor], NSParagraphStyleAttributeName : style};
        [[[NSAttributedString alloc] initWithString:redString attributes:redAttributes] drawInRect:CGRectMake(10, 236, 160, 21)];
    }

    [[variant defaultImageWithImageMediaType:SAGMediaTypeMedium] drawInRect:CGRectMake(26, 20, 128, 128)];
    
    [[variant.owningItem renderBaseColorImagesWithMaximumWidthOf:136] drawInRect:CGRectMake(22, 156, 136, 10)];
    
    [[variant.owningItem getSignalLightImage] drawInRect:CGRectMake(84.5, 10, 11, 11)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBItem *item = [self getItemAtIndexPath:indexPath];
    SBVariant *variant = [item getDefaultVariant];
    
    UIImage *image = [self prepareImageForLongRowCellAtIndexPath:indexPath withVariant:variant];
    
    return image;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath withVariant:(SBVariant *)variant
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000,120), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,1000,120)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};

    static int numberOfRows = 4, numberOfCols = 4;

    int numberOfLabelsToPlace = numberOfRows * numberOfCols;
    
    NSArray *arrDetails = [variant getVisibleDataList];
    
    int numberOfStringsInList = arrDetails.count;

    int loopLimit = numberOfStringsInList < numberOfLabelsToPlace ? numberOfStringsInList : numberOfLabelsToPlace;

    static int offsetFront = 120, offsetTop = 10, width = 210, height = 21, spaceX = 10, spaceY = 5;

    int i = 0;

    for (int j = 0; j < numberOfRows && i < loopLimit; j++)
    {
        for (int k = 0; k < numberOfCols && i < loopLimit; k++)
        {
            NSDictionary *dict = arrDetails[i];

            NSString *key = [dict objectForKey:@"label"];
            NSString *value = [dict objectForKey:@"value"];

            int x = offsetFront + j * (width + spaceX);
            int y = offsetTop + k * (height + spaceY);

            [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", key, value] attributes:attributes] drawInRect:CGRectMake(x, y, width, height)];

            i++;
        }
    }
    
    [[variant defaultImageWithImageMediaType:SAGMediaTypeMedium] drawInRect:CGRectMake(26, 28, 64, 64)];
    
    [variant.owningItem.getSignalLightImage drawInRect:CGRectMake(52, 12, 11, 11)];
    
    [[variant.owningItem renderBaseColorImagesWithMaximumWidthOf:80] drawInRect:CGRectMake(18, 97, 80, 10)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (int)displayEntity
{
    return DisplayEntityVariant;
}

@end