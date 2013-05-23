//
//  ContactCell.h
//  SalesBook
//
//  Created by Frank Wittmann on 29.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonCollectionCell.h"

@interface ContactCell : CommonCollectionCell

@property (weak, nonatomic) IBOutlet UILabel *labelContactName;
@property (weak, nonatomic) IBOutlet UILabel *labelPosition;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UILabel *labelFax;
@property (weak, nonatomic) IBOutlet UILabel *labelEMail;

@end
