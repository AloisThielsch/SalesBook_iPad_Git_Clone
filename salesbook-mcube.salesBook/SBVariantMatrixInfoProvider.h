//
//  SBVariantMatrixInfoProvider.h
//  SalesBook
//
//  Created by Julian Knab on 24.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBItem, SBVariant;

@interface SBVariantMatrixInfoProvider : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSArray *info;

- (id)initWithItem:(SBItem *)item;
- (id)initWithVariant:(SBVariant *)variant;

@end