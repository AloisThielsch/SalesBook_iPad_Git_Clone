//
//  CustomerSelectorTableViewCell.h
//  SalesBook
//
//  Created by Julian Knab on 07.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerSelectorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblCustomerNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerName;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerStreet;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerZipAndCity;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerCountry;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomerAddressType;

@end