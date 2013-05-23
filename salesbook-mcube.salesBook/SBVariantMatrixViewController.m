//
//  SBVariantMatrixViewController.m
//  SalesBook
//
//  Created by Julian Knab on 09.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBVariantMatrixViewController.h"

#import "SBVariantMatrixInfoProvider.h"

#import "SBVariantMatrix.h"
#import "SBVariantMatrixDataCell.h"
#import "SBVariantMatrixDataRow.h"
#import "SBVariantMatrixSumCell.h"
#import "SBVariantMatrixSumRow.h"

#import "SBItem+Extensions.h"

#import "NSDate+Extensions.h"

#import "SBAssortment+Extensions.h"

#import "SBStock+Extensions.h"

#import "ItemDetailViewController.h"

@implementation SBVariantMatrixViewController
{
    NSMutableArray * _collapsedSections;
}

@synthesize matrix;

- (id)initWithMatrix:(SBVariantMatrix *)aMatrix
{    
    if (self)
    {
        self.matrix = aMatrix;
        
        self.isAddNotSubtract = YES;

        SBVariant *var = [aMatrix.item getDefaultVariant];

        self.infoProvider = [[SBVariantMatrixInfoProvider alloc] initWithVariant:var];
        
        self.activeVariant = var;
    }
    
    return self;
}

- (id)initWithMatrix:(SBVariantMatrix *)aMatrix variant:(SBVariant *)variant
{
    if (self) {
        self.matrix = aMatrix;
        self.isAddNotSubtract = YES;
        self.infoProvider = [[SBVariantMatrixInfoProvider alloc] initWithVariant:variant];
        self.activeVariant = variant;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.stepValue = 1;

    self.itemInfoTableView.dataSource = self.infoProvider;

    self.image.image = [self.activeVariant defaultImageWithImageMediaType:SAGMediaTypeMedium];

    self.image.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.image addGestureRecognizer:recognizer];

    int count = [self.matrix numberOfSections];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        [sections setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
    }

    _collapsedSections = sections;

    count = [self.matrix numberOfColumns];

    static int offsetFront = 300;

    for (int i = 0; i < count; i++)
    {
        int x = offsetFront + i * 50;

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 3, 44, 44)];
        [btn setTitle:self.matrix.dimensionOneValues[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(assortmentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        btn.tag = i;

        [self.deliveryDateScrollView addSubview:btn];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = [self.matrix numberOfSections];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)i
{
    NSNumber *isCollapsed = [_collapsedSections objectAtIndex:i];

    if (isCollapsed.boolValue)
    {
        return 1;
    }

    int count = [self.matrix numberOfRowsInSection:i];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;

    NSString *identifier = row == 0 ? @"variantMatrixSumRow" : @"variantMatrixDataRow";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    UITableViewCell *cellToReturn = row == 0 ? [self prepareCell:cell forSumRowAtIndex:indexPath] : [self prepareCell:cell forDataRowAtIndex:indexPath];

    return cellToReturn;
}

- (UITableViewCell *)prepareCell:(UITableViewCell *)cell forSumRowAtIndex:(NSIndexPath *)indexPath
{
    static int offsetFront = 300;

    int sectionNo = indexPath.section;

    NSString *colorStr = [self.matrix.dimensionTwoValues objectAtIndex:sectionNo];

    UIButton *colorBtn = (UIButton *)[cell viewWithTag:-2];
    [colorBtn setTitle:colorStr forState:UIControlStateNormal];

    NSNumber *myLovelyNumber = _collapsedSections[sectionNo];
    BOOL isCollapsed = myLovelyNumber.boolValue;
    NSString *collapseStr = isCollapsed ? @"+" : @"-";

    UIButton *collapseBtn = (UIButton *)[cell viewWithTag:-1];
    [collapseBtn setTitle:collapseStr forState:UIControlStateNormal];

    int cellCount = self.matrix.numberOfColumns;

    for (int i = 0; i < cellCount; i++)
    {
        int x = offsetFront + i * 50;

        SBVariantMatrixSection *section = self.matrix.sections[sectionNo];
        SBVariantMatrixDataRow *dataRow = section.dataRows[0];
        SBVariantMatrixDataCell *dataCell = dataRow.dataCells[i];

        SBVariant *variant = dataCell.itemVariant;

        SBStock *stock = [variant getStock];

        NSString *strStock = [NSString stringWithFormat:@"%u / %u", stock.qty1.intValue, stock.qty2.intValue];

        UILabel *lblStock = [[UILabel alloc] initWithFrame:CGRectMake(x, 3, 44, 22)];
        lblStock.backgroundColor = [UIColor darkGrayColor];
        lblStock.text = strStock;
        lblStock.textAlignment = NSTextAlignmentCenter;
        lblStock.textColor = [UIColor whiteColor];
        lblStock.font = [lblStock.font fontWithSize:12];

        [cell addSubview:lblStock];

        int amount = [self.matrix getAmountOfSumCellAtSection:sectionNo inColumn:i];
        NSString *strAmount = [NSString stringWithFormat:@"%u", amount];

        UILabel *lblAmount = [[UILabel alloc] initWithFrame:CGRectMake(x, 25, 44, 22)];
        lblAmount.backgroundColor = [UIColor darkGrayColor];
        lblAmount.text = strAmount;
        lblAmount.textAlignment = NSTextAlignmentCenter;
        lblAmount.textColor = [UIColor whiteColor];
        lblAmount.font = [lblAmount.font fontWithSize:12];
        
        [cell addSubview:lblAmount];
        
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 3, 44, 44)];
//        btn.backgroundColor = [UIColor darkGrayColor];
//        btn.tag = i;
//
//        [btn setTitle:str forState:UIControlStateNormal];
//
//        [cell addSubview:btn];
    }

    return cell;
}

- (UITableViewCell *)prepareCell:(UITableViewCell *)cell forDataRowAtIndex:(NSIndexPath *)indexPath
{
    static int offsetFront = 300;

    int sectionNo = indexPath.section;
    int itemNo = indexPath.row - 1;

    SBVariantMatrixSection *section = self.matrix.sections[sectionNo];
    SBVariantMatrixDataRow *dataRow = section.dataRows[itemNo];

    NSDate *deliveryDate = dataRow.deliveryDate;
    NSDate *todaysDate = [NSDate date];

    NSString *strDeliveryDate = [deliveryDate asWortmannFormattedString];
    NSString *strTodaysDate = [todaysDate asWortmannFormattedString];

    UILabel *dateLbl = (UILabel *)[cell viewWithTag:-1];
    dateLbl.text = [strDeliveryDate isEqual:strTodaysDate] ? @"sofort" : strDeliveryDate;

    int cellCount = self.matrix.numberOfColumns;
    
    for (int i = 0; i < cellCount; i++)
    {
        int x = offsetFront + i * 50;

        int amount = [self.matrix getAmountOfDataCellAtSection:sectionNo inRow:itemNo inColumn:i];
        NSString *str = amount == 0 ? @"" : [NSString stringWithFormat:@"%u", amount];

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, 3, 44, 44)];
        btn.tag = i;

        [btn setTitle:str forState:UIControlStateNormal];

        SBVariantMatrixDataCell *dataCell = dataRow.dataCells[i];

        if (dataCell.itemVariant == nil)
        {
            btn.userInteractionEnabled = NO;
            btn.backgroundColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
        }
        else
        {
            btn.userInteractionEnabled = YES;
            btn.backgroundColor = [UIColor lightGrayColor];
            
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleButtonTap:)];
            [btn addGestureRecognizer:tapGestureRecognizer];
        }

        [cell addSubview:btn];
    }

    return cell;
}

- (void)handleButtonTap:(UITapGestureRecognizer *)recognizer
{
    UIButton *button = (UIButton *)recognizer.view;

    UITableViewCell *tableViewCell = (UITableViewCell *)button.superview;

    NSIndexPath *indexPath = [self.variantMatrixTableView indexPathForCell:tableViewCell];

    int sectionNo = indexPath.section;
    int rowNo = indexPath.row - 1;
    int columnNo = button.tag;

    if (self.isAddNotSubtract)
    {
        [self.matrix increaseAmountOfDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo by:self.stepValue];
    }
    else
    {
        [self.matrix decreaseAmountOfDataCellAtSection:sectionNo inRow:rowNo inColumn:columnNo by:self.stepValue];
    }

    [self.variantMatrixTableView reloadData];
}

- (IBAction)collapseButtonTapped:(UIButton *)sender
{
    UIView *cellContentView = sender.superview;

    UITableViewCell *tableViewCell = (UITableViewCell *)cellContentView.superview;

    NSIndexPath *indexPath = [self.variantMatrixTableView indexPathForCell:tableViewCell];
    
    int sectionNo = indexPath.section;

    NSNumber *myLovelyNumber = _collapsedSections[sectionNo];

    BOOL isCollapsed = myLovelyNumber.boolValue;

    myLovelyNumber = [NSNumber numberWithBool:!isCollapsed];

    [_collapsedSections setObject:myLovelyNumber atIndexedSubscript:sectionNo];

    [self.variantMatrixTableView reloadData];
}

- (IBAction)colorCodeLabelTapped:(UIButton *)sender
{
    UIView *cellContentView = sender.superview;
    
    UITableViewCell *tableViewCell = (UITableViewCell *)cellContentView.superview;

    NSIndexPath *indexPath = [self.variantMatrixTableView indexPathForCell:tableViewCell];
    
    int sectionNo = indexPath.section;

    SBVariantMatrixSection *section = self.matrix.sections[sectionNo];

    if (section.dataRows.count == 0) return;

    SBVariantMatrixDataRow *dataRow = section.dataRows[0];

    SBVariantMatrixDataCell *dataCell = nil;
    SBVariant *variant = nil;

    for (int i = 0; i < dataRow.dataCells.count && variant == nil; i++)
    {
        dataCell = dataRow.dataCells[i];
        variant = dataCell.itemVariant;
    }

    self.activeVariant = variant;

    self.image.image = [variant defaultImageWithImageMediaType:SAGMediaTypeMedium];

    self.infoProvider = [self.infoProvider initWithVariant:variant];
    
    [self.itemInfoTableView reloadData];
}

- (void)assortmentButtonTapped:(UIButton *)sender
{
    int column = sender.tag;
    NSString *strAssortment = self.matrix.dimensionOneValues[column];

    SBVariant *variant = nil;

    for (int i = 0; i < self.matrix.sections.count && variant == nil; i++)
    {
        SBVariantMatrixSection *section = self.matrix.sections[i];

        for (int j = 0; j < section.dataRows.count && variant == nil; j++)
        {
            SBVariantMatrixDataRow *dataRow = section.dataRows[j];
            SBVariantMatrixDataCell *dataCell = dataRow.dataCells[column];

            variant = dataCell.itemVariant;
        }
    }

    NSString *strSeason = variant.season;

    NSDictionary *assortmentDict = [SBAssortment sizeIndexWithAssortment:strAssortment andSeason:strSeason];

    NSArray *sizeIndexArray = [assortmentDict objectForKey:@"sizeIndex"];

    int count = sizeIndexArray.count;

    int width = count > 2 ? 100 + count * 30 : 270;

    UIViewController *contoller = [[UIViewController alloc] init];
    [contoller setContentSizeForViewInPopover:CGSizeMake(width, 100)];
    [contoller.view setBackgroundColor:[UIColor whiteColor]];

    UILabel *lbl0 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 270, 20)];
    lbl0.text = [NSString stringWithFormat:@"Saison %@ - %@ Paar", strSeason, [assortmentDict objectForKey:@"total"]];
    [contoller.view addSubview:lbl0];

    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 80, 20)];
    lbl1.text = @"Größe";
    [contoller.view addSubview:lbl1];

    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 80, 20)];
    lbl2.text = @"Menge";
    [contoller.view addSubview:lbl2];

    for (int i = 0; i < count; i++)
    {
        int x = 100 + i * 30;

        NSDictionary *dict = (NSDictionary *)sizeIndexArray[i];

        NSNumber *numQty = [dict objectForKey:@"quantity"];

        NSString *strQty = [NSString stringWithFormat:@"%u", numQty.intValue];
        NSString *strSize = [dict objectForKey:@"size"];

        strSize = [strSize stringByReplacingOccurrencesOfString:@" " withString:@""];

        UILabel *lblQty = [[UILabel alloc] initWithFrame:CGRectMake(x, 70, 30, 20)];
        lblQty.text = strQty;

        [contoller.view addSubview:lblQty];

        UILabel *lblSize = [[UILabel alloc] initWithFrame:CGRectMake(x, 40, 30, 20)];
        lblSize.text = strSize;

        [contoller.view addSubview:lblSize];
    }

    UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:contoller];

    [[LRPopoverManager sharedManager] presentPopoverController:pc fromRect:CGRectMake(0, 0, 44, 36) inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)toggleAddAndSubtract:(id)sender
{
    self.isAddNotSubtract = !self.isAddNotSubtract;
}

- (IBAction)stepperTapped:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    
    NSNumber *number = [NSNumber numberWithDouble:stepper.value];

    int intValue = number.intValue;

    self.stepValue = intValue;

    self.stepTextField.text = [NSString stringWithFormat:@"%u", intValue];
}

- (void)imageTapped:(id)sender
{
    NSLog(@"someone tapped that ugly shoe!");

    ItemDetailViewController *controller = [ItemDetailViewController itemDetailViewController];
	controller.variant = self.activeVariant;
	[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)close:(UIButton *)button
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:^{

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

        [[NSNotificationCenter defaultCenter] postNotificationName:notificationShoppingCartChanged object:self.matrix.cart];

        DDLogInfo(@"Dismiss Matrix!");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end