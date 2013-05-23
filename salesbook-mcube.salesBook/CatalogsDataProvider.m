//
//  CatalogDataProvider.m
//  SalesBook
//
//  Created by Julian Knab on 21.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CatalogsDataProvider.h"

#import "SBCatalog+Extensions.h"

#import "UIImage+ImageWithUIView.h"

@implementation CatalogsDataProvider

- (UIImage *)prepareImageForSmallCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBCatalog *catalog = [self getItemAtIndexPath:indexPath];

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(180,270), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,180,270)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    
    [[[NSAttributedString alloc] initWithString:[catalog catalogDenoation] attributes:attributes] drawInRect:CGRectMake(10, 125, 160, 20)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)prepareImageForLongRowCellAtIndexPath:(NSIndexPath *)indexPath
{
    SBCatalog *catalog = [self getItemAtIndexPath:indexPath];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000,120), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,1000,120)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    
    [[[NSAttributedString alloc] initWithString:[catalog catalogDenoation] attributes:attributes] drawInRect:CGRectMake(30, 50, 200, 20)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)doesRequireToDrillDown:(SBCatalog *)catalog
{
    BOOL drillSetting = [[[SAGSettingsManager sharedManager] settingForKey:@"shouldItemGroupsDrillDown" withDefaultValue:[NSNumber numberWithBool:NO]] boolValue];

    if (drillSetting && catalog.itemGroups.count > 0)
    {
        return YES;
    }

    return NO;
}

- (int)displayEntity
{
    return DisplayEntityCatalog;
}

@end