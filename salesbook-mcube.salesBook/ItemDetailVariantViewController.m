//
//  ItemDetailVariantViewController.m
//  SalesBook
//
//  Created by Frank Wittmann on 22.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "ItemDetailVariantViewController.h"
#import "ItemDetailVariantCell.h"

#import "SAGObjectSelectionManager.h"

#import "SBItem+Extensions.h"

@interface ItemDetailVariantViewController()<ObjectSelectionManagerProtocol>
@property (nonatomic, strong) NSArray *variantArray;
@end

@implementation ItemDetailVariantViewController

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

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[SAGObjectSelectionManager sharedManager] addSubscriber:self forEntity:@"SBVariant"];
	
	if (self.variant) {
		[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[_variantArray indexOfObject:self.variant] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionTop];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[SAGObjectSelectionManager sharedManager] removeSubscriber:self forEntity:@"SBVariant"];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.variantArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	ItemDetailVariantCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemDetailVariantCell" forIndexPath:indexPath];
	SBVariant *variant = [self.variantArray objectAtIndex:indexPath.item];
	
	UIImage *previewImage = [variant defaultImageWithImageMediaType:SAGMediaTypeMedium];
	cell.previewImage.image = previewImage;

	UIView *bgView = [[UIView alloc] init];
	bgView.backgroundColor = [UIColor orangeColor];
	cell.selectedBackgroundView = bgView;
	
	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	self.variant = [self.variantArray objectAtIndex:indexPath.item];
	
	[[SAGObjectSelectionManager sharedManager] broadcastSelectionOfEntity:@"SBVariant" withObjectID:self.variant.objectID];
}

#pragma mark - ObjectSelectionManagerProtocol

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
	SBVariant *variant = (SBVariant *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
	NSInteger row = [self.variantArray indexOfObject:variant];
	[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

@end
