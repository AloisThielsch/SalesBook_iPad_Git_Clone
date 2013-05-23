//
//  MenuViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

#import "SAGMenuController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITabBarControllerDelegate, SAGMenuControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblCustomerNo;
@property (weak, nonatomic) IBOutlet UILabel *lblName1;
@property (weak, nonatomic) IBOutlet UILabel *lblStreet;
@property (weak, nonatomic) IBOutlet UILabel *lblZipCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCountry;

@property (weak, nonatomic) IBOutlet UIButton *btnShowCustomerSelector;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveSelectedCustomer;

@property (weak, nonatomic) IBOutlet UIImageView *imgCustomerType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)removeSelectedCustomer;

@end
