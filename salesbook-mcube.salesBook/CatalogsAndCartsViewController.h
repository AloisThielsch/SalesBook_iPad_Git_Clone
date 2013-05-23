//
//  CatalogsAndCartsViewController.h
//  SalesBook
//
//  Created by Julian Knab on 03.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DragDropCraneDelegate.h"

@class DragDropCrane;

@interface CatalogsAndCartsViewController : UIViewController<DragDropCraneDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *segCtrl;

//- (void)handleDragAndDrop:(UILongPressGestureRecognizer *)gestureRecognizer;
//
//- (void)dragDropCrane:(DragDropCrane *)dragDropCrane didDropOnView:(UIView *)view;
//- (void)illegalDropPerformedByDragDropCrane:(DragDropCrane *)dragDropCrane;

- (IBAction)revealMenu:(id)sender;

- (IBAction)toggleLayout:(id)sender;

- (IBAction)btnBackTapped:(id)sender;
- (IBAction)btnUpTapped:(id)sender;
- (IBAction)btnDownTapped:(id)sender;

//- (void)activateBackButton;
//- (void)deactivateBackButton;

@end