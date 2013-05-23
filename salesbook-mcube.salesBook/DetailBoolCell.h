//
//  DetailBoolCell.h
//  SalesBook
//
//  Created by Frank Wittmann on 17.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailBaseCell.h"

@interface DetailBoolCell : DetailBaseCell

@property (weak, nonatomic) IBOutlet UISwitch *switchValue;

@end
