//
//  ViewController.m
//  IntroducingCollectionViews
//
//  Created by Mark Pospesel on 10/4/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "NiceLayoutsViewController.h"

#import "GridLayout.h"
#import "LineLayout.h"
#import "ListLayout.h"

#import "SBCatalog+Extensions.h"
#import "SBItem+Extensions.h"
#import "SBItemGroup+Extensions.h"
#import "SBVariant+Extensions.h"

#import "CatalogsDataProvider.h"
#import "ItemGroupsDataProvider.h"
#import "ItemsDataProvider.h"
#import "VariantsDataProvider.h"

#import "ItemDetailViewController.h"

@interface NiceLayoutsViewController () <UICollectionViewDelegate>
{
    CollectionViewDataProvider __unsafe_unretained * _dataProvider;
    NSMutableArray * _dataProviders;
}

@property (nonatomic, assign) LayoutStyle layoutStyle;

@end

@implementation NiceLayoutsViewController

@synthesize dataProvider = _dataProvider, delegate;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    _dataProviders = [NSMutableArray new];

    _layoutStyle = LayoutStyleGrid;

    NSArray *catalogs = [SBCatalog MR_findAll];

    CatalogsDataProvider *dp = [[CatalogsDataProvider alloc] initWithItems:catalogs andSortIdentifier:@"catalogNumber"];
    dp.layoutStyle = _layoutStyle;

    [_dataProviders addObject:dp];
    
    _dataProvider = dp;
}

- (void)viewDidLoad
{
    [self.collectionView setCollectionViewLayout:[[GridLayout alloc] init]];

    [self.collectionView setDataSource:_dataProvider];

    [self.collectionView setDelegate:_dataProvider];
    
    [super viewDidLoad];

    [self.collectionView reloadData];

    self.collectionView.backgroundColor = [UIColor grayColor];
     
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setLayoutStyle:(LayoutStyle)layoutStyle animated:(BOOL)animated
{
    if (layoutStyle == self.layoutStyle) return;

    UICollectionViewLayout *newLayout = nil;

    switch (layoutStyle)
    {
        case LayoutStyleGrid:
            newLayout = [[GridLayout alloc] init];
            break;
            
        case LayoutStyleLine:
            newLayout = [[LineLayout alloc] init];
            break;

        case LayoutStyleList:
            newLayout = [[ListLayout alloc] init];
            break;

        default:
            break;
    }

    if (!newLayout) return;

    self.layoutStyle = layoutStyle;
    self.dataProvider.layoutStyle = layoutStyle;

    [self.collectionView setCollectionViewLayout:newLayout animated:animated];

    [self.collectionView.collectionViewLayout performSelector:@selector(invalidateLayout) withObject:nil afterDelay:0.4];

    NSArray *cRappleHasTheMostStupidNamesForMethodsAndVariablesAndClassesAndEverything = [self.collectionView indexPathsForVisibleItems];

    [self.collectionView reloadItemsAtIndexPaths:cRappleHasTheMostStupidNamesForMethodsAndVariablesAndClassesAndEverything];
    
    //TODO: scroll up/down. helps to adjust the scollview. pfff
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];

        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];

        if (indexPath)
        {
            int entity = [_dataProvider displayEntity];

            switch (entity)
            {
                case DisplayEntityCatalog:
                {
                    [self handleTapOnCatalogAtIndexPath:indexPath];
                    break;
                }
                case DisplayEntityItemGroup:
                {
                    [self handleTapOnItemGroupAtIndexPath:indexPath];
                    break;
                }
                case DisplayEntityVariant:
                {
                    [self handleTapOnVariantAtIndexPath:indexPath];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)handleTapOnCatalogAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogsDataProvider *currDataProvider = (CatalogsDataProvider *)_dataProvider;

    SBCatalog *catalog = [currDataProvider getItemAtIndexPath:indexPath];

    CollectionViewDataProvider *nextDataProvider;

    if ([currDataProvider doesRequireToDrillDown:catalog])
    {
        NSArray *itemGroups = catalog.itemGroups.allObjects;
        nextDataProvider = [[ItemGroupsDataProvider alloc] initWithItems:itemGroups andSortIdentifier:@"itemGroupNumber"];
        nextDataProvider.layoutStyle = _layoutStyle;
    }
    else
    {
        NSArray *items = catalog.items.allObjects;
        nextDataProvider = [[ItemsDataProvider alloc] initWithItems:items andSortIdentifier:@"itemNumber"];
        nextDataProvider.layoutStyle = _layoutStyle;
    }

    [self pushDataProvider:nextDataProvider];
}

- (void)handleTapOnItemGroupAtIndexPath:(NSIndexPath *)indexPath
{
    ItemGroupsDataProvider *currDataProvider = (ItemGroupsDataProvider *)_dataProvider;

    SBItemGroup *itemGroup = [currDataProvider getItemAtIndexPath:indexPath];

    CollectionViewDataProvider *nextDataProvider;
    
    if ([currDataProvider doesRequireToDrillDown:itemGroup])
    {
        NSArray *itemGroups = itemGroup.subGroups.allObjects;
        nextDataProvider = [[ItemGroupsDataProvider alloc] initWithItems:itemGroups andSortIdentifier:@"itemGroupNumber"];
        nextDataProvider.layoutStyle = _layoutStyle;
    }
    else
    {
        NSArray *items = itemGroup.items.allObjects;
        nextDataProvider = [[ItemsDataProvider alloc] initWithItems:items andSortIdentifier:@"itemNumber"];
        nextDataProvider.layoutStyle = _layoutStyle;
    }
    
    [self pushDataProvider:nextDataProvider];
}

- (void)handleTapOnVariantAtIndexPath:(NSIndexPath *)indexPath
{
    ItemsDataProvider *currDataProvider = (ItemsDataProvider *)_dataProvider;

    SBItem *item = [currDataProvider getItemAtIndexPath:indexPath];
    SBVariant *variant = [item getDefaultVariant];

    NSLog(@"tapped on variant with number %@", variant.variantNumber);
	
	//TODO: item detail VC
	
	ItemDetailViewController *controller = [ItemDetailViewController itemDetailViewController];
	controller.variant = variant;
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [self.delegate handleDragAndDrop:longPressGestureRecognizer];
}

- (void)pushDataProvider:(id)dp
{
    [_dataProviders addObject:dp];

    [self refreshTheCollectionView];
}

- (void)popDataProvider
{
    if (_dataProviders.count == 1) return;

    [_dataProviders removeLastObject];

    [self refreshTheCollectionView];
}

- (void)refreshTheCollectionView
{
    if (_dataProviders.count > 1)
    {
		if ([delegate respondsToSelector:@selector(activateBackButton)]) {
			[delegate activateBackButton];
		}
    }
    else if (_dataProviders.count == 1)
    {
		if ([delegate respondsToSelector:@selector(deactivateBackButton)]) {
			[delegate deactivateBackButton];
		}
    }

    _dataProvider = _dataProviders.lastObject;
    _dataProvider.layoutStyle = _layoutStyle;

    self.collectionView.dataSource = _dataProvider;

    [self.collectionView reloadData];
}

- (void)btnBackTapped
{
    [self popDataProvider];
}

- (void)btnUpTapped
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
}

- (void)btnDownTapped
{
    int itemCount = [self.dataProvider collectionView:self.collectionView numberOfItemsInSection:0];
    int lastItem = itemCount-1;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:lastItem inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

@end