//
//  SBVariantMatrixViewController.h
//  SalesBook
//
//  Created by Julian Knab on 09.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBVariantMatrix, SBVariantMatrixInfoProvider, SBVariant;

@interface SBVariantMatrixViewController : UIViewController

@property (nonatomic, retain) SBVariantMatrix *matrix;

@property (nonatomic) BOOL isAddNotSubtract;

@property (nonatomic) int stepValue;

@property (nonatomic, retain) SBVariantMatrixInfoProvider *infoProvider;

@property (strong, nonatomic) IBOutlet UIImageView *image;

@property (strong, nonatomic) IBOutlet UIScrollView *deliveryDateScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *variantMatrixScrollView;
@property (strong, nonatomic) IBOutlet UITableView *variantMatrixTableView;

@property (strong, nonatomic) IBOutlet UITableView *itemInfoTableView;
@property (strong, nonatomic) IBOutlet UITextField *stepTextField;

@property (nonatomic, assign) SBVariant *activeVariant;

- (id)initWithMatrix:(SBVariantMatrix *)matrix;
- (id)initWithMatrix:(SBVariantMatrix *)matrix variant:(SBVariant *)variant;

- (IBAction)collapseButtonTapped:(UIButton *)sender;
- (IBAction)colorCodeLabelTapped:(UILabel *)sender;

- (IBAction)toggleAddAndSubtract:(id)sender;

- (IBAction)close:(UIBarButtonItem *)sender;

- (void)assortmentButtonTapped:(UIButton *)sender;

@end