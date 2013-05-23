//
//  ImageRenderer.m
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ImageRenderer.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

@interface ImageRenderer ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPath;
@property (nonatomic, readwrite, strong) SBVariant *variant;
@property (nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, strong) UICollectionView *collectionView;
@property (nonatomic, readwrite) enum ImageRendererCellType rendererType;

@end

@implementation ImageRenderer

- (id)initWithVariant:(SBVariant *)variant withImageRendererType:(enum ImageRendererCellType)rendererType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView delegate:(id<ImageRendererDelegate>)theDelegate
{
    if (self = [super init])
    {
        self.delegate = theDelegate;
        self.variant = variant;
        self.rendererType = rendererType;
        self.image = nil;
        self.indexPath = indexPath;
        self.collectionView = collectionView;
        self.threadPriority = NSOperationQueuePriorityVeryHigh;
    }
    
    return self;
}

- (void)main
{
    @autoreleasepool
    {
        if (self.isCancelled)
            return;
        
        UIImage *image = [self prepareImageWithVariant:self.variant];
  
        if (self.isCancelled)
        {
            image = nil;
            return;
        }
        
        if (image)
        {
            self.image = image;
        }
        
        image = nil;
        
        if (self.isCancelled)
            return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageRendererDidFinish:) withObject:self waitUntilDone:NO];
    }
}

- (UIImage *)prepareImageWithVariant:(SBVariant *)variant
{
    if (variant == nil)
    {
        return nil;
    }
    
    switch (self.rendererType)
    {
        case ImageRendererCellTypeSmallCell:
            return [self prepareImageForSmallCardCellWithVariant:variant];
            break;
        case ImageRendererCellTypeLongCell:
            return [self prepareImageForLongRowCellWithVariant:variant];
            break;
        default:
            break;
    }
    
    return nil;
}

- (UIImage *)prepareImageForSmallCardCellWithVariant:(SBVariant *)variant
{

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(180,270), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,180,270)] fill];
    
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *redAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor redColor], NSParagraphStyleAttributeName : style};
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    
    NSString *priceString = [variant price2]; //Wenn es einen Rotpreis gibt, wird
    
    if (priceString.length == 0)
    {
        redAttributes = attributes; //Kein Rotpreis, daher auch keine rote Schrift.
        priceString = [variant price];
    }
    
    NSArray *visibleData = [variant getVisibleDataDetail];
    
    [visibleData enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop)
    {
        [[[NSAttributedString alloc] initWithString:[dict objectForKey:@"value"] attributes:attributes] drawInRect:CGRectMake(10, 179 + (idx * 19), 160, 21)];
        
        *stop = ((idx == 2 && priceString.length > 0) || idx > 2);
    }];
    
    if (visibleData.count == 0) ///Fallback falls keine Varianten da sind!
    {
        [[[NSAttributedString alloc] initWithString:variant.variantNumber attributes:attributes] drawInRect:CGRectMake(10, 179, 160, 21)];
    }
    
    if (priceString.length > 0) //Wenn es einen Preis gibt wird der aufgedruckt!
    {
        [[[NSAttributedString alloc] initWithString:priceString attributes:redAttributes] drawInRect:CGRectMake(10, 236, 160, 21)];
    }
    
    UIImage *variantImage = [variant defaultImageWithImageMediaType:SAGMediaTypeMedium];
    
    if (variantImage == nil)
    {
        variantImage = [UIImage imageNamed:@"image.png"];
    }
    
    [variantImage drawInRect:CGRectMake(26, 20, 128, 128)];
    
    [[variant.owningItem renderBaseColorImagesWithMaximumWidthOf:136] drawInRect:CGRectMake(22, 156, 136, 10)];
    
    [[variant.owningItem getSignalLightImage] drawInRect:CGRectMake(84.5, 10, 11, 11)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)prepareImageForLongRowCellWithVariant:(SBVariant *)variant
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1000,120), NO, [[UIScreen mainScreen] scale]);
    
    [[UIColor whiteColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:CGRectMake(0,0,1000,120)] fill];
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : style};
    NSDictionary *redAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName : [UIColor redColor], NSParagraphStyleAttributeName : style};
    
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
            
            NSDictionary *render = attributes;
            
            if ([[dict valueForKey:@"uniqueID"] isEqualToString:@"SBVariant.price2"]) render = redAttributes; //Der Preis2 ist bei uns ein Rotpreis
            
            [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", key, value] attributes:render] drawInRect:CGRectMake(x, y, width, height)];
            
            i++;
        }
    }
    
    if (arrDetails.count == 0) ///Fallback falls keine Varianten da sind!
    {
        [[[NSAttributedString alloc] initWithString:variant.variantNumber attributes:attributes] drawInRect:CGRectMake(120, 10, width, height)];
    }
    
    UIImage *variantImage = [variant defaultImageWithImageMediaType:SAGMediaTypeMedium];
    
    if (variantImage == nil)
    {
        variantImage = [UIImage imageNamed:@"image.png"];
    }
    
    [variantImage drawInRect:CGRectMake(26, 28, 64, 64)];
    
    [variant.owningItem.getSignalLightImage drawInRect:CGRectMake(52, 12, 11, 11)];
    
    [[variant.owningItem renderBaseColorImagesWithMaximumWidthOf:80] drawInRect:CGRectMake(18, 97, 80, 10)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
