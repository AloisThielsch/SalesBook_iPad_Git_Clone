//
//  SBShoppingCartDetailViewController.m
//  SalesBook
//
//  Created by Julian Knab on 15.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "SBShoppingCartDetailViewController.h"

#import "SBAddress+Extensions.h"
#import "SBCustomer+Extensions.h"
#import "SBDocumentPosition+Extensions.h"
#import "SBPrice.h"
#import "SBShoppingCart+Extensions.h"
#import "SBVariant+Extensions.h"

#import "HTMLtoPDFViewController.h"
#import "SBVariantMatrix.h"
#import "SBVariantMatrixViewController.h"
#import "CustomerSelectorViewController.h"

@interface SBShoppingCartDetailViewController ()

@property (nonatomic, strong) UIActionSheet *actionSheet;

@end

@implementation SBShoppingCartDetailViewController

@synthesize cart;

- (id)initWithCart:(SBShoppingCart *)aCart
{
    if (self)
    {
        self.cart = aCart;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshEntireView:)
                                                 name:notificationShoppingCartChanged
                                               object:nil];
    [self setHeaderData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cart.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shoppingCartPositionRow"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shoppingCartPositionRow"];
    }

    int posNumber = indexPath.row;

    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    NSArray *sortedPositions = [self.cart.positions sortedArrayUsingDescriptors:sortDescriptors];

    SBDocumentPosition *docPos = sortedPositions[posNumber];

    SBPrice *price = [docPos.referencedVariant getPriceForCustomerOrNil:docPos.document.customer];

    NSArray *arrDetails = [docPos.referencedVariant getVisibleData];
    
    NSString *strColor;
    
    for (NSDictionary *dict in arrDetails)
    {
        if ([[dict objectForKey:@"uniqueID"] isEqualToString:@"SBVariant.color"])
        {
            strColor = [dict objectForKey:@"value"];
        }
    }

    UIImageView *imageView = (UIImageView *)[cell viewWithTag:0];
    imageView.image = [docPos.referencedVariant defaultImageWithImageMediaType:SAGMediaTypeMedium];

    UILabel *lblNumber = (UILabel *)[cell viewWithTag:1];
    lblNumber.text = docPos.referencedVariant.variantNumber;

    UILabel *lblColor = (UILabel *)[cell viewWithTag:2];
    lblColor.text = strColor;

    UILabel *lblDate = (UILabel *)[cell viewWithTag:3];
    lblDate.text = [docPos.calculatedDeliveryDate asWortmannFormattedString];

    UILabel *lblAmount = (UILabel *)[cell viewWithTag:4];
    lblAmount.text = [NSString stringWithFormat:@"%u", docPos.amount.intValue];

    UIStepper *stepper = (UIStepper *)[cell viewWithTag:5];
    stepper.value = docPos.amount.doubleValue;

    // TODO: the following two lines need to be parameterized
    stepper.hidden = YES;
    stepper.userInteractionEnabled = NO;

    UILabel *lblAmountTotal = (UILabel *)[cell viewWithTag:6];
    int intAmountTotal = docPos.amount.intValue * docPos.referencedVariant.packQuantity.intValue;
    lblAmountTotal.text = [NSString stringWithFormat:@"%u", intAmountTotal];

    UILabel *lblSinglePrice = (UILabel *)[cell viewWithTag:7];
    double dblSinglePrice = price.price.doubleValue;
    NSNumber *numSinglePrice = [NSNumber numberWithDouble:dblSinglePrice];
    lblSinglePrice.text = [NSString stringWithFormat:@"%@", [numSinglePrice stringWithCurrencyCode:nil withLocale:nil]];

    UILabel *lblRebate = (UILabel *)[cell viewWithTag:8];
    lblRebate.text = @"-";

    UILabel *lblTotalPrice = (UILabel *)[cell viewWithTag:9];
    double dblTotalPrice = docPos.amount.intValue * docPos.referencedVariant.packQuantity.intValue * price.price.doubleValue;
    NSNumber *numTotalPrice = [NSNumber numberWithDouble:dblTotalPrice];
    lblTotalPrice.text = [NSString stringWithFormat:@"%@", [numTotalPrice stringWithCurrencyCode:nil withLocale:nil]];

    UIImageView *light = (UIImageView *)[cell viewWithTag:10];
    light.image = [docPos.referencedVariant getSignalLightImage];

    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressGestureRecognizer];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        int posNumber = indexPath.row;
        
        NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
        NSArray *sortedPositions = [self.cart.positions sortedArrayUsingDescriptors:sortDescriptors];
        
        SBDocumentPosition *docPos = sortedPositions[posNumber];

        [self.cart removeDocumentPosition:docPos];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) return;

    UITableViewCell *cell = (UITableViewCell *)longPressGestureRecognizer.view;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    int posNumber = indexPath.row;
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    NSArray *sortedPositions = [self.cart.positions sortedArrayUsingDescriptors:sortDescriptors];
    
    SBDocumentPosition *docPos = sortedPositions[posNumber];

    NSLog(@"long press detected! %@", docPos.referencedVariant.variantNumber);
}

- (IBAction)stepperTapped:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;

    UITableViewCell *cell = (UITableViewCell *)stepper.superview.superview;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    int posNumber = indexPath.row;
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    NSArray *sortedPositions = [self.cart.positions sortedArrayUsingDescriptors:sortDescriptors];
    
    SBDocumentPosition *docPos = sortedPositions[posNumber];

    [docPos setAmountWithInt:stepper.value];
}

- (void)refreshEntireView:(id)sender
{
    [self setHeaderData];
    [self.tableView reloadData];
}

- (void)setHeaderData
{
    SBAddress *address;

    // set header labels ('Customer', 'Invoice address', 'Delivery address')
    // TODO: localization

    self.lblCustomer0.text = @"Customer";

    self.lblInvoice0.text = @"Invoice address";
    self.lblInvoice1.text = @" ";

    self.lblDelivery0.text = @"Delivery address";
    self.lblDelivery1.text = @" ";

    // get cart's customer
    SBCustomer *customer = self.cart.customer;

    // if customer is set, hide select button and fill labels
    if (customer)
    {
        self.btnSelectCustomer.hidden = YES;

        self.btnSelectInvoice.userInteractionEnabled = YES;
        self.btnSelectDelivery.userInteractionEnabled = YES;

        [self.btnSelectInvoice setTitle:@"Tap to select" forState:UIControlStateNormal];
        [self.btnSelectDelivery setTitle:@"Tap to select" forState:UIControlStateNormal];

        address = customer.primaryAddress;

        self.lblCustomer1.text = customer.customerNumber ? customer.customerNumber : @" ";
        self.lblCustomer2.text = address.name1 ? address.name1 : @" ";
        self.lblCustomer3.text = address.street ? address.street : @" ";
        self.lblCustomer4.text = address.zipCity ? address.zipCity : @" ";
        self.lblCustomer5.text = address.country ? address.country : @" ";
    }
    // if no customer, set address selection buttons to disabled
    else
    {
        self.btnSelectInvoice.userInteractionEnabled = NO;
        self.btnSelectDelivery.userInteractionEnabled = NO;

        [self.btnSelectInvoice setTitle:@"Select customer" forState:UIControlStateNormal];
        [self.btnSelectDelivery setTitle:@"Select customer" forState:UIControlStateNormal];

        self.lblCustomer1.text = @" ";
        self.lblCustomer2.text = @" ";
        self.lblCustomer3.text = @" ";
        self.lblCustomer4.text = @" ";
        self.lblCustomer5.text = @" ";
    }

    // get invoice address
    address = self.cart.invoiceAddress;

    // if invoice address is set, hide select button and fill labels
    if (address)
    {
        self.btnSelectInvoice.hidden = YES;

        self.lblInvoice2.text = address.name1 ? address.name1 : @" ";
        self.lblInvoice3.text = address.street ? address.street : @" ";
        self.lblInvoice4.text = address.zipCity ? address.zipCity : @" ";
        self.lblInvoice5.text = address.country ? address.country : @" ";
    }
    else
    {
        self.lblInvoice2.text = @" ";
        self.lblInvoice3.text = @" ";
        self.lblInvoice4.text = @" ";
        self.lblInvoice5.text = @" ";
    }

    // get delivery address
    address = self.cart.deliveryAddress;

    // if delivery address is set, hide select button and fill labels
    if (address)
    {
        self.btnSelectDelivery.hidden = YES;

        self.lblDelivery2.text = address.name1 ? address.name1 : @" ";
        self.lblDelivery3.text = address.street ? address.street : @" ";
        self.lblDelivery4.text = address.zipCity ? address.zipCity : @" ";
        self.lblDelivery5.text = address.country ? address.country : @" ";
    }
    else
    {
        self.lblDelivery2.text = @" ";
        self.lblDelivery3.text = @" ";
        self.lblDelivery4.text = @" ";
        self.lblDelivery5.text = @" ";
    }

    // gather all the other data ...
    NSDate *earliestDeliveryDate = self.cart.getEarliestDeliveryDate;
    NSDate *latestDeliveryDate = self.cart.getLatestDeliveryDate;

    NSString *strEarliestDeliveryDate = earliestDeliveryDate ? earliestDeliveryDate.asWortmannFormattedString : @"-";
    NSString *strLatestDeliveryDate = latestDeliveryDate ? latestDeliveryDate.asWortmannFormattedString : @"-";

    NSString *strCurrencyCode = self.cart.currencyCode ? self.cart.currencyCode : @"-";

    double dblTotalPriceWithRebate = self.cart.getTotalPriceWithRebate;
    NSNumber *numTotalPriceWithRebate = [NSNumber numberWithDouble:dblTotalPriceWithRebate];

    // ... and fill the other labels (column on the very right)
    self.lblHeader0.text = [NSString stringWithFormat:@"Datum / Zeit: %@", self.cart.creationDate.asLocalizedString];
    self.lblHeader1.text = [NSString stringWithFormat:@"Positionen: %u", self.cart.positions.count];
    self.lblHeader2.text = [NSString stringWithFormat:@"frühester LT: %@", strEarliestDeliveryDate];
    self.lblHeader3.text = [NSString stringWithFormat:@"spätester LT: %@", strLatestDeliveryDate];
    self.lblHeader4.text = [NSString stringWithFormat:@"Währung: %@", strCurrencyCode];
    self.lblHeader5.text = [NSString stringWithFormat:@"Summe: %@", [numTotalPriceWithRebate stringWithCurrencyCode:nil withLocale:nil]];
}

- (IBAction)btnOpenMatrixTapped:(id)sender
{
    UIButton *button = (UIButton *)sender;

    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    int posNumber = indexPath.row;

    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    NSArray *sortedPositions = [self.cart.positions sortedArrayUsingDescriptors:sortDescriptors];

    SBDocumentPosition *docPos = sortedPositions[posNumber];

    [self loadMatrixWithItem:docPos.referencedVariant.owningItem];
}

- (IBAction)btnActionMenuTapped:(UIBarButtonItem *)button
{
    if ([_actionSheet isVisible])
    {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
        _actionSheet = nil;
    
        return;
    }
    
    _actionSheet = [[PSPDFActionSheet alloc] initWithTitle:nil];
    _actionSheet.delegate = self;
    
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"Bestellung abschicken", @"Bestellung abschicken")];
    [_actionSheet addButtonWithTitle:NSLocalizedString(@"PDF", @"Bestellung ausdrucken")];

    [_actionSheet showFromBarButtonItem:button animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            // cart 2 order
            // [order saveToMCube];
            [self.cart prepareForDelete];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartDeleted object:nil];
        }
            break;
        case 1:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            HTMLtoPDFViewController *htmpVC = (HTMLtoPDFViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PDFGenerator"];
            htmpVC.document = self.cart;
            htmpVC.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:htmpVC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
    _actionSheet = nil;
}

- (IBAction)btnSelectInvoiceTapped:(UIButton *)button
{
    NSLog(@"btnSelectInvoiceTapped");
}

- (IBAction)btnSelectDeliveryTapped:(UIButton *)button
{
    NSLog(@"btnSelectDeliveryTapped");
}

- (IBAction)close:(UIButton *)button
{
    if ([_actionSheet isVisible])
    {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
        _actionSheet = nil;
    }
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
        
        // add stuff here
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"selectCustomer"])
    {
        CustomerSelectorViewController *customerSelectorViewController = segue.destinationViewController;
        customerSelectorViewController.delegate = self;
    }
}

- (IBAction)closeCustomerSelector:(UIStoryboardSegue *)segue
{
    
}

- (void)loadMatrixWithItem:(SBItem *)item
{
    [SVProgressHUD showWithStatus:@"Lade Matrix..."];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

    dispatch_async(queue, ^(void)
    {
        SBVariantMatrix *variantMatrix = [[SBVariantMatrix alloc] initWithItem:item andCart:self.cart];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        SBVariantMatrixViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"VariantMatrix"];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

        vc = [vc initWithMatrix:variantMatrix];

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            [SVProgressHUD dismiss];

            [self presentViewController:vc animated:YES completion:^{ DDLogInfo(@"Present Matrix!"); }];
        });
    });
}

- (void)didSelectEntity:(NSString *)entityName withObjectID:(NSManagedObjectID *)objectID
{
    if ([entityName isEqualToString:@"SBCustomer"])
    {
        // set customer
        SBCustomer *selectedCustomer = (SBCustomer *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:objectID error:nil];
        self.cart.customer = selectedCustomer;

        // get invoice addresses and if there is only one, set it
        NSSet *invoiceAddresses = [selectedCustomer getInvoiceAddressesWithFallback:YES];
        if (invoiceAddresses.count == 1) self.cart.invoiceAddress = invoiceAddresses.anyObject;

        // get delivery addresses and if there is only one, set it
        NSSet *deliveryAddresses = [selectedCustomer getDeliveryAddressesWithFallback:YES];
        if (deliveryAddresses.count == 1) self.cart.deliveryAddress = deliveryAddresses.anyObject;

        // save and announce changes
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self.cart];

        // refresh view's detail header
        [self setHeaderData];
    }
}

@end