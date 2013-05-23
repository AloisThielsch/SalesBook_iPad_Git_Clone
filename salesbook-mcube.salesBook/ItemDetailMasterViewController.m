//
//  ItemDetailMasterViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemDetailMasterViewController.h"

#import "SAGObjectSelectionManager.h"

#import "SBItem+Extensions.h"
#import "SBMedia+Extensions.h"

@interface ItemDetailMasterViewController()<ObjectSelectionManagerProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	NSInteger _currentVariantIndex;
	NSInteger _currentMediaFileIndex;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *viewPageControl;
@property (weak, nonatomic) IBOutlet UIPageControl *variantPageControl;

@property (nonatomic, strong) NSArray *variantArray;
@property (nonatomic) NSInteger variantCount;
@property (nonatomic, strong) NSArray *mediaFiles;
@property (nonatomic) NSInteger mediaFileCount;

@property (nonatomic) CGFloat initialZoomScale;
@end

@implementation ItemDetailMasterViewController

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)awakeFromNib
{
	[self commonInit];
}

- (void)commonInit
{
	_currentVariantIndex = 0;
	_currentMediaFileIndex = 0;
}

- (void)setVariant:(SBVariant *)variant
{
	_variantArray = [variant.owningItem getMatrixItemsFor2ndDimension];
	[_variantArray enumerateObjectsUsingBlock:^(SBVariant *obj, NSUInteger idx, BOOL *stop) {
		if ([[obj matrixValueFor2ndDimension] isEqualToString:[variant matrixValueFor2ndDimension]]) {
			_variant = obj;
			_currentVariantIndex = idx;
			*stop = YES;
		}
	}];
	
	_variantCount = [_variantArray count];

	_mediaFiles = [_variant getDownloadedMediaFilesWithImageMediaType:SAGMediaTypeLarge];
	_mediaFileCount = [_mediaFiles count];
	
	_currentMediaFileIndex = MAX(0, MIN(_currentMediaFileIndex, _mediaFileCount));
	
	[self updateUI];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.variantPageControl.transform = CGAffineTransformMakeRotation(M_PI / 2);
	
	[self updateUI];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[SAGObjectSelectionManager sharedManager] addSubscriber:self forEntity:@"SBVariant"];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self adjustScale];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[SAGObjectSelectionManager sharedManager] removeSubscriber:self forEntity:@"SBVariant"];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];

	UIView *imageView = [self.scrollView.subviews objectAtIndex:0];
	imageView.frame = self.scrollView.bounds;
}

- (UIImage *)currentImage
{
	if (_currentMediaFileIndex >= [_mediaFiles count]) {
		return nil;
	}

	SBMedia *mediaFileData = _mediaFiles[_currentMediaFileIndex];
	return [mediaFileData getImage];
}

- (SBVariant *)currentVariant
{
	return self.variant;
}

- (void)updateUI
{
	[self setImage:self.currentImage];
	[self updatePageControls];
}

- (void)adjustScale
{
	UIImage *image = [self currentImage];
	CGSize imageSize = image.size;
	self.scrollView.contentSize = image.size;
	
    CGSize boundsSize = self.scrollView.bounds.size;
	
    CGFloat xScale = boundsSize.width  / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    
    BOOL imagePortrait = imageSize.height > imageSize.width;
    BOOL phonePortrait = boundsSize.height > boundsSize.width;
    CGFloat minScale = imagePortrait == phonePortrait ? xScale : MIN(xScale, yScale);
    
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
	
    if (minScale > maxScale) {
        minScale = maxScale;
    }
	
	//    self.scrollView.maximumZoomScale = maxScale;
	//    self.scrollView.minimumZoomScale = minScale;
	_initialZoomScale = self.scrollView.zoomScale = maxScale;
}

- (void)setImage:(UIImage *)image
{
	UIImageView *imageView = [self.scrollView.subviews objectAtIndex:0];
	imageView.image = image;
	[self adjustScale];
	[self updatePageControls];
}

- (void)updatePageControls
{
	self.variantPageControl.numberOfPages = _variantCount;
	self.viewPageControl.numberOfPages = _mediaFileCount;
	
	CGFloat alpha = [self scrollViewHasInitialScale:self.scrollView] ? 1.0 : 0.0;
	[UIView animateWithDuration:0.25
					 animations:^{
						 self.variantPageControl.alpha = alpha;
						 self.viewPageControl.alpha = alpha;
					 }];
	
	self.variantPageControl.currentPage = _currentVariantIndex;
	self.viewPageControl.currentPage = _currentMediaFileIndex;
	
	self.variantPageControl.hidden = _variantCount <= 1;
	self.viewPageControl.hidden = _mediaFileCount <= 1;
}

- (BOOL)scrollViewHasInitialScale:(UIScrollView *)scrollView
{
	return scrollView.zoomScale == _initialZoomScale;
}

#pragma mark - ObjectSelectionManagerProtocol

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
	SBVariant *variant = (SBVariant *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
	self.variant = variant;
	[self updateUI];
//
//	[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBVariant" withObjectID:variant.objectID];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return [self.scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	[self updatePageControls];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (IBAction)didSwipeLeft:(UISwipeGestureRecognizer *)sender {
	if ([self scrollViewHasInitialScale:self.scrollView]) {
		_currentMediaFileIndex = (_currentMediaFileIndex + 1) == _mediaFileCount ? 0 : _currentMediaFileIndex + 1;
		[self setImage:self.currentImage];
	}
}

- (IBAction)didSwipeRight:(UISwipeGestureRecognizer *)sender {
	if ([self scrollViewHasInitialScale:self.scrollView]) {
		_currentMediaFileIndex = _currentMediaFileIndex == 0 ? (_mediaFileCount - 1) : _currentMediaFileIndex - 1;
		[self setImage:self.currentImage];
	}
}

- (IBAction)didSwipeUp:(UISwipeGestureRecognizer *)sender {
	if ([self scrollViewHasInitialScale:self.scrollView]) {
		_currentVariantIndex = _currentVariantIndex == 0 ? (_variantCount - 1) : _currentVariantIndex - 1;
		self.variant = _variantArray[_currentVariantIndex];
		[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBVariant" withObjectID:self.currentVariant.objectID];
	}
}

- (IBAction)didSwipeDown:(UISwipeGestureRecognizer *)sender {
	if ([self scrollViewHasInitialScale:self.scrollView]) {
		_currentVariantIndex = (_currentVariantIndex + 1) == _variantCount ? 0 : _currentVariantIndex + 1;
		self.variant = _variantArray[_currentVariantIndex];
		[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBVariant" withObjectID:self.currentVariant.objectID];
	}
}

- (IBAction)didDoubleTap:(UITapGestureRecognizer *)sender {
	self.scrollView.zoomScale = _initialZoomScale;

	UIView *imageView = [self.scrollView.subviews objectAtIndex:0];
	imageView.frame = self.scrollView.bounds;
	
	[self updatePageControls];
}

- (IBAction)didLongPress:(UILongPressGestureRecognizer *)sender
{
	[self.delegate handleDragAndDrop:sender];
}

@end
