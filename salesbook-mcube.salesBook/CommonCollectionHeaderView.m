//
//  CommonCollectionHeaderView.m
//  SalesBook
//
//  Created by Frank Wittmann on 06.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CommonCollectionHeaderView.h"

#import <QuartzCore/QuartzCore.h>

@interface CommonCollectionHeaderView() {
	CAGradientLayer *gradientLayer;
}

@end

@implementation CommonCollectionHeaderView

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!gradientLayer) {
		gradientLayer = [CAGradientLayer layer];
		gradientLayer.colors = @[ (__bridge id)([UIColor darkGrayColor].CGColor), (__bridge id)([UIColor whiteColor].CGColor), (__bridge id)([UIColor colorWithWhite:0.8 alpha:1.0].CGColor), (__bridge id)([UIColor darkGrayColor].CGColor) ];
		gradientLayer.locations = @[ @0.0, @0.05, @0.95, @1.0 ];
		gradientLayer.frame = self.bounds;
		[self.layer insertSublayer:gradientLayer atIndex:0];
	}
	
	self.labelHeader.textColor = [UIColor darkGrayColor];
	self.labelHeader.shadowColor = [UIColor whiteColor];
	self.labelHeader.shadowOffset = CGSizeMake(-1, 1);
}

@end
