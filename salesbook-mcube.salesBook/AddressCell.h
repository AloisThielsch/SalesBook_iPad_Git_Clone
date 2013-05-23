//
//  AddressCell.h
//  SalesBook
//
//  Created by Frank Wittmann on 26.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonCollectionCell.h"

@interface AddressCell : CommonCollectionCell

@property (weak, nonatomic) IBOutlet UILabel *labelCustomerNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelCustomerName;
@property (weak, nonatomic) IBOutlet UILabel *labelStreet;
@property (weak, nonatomic) IBOutlet UILabel *labelCityZip;
@property (weak, nonatomic) IBOutlet UILabel *labelCountry;

@end
