//
//  CatalogsAndCartsViewController.m
//  SalesBook
//
//  Created by Julian Knab on 03.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CatalogsAndCartsViewController.h"

#import "NiceLayoutsViewController.h"
#import "ShoppingCartOverviewViewController.h"

#import "DragDropCrane.h"
#import "DragDropCraneDriver.h"

#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"

#import "SBShoppingCart+Extensions.h"

#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "UnderRightViewController.h"

#import "SBVariantMatrix.h"

#import "SBVariantMatrixViewController.h"

#import "SAGAppDelegate.h"

@interface CatalogsAndCartsViewController ()
{
    NiceLayoutsViewController *_niceLayoutsViewController;
    ShoppingCartOverviewViewController *_shoppingCartOverviewViewController;
    
    DragDropCrane *_dragDropCrane;
    SBVariant *_draggingVariant;
}

@end

@implementation CatalogsAndCartsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self deactivateBackButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NiceLayoutsViewController"])
    {
        _niceLayoutsViewController = segue.destinationViewController;
        _niceLayoutsViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ShoppingCartOverviewViewController"])
    {
        _shoppingCartOverviewViewController = segue.destinationViewController;
        _shoppingCartOverviewViewController.delegate = self;
    }
}

- (void)handleDragAndDrop:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (_niceLayoutsViewController.dataProvider.displayEntity != DisplayEntityVariant) return;

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gestureRecognizer locationInView:_niceLayoutsViewController.collectionView];

        NSIndexPath *indexPath = [_niceLayoutsViewController.collectionView indexPathForItemAtPoint:point];

        if (!indexPath)
        {
            return;
        }
        else
        {
            UIView *cell = [_niceLayoutsViewController.collectionView cellForItemAtIndexPath:indexPath];

            SBItem *item = [_niceLayoutsViewController.dataProvider getItemAtIndexPath:indexPath];

            _draggingVariant = [item getDefaultVariant];

            if (!_dragDropCrane)
            {
                _dragDropCrane = [[DragDropCrane alloc] initWithDraggableView:cell andViewsToDropOn:_shoppingCartOverviewViewController.collectionView.visibleCells];
                _dragDropCrane.delegate = self;
            }
            else
            {
                _dragDropCrane = [_dragDropCrane initWithDraggableView:cell andViewsToDropOn:_shoppingCartOverviewViewController.collectionView.visibleCells];
            }
        }
    }

    [_dragDropCrane performSelector:@selector(dragging:) withObject:gestureRecognizer];
}

- (void)dragDropCrane:(DragDropCrane *)dragDropCrane didDropOnView:(UIView *)view
{
    UICollectionViewCell *cell = (UICollectionViewCell *)view;

    NSIndexPath *indexPath = [_shoppingCartOverviewViewController.collectionView indexPathForCell:cell];

    if (!indexPath) return;

    SBShoppingCart *shoppingCart = [_shoppingCartOverviewViewController getCartAtIndexPath:indexPath];

    if (shoppingCart == nil)
    {
        shoppingCart = [SBShoppingCart createNewCart];
    }

//    SBDocumentPosition *docPos = [shoppingCart addItemVariant:_draggingVariant];

    // %< -----

    [SVProgressHUD showWithStatus:@"Lade Matrix..."];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_async(queue, ^(void)
    {
//        SBVariantMatrix *variantMatrix = [self.matrixCache objectForKey:_draggingVariant.owningItem.itemNumber];
//
//        if (!variantMatrix)
//        {
            SBVariantMatrix *variantMatrix = [[SBVariantMatrix alloc] initWithItem:_draggingVariant.owningItem andCart:shoppingCart];
//        }

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        SBVariantMatrixViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VariantMatrix"];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

        vc = [vc initWithMatrix:variantMatrix];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [SVProgressHUD dismiss];
			
			UIViewController *parentController = self.parentViewController;
			[parentController presentViewController:vc
										   animated:YES
										 completion:^{
											 DDLogInfo(@"Present Matrix!");
										 }];

//            SAGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//
//            [appDelegate.window.rootViewController presentViewController:vc animated:YES completion:^{
//
//                DDLogInfo(@"Present Matrix!");
//            }];
        });
    });

    return;

    // ----- >%

    _dragDropCrane = nil;
    _draggingVariant = nil;
}

- (void)illegalDropPerformedByDragDropCrane:(DragDropCrane *)dragDropCrane
{
    NSLog(@"%@ illegal drop!", _draggingVariant.variantNumber);

    _dragDropCrane = nil;
    _draggingVariant = nil;
}

- (IBAction)toggleLayout:(id)sender
{
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;

    int index = segCtrl.selectedSegmentIndex;

    switch (index)
    {
        case LayoutStyleGrid:
            [_niceLayoutsViewController setLayoutStyle:LayoutStyleGrid animated:YES];
            break;
        case LayoutStyleLine:
            [_niceLayoutsViewController setLayoutStyle:LayoutStyleLine animated:YES];
            break;
        case LayoutStyleList:
            [_niceLayoutsViewController setLayoutStyle:LayoutStyleList animated:YES];
            break;
        default:
            break;
    }
}

- (IBAction)btnBackTapped:(id)sender
{
    [_niceLayoutsViewController btnBackTapped];
}

- (IBAction)btnUpTapped:(id)sender
{
    [_niceLayoutsViewController btnUpTapped];
}

- (IBAction)btnDownTapped:(id)sender
{
    [_niceLayoutsViewController btnDownTapped];
}

- (void)activateBackButton
{
    [self.btnBack setEnabled:YES];
}

- (void)deactivateBackButton
{
    [self.btnBack setEnabled:NO];
}

@end