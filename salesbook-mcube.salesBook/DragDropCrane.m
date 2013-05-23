//
//  DragDropCrane.m
//  SalesBook
//
//  Created by Julian Knab on 14.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "DragDropCrane.h"
#import "DragDropCraneDriver.h"

#import "UIImage+ImageWithUIView.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

#import "CatalogsAndCartsViewController.h"

#import "SAGAppDelegate.h"

@implementation DragDropCrane
{
    UIView * _dragView;
	UIView *_referenceView;
    NSMutableArray * _dropViews;
    DragDropCraneDriver * _craneDriver;
//    CatalogsAndCartsViewController __unsafe_unretained * _delegate;
}

- (id)initWithDraggableView:(UIView *)draggableView andViewsToDropOn:(NSArray *)viewsToDropOn
{
    self = [super init];
    
    if (self)
    {
        _dragView = draggableView;
        _dropViews = [NSMutableArray arrayWithArray:viewsToDropOn];

        _craneDriver = nil;
    }
    
    return self;
}

- (id)initWithDraggableView:(UIView *)draggableView referenceView:(UIView *)referenceView andViewsToDropOn:(NSArray *)viewsToDropOn
{
	self = [self initWithDraggableView:draggableView andViewsToDropOn:viewsToDropOn];

	if (self) {
		_referenceView = referenceView;
	}
	
	return self;
}

- (void)dragObjectAccordingToGesture:(UIPanGestureRecognizer *)recognizer
{
    if (_craneDriver)
    {
		CGPoint pointInView;
		
		pointInView = [recognizer locationInView:recognizer.view];
		if (_referenceView) {
			pointInView = [_referenceView convertPoint:pointInView fromView:recognizer.view];
		}
		
        _craneDriver.draggingView.center = pointInView;
    }
}

- (void)dragging:(id)sender
{
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;

    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint pointInView = [recognizer locationInView:_dragView];

            BOOL pointInsideDragView = [_dragView pointInside:pointInView withEvent:nil];

            if (pointInsideDragView)
            {
				UIImageView *imgView;
				
				if ([self.delegate respondsToSelector:@selector(provideDraggableImage)]) {
					imgView = [[UIImageView alloc] initWithImage:[self.delegate provideDraggableImage]];
					imgView.alpha = 0.8f;
				} else {
					imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithUIView:_dragView alpha:0.8f]];
				}

                _craneDriver = [[DragDropCraneDriver alloc] initWithDraggingView:imgView andRestingView:_dragView];
				
				//TODO: view translation untersuchen!
                [recognizer.view.superview.superview.superview addSubview:imgView];

                [self dragObjectAccordingToGesture:recognizer];
            }

            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            [self dragObjectAccordingToGesture:recognizer];

            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (_craneDriver)
            {
                UIView *dragView = _craneDriver.draggingView;
                
                BOOL dropInViewAllowed = NO;
                
                for (UIView *dropView in _dropViews)
                {
                    CGPoint pointInDropView = [recognizer locationInView:dropView];

                    if ([dropView pointInside:pointInDropView withEvent:nil])
                    {
                        dropInViewAllowed = YES;

                        [dragView removeFromSuperview];

//                        CatalogsAndCartsViewController *delegate = _delegate;
                        
                        [self.delegate dragDropCrane:self didDropOnView:dropView];
                    }
                }
                
                if (!dropInViewAllowed)
                {
                    [_craneDriver putDraggedViewBackToOriginalPosition];

//                    CatalogsAndCartsViewController *delegate = _delegate;
//                    
                    [self.delegate illegalDropPerformedByDragDropCrane:self];
                }

                _craneDriver = nil;
            }

            break;
        }
        
        default:
        {
            break;
        }
    }  
}

@end