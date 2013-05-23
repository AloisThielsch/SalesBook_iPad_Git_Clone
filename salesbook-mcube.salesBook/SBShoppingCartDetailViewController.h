//
//  SBShoppingCartDetailViewController.h
//  SalesBook
//
//  Created by Julian Knab on 15.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBShoppingCart;

@interface SBShoppingCartDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) SBShoppingCart *cart;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UILabel *lblHeader0;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader1;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader2;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader3;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader4;
@property (strong, nonatomic) IBOutlet UILabel *lblHeader5;

@property (strong, nonatomic) IBOutlet UILabel *lblCustomer0;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer1;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer2;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer3;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer4;
@property (strong, nonatomic) IBOutlet UILabel *lblCustomer5;

@property (strong, nonatomic) IBOutlet UILabel *lblInvoice0;
@property (strong, nonatomic) IBOutlet UILabel *lblInvoice1;
@property (strong, nonatomic) IBOutlet UILabel *lblInvoice2;
@property (strong, nonatomic) IBOutlet UILabel *lblInvoice3;
@property (strong, nonatomic) IBOutlet UILabel *lblInvoice4;
@property (strong, nonatomic) IBOutlet UILabel *lblInvoice5;

@property (strong, nonatomic) IBOutlet UILabel *lblDelivery0;
@property (strong, nonatomic) IBOutlet UILabel *lblDelivery1;
@property (strong, nonatomic) IBOutlet UILabel *lblDelivery2;
@property (strong, nonatomic) IBOutlet UILabel *lblDelivery3;
@property (strong, nonatomic) IBOutlet UILabel *lblDelivery4;
@property (strong, nonatomic) IBOutlet UILabel *lblDelivery5;

@property (strong, nonatomic) IBOutlet UIButton *btnSelectCustomer;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectInvoice;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectDelivery;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnActionMenu;

- (id)initWithCart:(SBShoppingCart *)aCart;

@end