//
//  DragDropContext.h
//  SalesBook
//
//  Created by Julian Knab on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DragDropCraneDriver : NSObject

- (id)initWithDraggingView:(UIView *)dragView andRestingView:(UIView *)restView;
- (void)putDraggedViewBackToOriginalPosition;

@property (retain, nonatomic) UIView *draggingView;

@end