//
//  ItemGroupsItemGroupsDataProvider.m
//  SalesBook
//
//  Created by Julian Knab on 26.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemGroupsDataProvider.h"

#import "SBItemGroup+Extensions.h"

#import "UIImage+ImageWithUIView.h"

@implementation ItemGroupsDataProvider

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBItemGroup *itemGroup = [self getItemAtIndexPath:indexPath];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(180,270), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,180,270)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    
    [[[NSAttributedString alloc] initWithString:[itemGroup itemGroupDenoation] attributes:attributes] drawInRect:CGRectMake(10, 125, 160, 20)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBItemGroup *itemGroup = [self getItemAtIndexPath:indexPath];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000,120), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,1000,120)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    
    [[[NSAttributedString alloc] initWithString:[itemGroup itemGroupDenoation] attributes:attributes] drawInRect:CGRectMake(30, 50, 200, 20)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)doesRequireToDrillDown:(SBItemGroup *)itemGroup
{
    return itemGroup.subGroups.count > 0;
}

- (int)displayEntity
{
    return DisplayEntityItemGroup;
}

@end