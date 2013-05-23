//
//  DragDropCraneDelegate.h
//  SalesBook
//
//  Created by Frank Wittmann on 26.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DragDropCrane;

@protocol DragDropCraneDelegate<NSObject>

- (void)handleDragAndDrop:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)dragDropCrane:(DragDropCrane *)dragDropCrane didDropOnView:(UIView *)view;
- (void)illegalDropPerformedByDragDropCrane:(DragDropCrane *)dragDropCrane;

@optional

- (void)activateBackButton;
- (void)deactivateBackButton;

- (UIImage *)provideDraggableImage;

@end
