//
//  ShoppingCartOverviewViewController.m
//  SalesBook
//
//  Created by Julian Knab on 13.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBShoppingCart+Extensions.h"
#import "ShoppingCartOverviewViewController.h"
#import "SBShoppingCartDetailViewController.h"

#import "SAGAppDelegate.h"
#import "SAGMenuController.h"

@interface ShoppingCartOverviewViewController ()
{
    NSArray *carts;
    SBShoppingCart *workCart;
}

@end

@implementation ShoppingCartOverviewViewController

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshEntireView:)
                                                     name:notificationShoppingCartCreated
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshEntireView:)
                                                     name:notificationShoppingCartChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshEntireView:)
                                                     name:notificationShoppingCartDeleted
                                                   object:nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    carts = [self getCarts];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(120, 120)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [flowLayout setMinimumInteritemSpacing:10];
    [flowLayout setMinimumLineSpacing:10];

    self.collectionView.collectionViewLayout = flowLayout;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return carts.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStdCell = @"ShoppingCartOverviewCell";
    static NSString *identifierAddCell = @"ShoppingCartOverviewNewCartCell";

    if (indexPath.row == carts.count)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierAddCell forIndexPath:indexPath];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonNewCartTapped)];
        [cell addGestureRecognizer:tap];

        return cell;
    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierStdCell forIndexPath:indexPath];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonCartTapped:)];
    [cell addGestureRecognizer:tap];

    SBShoppingCart *cart = [self getCartAtIndexPath:indexPath];

    UILabel *lblName = (UILabel *)[cell viewWithTag:200];
    lblName.text = cart.humanReadableName;

    UILabel *lblInfo = (UILabel *)[cell viewWithTag:201];
    lblInfo.text = [NSString stringWithFormat:@"%u Positionen", [cart getNumberOfPositions]];

    UILabel *lblCount = (UILabel *)[cell viewWithTag:202];
    lblCount.text = [NSString stringWithFormat:@"%u Optionen", [cart getTotalNumberOfVariantsFromAllPositions]];

    UILabel *lblAmount = (UILabel *)[cell viewWithTag:203];
    lblAmount.text = [NSString stringWithFormat:@"%.2f", [cart getTotalPriceWithRebate]];

    return cell;
}

- (SBShoppingCart *)getCartAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == carts.count) return nil;

    SBShoppingCart *cart = carts[indexPath.row];
    
    return cart;
}

- (NSIndexPath *)getIndexPathForCart:(SBShoppingCart *)shoppingCart
{
    int index = [carts indexOfObject:shoppingCart];

    if (index == carts.count || index == NSNotFound) return nil;

    return [NSIndexPath indexPathForRow:index inSection:0];
}

- (void)refreshCellForCart:(NSNotification *)notification
{
    SBShoppingCart *shoppingCart = (SBShoppingCart *)notification.object;

    NSIndexPath *indexPath = [self getIndexPathForCart:shoppingCart];

    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
}

- (void)refreshEntireView:(NSNotification *)notification
{
    carts = [self getCarts];

    [self.collectionView reloadData];
}

- (NSArray *)getCarts
{
    NSPredicate *predicate;
    
    SBCustomer *customer = [[SAGMenuController defaultController] customer];
    
    if (customer)
    {
        predicate = [NSPredicate predicateWithFormat:@"customer = nil or customer = %@", customer];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"customer = nil"];
    }

    NSArray *arrayWithCarts = [SBShoppingCart MR_findAllSortedBy:@"humanReadableName" ascending:YES withPredicate:predicate];

    return arrayWithCarts;
}

- (void)buttonCartTapped:(UITapGestureRecognizer *)recognizer
{
    UICollectionViewCell *cell = (UICollectionViewCell *)recognizer.view;

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

    SBShoppingCart *cart = [self getCartAtIndexPath:indexPath];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^(void)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        SBShoppingCartDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ShoppingCart"];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;

        vc = [vc initWithCart:cart];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [SVProgressHUD dismiss];

			UIViewController *parentController = self.parentViewController;

			[parentController presentViewController:vc animated:YES completion:^{ }];
        });
    });
}

- (void)buttonNewCartTapped
{
    [SBShoppingCart createNewCart];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) return;

    CGPoint point = [longPressGestureRecognizer locationInView:self.collectionView];

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (!indexPath || indexPath.row == carts.count) return;

    SBShoppingCart *shoppingCart = [self getCartAtIndexPath:indexPath];

    workCart = shoppingCart;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Rename", @"Duplicate", @"Delete", nil];

    [actionSheet showFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.collectionView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SBShoppingCart *cart = workCart;

    switch (buttonIndex)
    {
        case 0:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Rename cart" message:@"Type in new name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [[alertView textFieldAtIndex:0] setText:cart.humanReadableName];
            [alertView show];
            break;
        }
        case 1:
        {
            [cart cloneCart];
            workCart = nil;
            break;
        }
        case 2:
        {
            [cart deleteCart];
            workCart = nil;
            break;
        }
        default:
        {
            workCart = nil;
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString *newName = [[alertView textFieldAtIndex:0] text];
        SBShoppingCart *cart = workCart;
        [cart renameCartToNewName:newName];
    }

    workCart = nil;
}

@end