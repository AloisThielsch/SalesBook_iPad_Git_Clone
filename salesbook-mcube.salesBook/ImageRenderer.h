//
//  ImageRenderer.h
//  SalesBook
//
//  Created by Andreas Kucher on 11.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SBVariant+Extensions.h"

enum ImageRendererCellType {
    ImageRendererCellTypeSmallCell = 0,
    ImageRendererCellTypeLongCell = 1
};

@protocol ImageRendererDelegate;

@interface ImageRenderer : NSOperation

@property (nonatomic, assign) id <ImageRendererDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly, strong) UIImage *image;
@property (nonatomic, readonly, strong) SBVariant *variant;
@property (nonatomic, readonly, strong) UICollectionView *collectionView;
@property (nonatomic, readonly) enum ImageRendererCellType rendererType;

- (id)initWithVariant:(SBVariant *)variant withImageRendererType:(enum ImageRendererCellType)rendererType atIndexPath:(NSIndexPath *)indexPath inCollectionView:(UICollectionView *)collectionView delegate:(id<ImageRendererDelegate>) theDelegate;

@end

@protocol ImageRendererDelegate <NSObject>

- (void)imageRendererDidFinish:(ImageRenderer *)renderer;

@end
