//
//  GridLayout.m
//  IntroducingCollectionViews
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "ListLayout.h"

@implementation ListLayout

- (id)init
{
    self = [super init];

    if (self)
    {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = (CGSize){1000, 120};
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.headerReferenceSize = (CGSize){0, 0};
        self.footerReferenceSize = (CGSize){0, 0};
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
    }

    return self;
}

//// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
//- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    // call super so flow layout can return default attributes for all cells, headers, and footers
//    NSArray *array = [super layoutAttributesForElementsInRect:rect];
//    
//    // tweak the attributes slightly
//    for (UICollectionViewLayoutAttributes *attributes in array)
//    {
//        attributes.zIndex = 1;
//        /*if (attributes.representedElementCategory != UICollectionElementCategorySupplementaryView || [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
//            attributes.alpha = 0.5;
//        else if (attributes.indexPath.row > 0 || attributes.indexPath.section > 0)
//            attributes.alpha = 0.5; // for single cell closeup*/
//        if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal && attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
//        {
//            // make label vertical if scrolling is horizontal
//            attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
//            attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);            
//        }
////        
////        if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView && [attributes isKindOfClass:[ConferenceLayoutAttributes class]])
////        {
////            ConferenceLayoutAttributes *conferenceAttributes = (ConferenceLayoutAttributes *)attributes;
////            conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
////        }
//    }
//    
////    // Add our decoration views (shelves)
////    NSMutableArray *newArray = [array mutableCopy];
////    
////    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
////        if (CGRectIntersectsRect([obj CGRectValue], rect))
////        {
////            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:key];
////            attributes.frame = [obj CGRectValue];
////            attributes.zIndex = 0;
////            //attributes.alpha = 0.5; // screenshots
////            [newArray addObject:attributes];
////        }
////    }];
////
////    array = [NSArray arrayWithArray:newArray];
//    
//    return array;
//}
//
//// Layout attributes for a specific cell
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
//    attributes.zIndex = 1;
//    return attributes;
//}
//
//// layout attributes for a specific header or footer
//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
////    if ([kind isEqualToString:[SmallConferenceHeader kind]])
//        return nil;
//    
//    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
//    attributes.zIndex = 1;
//    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal)
//    {
//        // make label vertical if scrolling is horizontal
//        attributes.transform3D = CATransform3DMakeRotation(-90 * M_PI / 180, 0, 0, 1);
//        attributes.size = CGSizeMake(attributes.size.height, attributes.size.width);
//    }
//    
////    if ([attributes isKindOfClass:[ConferenceLayoutAttributes class]])
////    {
////        ConferenceLayoutAttributes *conferenceAttributes = (ConferenceLayoutAttributes *)attributes;
////        conferenceAttributes.headerTextAlignment = NSTextAlignmentLeft;
////    }
//    
//   return attributes;
//}
//
//// layout attributes for a specific decoration view
//- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
//{
////    id shelfRect = self.shelfRects[indexPath];
////    if (!shelfRect)
//        return nil; // no shelf at this index (this is probably an error)
//    
////    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[ShelfView kind] withIndexPath:indexPath];
////    attributes.frame = [shelfRect CGRectValue];
////    attributes.zIndex = 0; // shelves go behind other views
////    
////    return attributes;
//}

@end