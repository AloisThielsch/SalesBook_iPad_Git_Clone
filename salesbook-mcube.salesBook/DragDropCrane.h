//
//  DragDropCrane.h
//  SalesBook
//
//  Created by Julian Knab on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DragDropCraneDelegate.h"

@class SBVariant;

@interface DragDropCrane : NSObject

@property (nonatomic, assign) id<DragDropCraneDelegate> delegate;

- (id)initWithDraggableView:(UIView *)draggableView andViewsToDropOn:(NSArray *)viewsToDropOn;
- (id)initWithDraggableView:(UIView *)draggableView referenceView:(UIView *)referenceView andViewsToDropOn:(NSArray *)viewsToDropOn;

@end