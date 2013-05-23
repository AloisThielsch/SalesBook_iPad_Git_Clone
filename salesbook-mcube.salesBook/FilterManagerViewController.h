//
//  FilterManagerViewController.h
//  SalesBook
//
//  Created by Frank Wittmann on 07.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SBFilter+Extensions.h"

typedef enum {
	FilterManagerEditingModeNew,
	FilterManagerEditingModeExisting
} FilterManagerEditingMode;

@interface FilterManagerViewController : UIViewController

@property (nonatomic, strong) SBFilter *filter;
@property (nonatomic) FilterManagerEditingMode editingMode;

+ (FilterManagerViewController *)filterManagerViewControllerForEntityName:(NSString *)entityName;

@end
