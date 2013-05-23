//
//  DragDropContext.m
//  SalesBook
//
//  Created by Julian Knab on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DragDropCraneDriver.h"

@implementation DragDropCraneDriver
{
    UIView * _draggingView;
    UIView * _originalView;
    
    CGPoint _originalPosition;
}

@synthesize draggingView = _draggingView;

- (id)initWithDraggingView:(UIView *)dragView andRestingView:(UIView *)restView
{
    self = [super init];

    if (self)
    {
        _draggingView = dragView;
        _originalView = restView.superview;

        _originalPosition = restView.frame.origin;
    }
    
    return self;
}

- (void)putDraggedViewBackToOriginalPosition;
{
    [UIView animateWithDuration:0.3
    
    animations:^()
    {
        CGPoint originalPointInSuperView = [_draggingView.superview convertPoint:_originalPosition fromView:_originalView];

        _draggingView.frame = CGRectMake(originalPointInSuperView.x, originalPointInSuperView.y, _draggingView.frame.size.width, _draggingView.frame.size.height);
    }
    completion:^(BOOL finished)
    {
        _draggingView.frame = CGRectMake(_originalPosition.x, _originalPosition.y, _draggingView.frame.size.width, _draggingView.frame.size.height);

        [_draggingView removeFromSuperview];
    }];
}

@end