//
//  ItemDetailViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemDetailViewController.h"

#import "SAGAppDelegate.h"
#import "SAGSettingsManager.h"

#import "ItemDetailVariantViewController.h"
#import "ItemDetailMasterViewController.h"
#import "ItemDetailAttributesViewController.h"
#import "ShoppingCartOverviewViewController.h"
#import "SBVariantMatrixViewController.h"
#import "NiceLayoutsViewController.h"

#import "SBShoppingCart+Extensions.h"
#import "SBItem+Extensions.h"
#import "SBVariant+Extensions.h"
#import "SBVariantMatrix.h"

#import "UIView+FrameCalculations.h"

#import "DragDropCrane.h"

const CGFloat kDrawerHandleWidth = 80.0;
const CGFloat kDrawerHandleHeight = 30.0;

typedef enum {
	DrawerStatusUnknown,
	DrawerStatusOpen,
	DrawerStatusClosed
} DrawerStatus;

@interface ItemDetailViewController() {
	CGFloat variantViewWidth;
	CGFloat attributeViewWidth;
	CGFloat cartHeight;
	
	UIButton *_variantsHandle;
	UIButton *_attributesHandle;
	DrawerStatus _variantDrawerStatus;
	DrawerStatus _attributeDrawerStatus;
	DrawerStatus _cartDrawerStatus;

    DragDropCrane *_dragDropCrane;
    SBVariant *_draggingVariant;
}

@property (nonatomic, weak) ItemDetailVariantViewController *variantViewController;
@property (nonatomic, weak) ItemDetailMasterViewController *masterViewController;
@property (nonatomic, weak) ItemDetailAttributesViewController *attributesViewController;
@property (nonatomic, weak) ShoppingCartOverviewViewController *cartViewController;

@property (nonatomic, strong) NSArray *variantArray;

@property (weak, nonatomic) IBOutlet UIView *variantsContainer;
@property (weak, nonatomic) IBOutlet UIView *masterContainer;
@property (weak, nonatomic) IBOutlet UIView *attributesContainer;
@property (weak, nonatomic) IBOutlet UIView *cartContainer;

@end

@implementation ItemDetailViewController

+ (ItemDetailViewController *)itemDetailViewController
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ItemDetail" bundle:nil];
	return (ItemDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ItemDetail"];
}

- (void)setVariant:(SBVariant *)variant
{
	_variantArray = [variant.owningItem getMatrixItemsFor2ndDimension];
	[_variantArray enumerateObjectsUsingBlock:^(SBVariant *obj, NSUInteger idx, BOOL *stop) {
		if ([[obj matrixValueFor2ndDimension] isEqualToString:[variant matrixValueFor2ndDimension]]) {
			_variant = obj;
			*stop = YES;
		}
	}];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"embedVariant"]) {
		self.variantViewController = segue.destinationViewController;
		self.variantViewController.variant = self.variant;
	} else if ([segue.identifier isEqualToString:@"embedMaster"]) {
		self.masterViewController = segue.destinationViewController;
		self.masterViewController.variant = self.variant;
		self.masterViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:@"embedAttributes"]) {
		self.attributesViewController = segue.destinationViewController;
		self.attributesViewController.variant = self.variant;
	} else if ([segue.identifier isEqualToString:@"embedCart"]) {
		self.cartViewController = segue.destinationViewController;
	}
}

- (void)viewDidLoad {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
	_cartViewController = [storyboard instantiateViewControllerWithIdentifier:@"ShoppingCartOverview"];
	[self addChildViewController:_cartViewController];
	[self.cartContainer addSubview:_cartViewController.view];
	_cartViewController.view.frame = self.cartContainer.bounds;
	
	_variantDrawerStatus = _attributeDrawerStatus = _cartDrawerStatus = DrawerStatusOpen;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	variantViewWidth = self.variantsContainer.$width;
	attributeViewWidth = self.attributesContainer.$width;
	cartHeight = self.cartContainer.$height;
	
	[self hideCartAnimated:NO];
	
	if (!_variantsHandle) {
		CGRect rectFrame = self.masterContainer.bounds;
		_variantsHandle = [UIButton buttonWithType:UIButtonTypeCustom];
		_variantsHandle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[_variantsHandle addTarget:self action:@selector(toggleVariantView:) forControlEvents:UIControlEventTouchUpInside];
		_variantsHandle.frame = CGRectMake(rectFrame.origin.x, (rectFrame.size.height / 2) - (kDrawerHandleWidth / 2), kDrawerHandleHeight, kDrawerHandleWidth);
		_variantsHandle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"drawer_handle.png"]];
		[self.masterContainer addSubview:_variantsHandle];
	}

	if (!_attributesHandle) {
		CGRect rectFrame = self.masterContainer.frame;
		_attributesHandle = [UIButton buttonWithType:UIButtonTypeCustom];
		_attributesHandle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[_attributesHandle addTarget:self action:@selector(toggleAttributeView:) forControlEvents:UIControlEventTouchUpInside];
		_attributesHandle.frame = CGRectMake(rectFrame.size.width - kDrawerHandleHeight, (rectFrame.size.height / 2) - (kDrawerHandleWidth / 2), kDrawerHandleHeight, kDrawerHandleWidth);
		_attributesHandle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"drawer_handle.png"]];
		_attributesHandle.transform = CGAffineTransformMakeRotation(M_PI);
		[self.masterContainer addSubview:_attributesHandle];
	}

	BOOL showVariantsDrawer = [[[SAGSettingsManager sharedManager] settingForKey:@"itemDetailViewShowVariantsDrawer" withDefaultValue:@YES] boolValue];
	if (showVariantsDrawer) {
		[self showVariants];
	} else {
		[self hideVariantsAnimated:NO];
	}
	
	BOOL showAttributesDrawer = [[[SAGSettingsManager sharedManager] settingForKey:@"itemDetailViewShowAttributesDrawer" withDefaultValue:@YES] boolValue];
	if (showAttributesDrawer) {
		[self showAttributes];
	} else {
		[self hideAttributesAnimated:NO];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[[SAGSettingsManager sharedManager] setSetting:_variantDrawerStatus == DrawerStatusOpen ? @YES : @NO forKey:@"itemDetailViewShowVariantsDrawer"];
	[[SAGSettingsManager sharedManager] setSetting:_attributeDrawerStatus == DrawerStatusOpen ? @YES : @NO forKey:@"itemDetailViewShowAttributesDrawer"];
}

- (IBAction)toggleVariantView:(id)sender
{
	if (_variantDrawerStatus == DrawerStatusClosed) {
		[self showVariants];
	} else {
		[self hideVariantsAnimated:YES];
	}
}

- (IBAction)toggleAttributeView:(id)sender
{
	if (_attributeDrawerStatus == DrawerStatusClosed) {
		[self showAttributes];
	} else {
		[self hideAttributesAnimated:YES];
	}
}

- (IBAction)close:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showVariants
{
	if (_variantDrawerStatus != DrawerStatusOpen) {
		_variantDrawerStatus = DrawerStatusOpen;
		
		CGRect rectMaster = self.masterContainer.frame;
		CGRect rectVariants = self.variantsContainer.frame;
		
		rectMaster.size.width -= variantViewWidth;
		rectMaster.origin.x = variantViewWidth;
		rectVariants.origin.x = 0;
		
		[UIView animateWithDuration:0.25
						 animations:^{
							 self.masterContainer.frame = rectMaster;
							 self.variantsContainer.frame = rectVariants;
						 }];
	}
}

- (void)hideVariantsAnimated:(BOOL)animated
{
	if (_variantDrawerStatus != DrawerStatusClosed) {
		CGRect rectMaster = self.masterContainer.frame;
		CGRect rectVariants = self.variantsContainer.frame;
		
		rectMaster.size.width += variantViewWidth;
		rectMaster.origin.x = 0;
		rectVariants.origin.x -= variantViewWidth;
		
		if (animated) {
			[UIView animateWithDuration:0.25
							 animations:^{
								 self.masterContainer.frame = rectMaster;
								 self.variantsContainer.frame = rectVariants;
							 }
							 completion:^(BOOL finished) {
								 _variantDrawerStatus = DrawerStatusClosed;
							 }];
		} else {
			self.masterContainer.frame = rectMaster;
			self.variantsContainer.frame = rectVariants;
			_variantDrawerStatus = DrawerStatusClosed;
		}
	}
}

- (void)showAttributes
{
	if (_attributeDrawerStatus != DrawerStatusOpen) {
		_attributeDrawerStatus = DrawerStatusOpen;
		
		CGRect rectMaster = self.masterContainer.frame;
		CGRect rectAttributes = self.attributesContainer.frame;
		
		rectMaster.size.width -= attributeViewWidth;
		rectAttributes.origin.x -= attributeViewWidth;
		
		[UIView animateWithDuration:0.25
						 animations:^{
							 self.masterContainer.frame = rectMaster;
							 self.attributesContainer.frame = rectAttributes;
						 }];
	}
}

- (void)hideAttributesAnimated:(BOOL)animated
{
	if (_attributeDrawerStatus != DrawerStatusClosed) {
		CGRect rectMaster = self.masterContainer.frame;
		CGRect rectAttributes = self.attributesContainer.frame;
		
		rectMaster.size.width += attributeViewWidth;
		rectAttributes.origin.x += attributeViewWidth;
		
		if (animated) {
			[UIView animateWithDuration:0.25
							 animations:^{
								 self.masterContainer.frame = rectMaster;
								 self.attributesContainer.frame = rectAttributes;
							 }
							 completion:^(BOOL finished) {
								 _attributeDrawerStatus = DrawerStatusClosed;
							 }];
		} else {
			self.masterContainer.frame = rectMaster;
			self.attributesContainer.frame = rectAttributes;
			_attributeDrawerStatus = DrawerStatusClosed;
		}
	}
}

- (void)showCart
{
	if (_cartDrawerStatus != DrawerStatusOpen) {
		_cartDrawerStatus = DrawerStatusOpen;
		[UIView animateWithDuration:0.25
						 animations:^{
							 self.cartContainer.$y -= cartHeight;
						 }];
	}
}

- (void)hideCartAnimated:(BOOL)animated
{
	if (_cartDrawerStatus != DrawerStatusClosed) {
		if (animated) {
			[UIView animateWithDuration:0.25
							 animations:^{
								 self.cartContainer.$y += cartHeight;
							 }
							 completion:^(BOOL finished) {
								 _cartDrawerStatus = DrawerStatusClosed;
							 }];
		} else {
			self.cartContainer.$y += cartHeight;
			_cartDrawerStatus = DrawerStatusClosed;
		}
	}
}

#pragma mark - DragDropCraneDelegate

- (void)handleDragAndDrop:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		[self showCart];
		
		_draggingVariant = [self.masterViewController currentVariant];
		if (!_dragDropCrane)
		{
			_dragDropCrane = [[DragDropCrane alloc] initWithDraggableView:[self.masterContainer.subviews objectAtIndex:0]
															referenceView:self.masterContainer.superview
														 andViewsToDropOn:self.cartViewController.collectionView.visibleCells];
			_dragDropCrane.delegate = self;
		}
		else
		{
			_dragDropCrane = [_dragDropCrane initWithDraggableView:[self.masterContainer.subviews objectAtIndex:0]
													 referenceView:self.masterContainer
												  andViewsToDropOn:self.cartViewController.collectionView.visibleCells];
		}
    }
	
    [_dragDropCrane performSelector:@selector(dragging:) withObject:gestureRecognizer];
}

- (void)dragDropCrane:(DragDropCrane *)dragDropCrane didDropOnView:(UIView *)view
{
	[self hideCartAnimated:YES];
	
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
	
    NSIndexPath *indexPath = [self.cartViewController.collectionView indexPathForCell:cell];
	
    if (!indexPath) return;
	
    SBShoppingCart *shoppingCart = [self.cartViewController getCartAtIndexPath:indexPath];
	
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
					   
//					   vc = [vc initWithMatrix:variantMatrix];
					   vc = [vc initWithMatrix:variantMatrix variant:_draggingVariant];
					   
					   dispatch_async(dispatch_get_main_queue(), ^(void)
									  {
										  [SVProgressHUD dismiss];
										  
										  UIViewController *parentController = self;
										  [parentController presentViewController:vc
																		 animated:YES
																	   completion:^{
																		   DDLogInfo(@"Present Matrix!");
																	   }];

//										  SAGAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//										  
//										  [appDelegate.window.rootViewController presentViewController:vc animated:YES completion:^{
//											  
//											  DDLogInfo(@"Present Matrix!");
//										  }];
									  });
				   });
	
    return;
	
    // ----- >%
	
    _dragDropCrane = nil;
    _draggingVariant = nil;
}

- (void)illegalDropPerformedByDragDropCrane:(DragDropCrane *)dragDropCrane
{
	[self hideCartAnimated:YES];

    _dragDropCrane = nil;
    _draggingVariant = nil;
}

- (UIImage *)provideDraggableImage
{
	return [_draggingVariant defaultImageWithImageMediaType:SAGMediaTypeMedium];
}

@end
