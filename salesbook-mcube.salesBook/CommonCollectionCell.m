//
//  CommonCollectionCell.m
//  SalesBook
//
//  Created by Frank Wittmann on 06.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "CommonCollectionCell.h"

#import <QuartzCore/QuartzCore.h>

@interface CommonCollectionCell() {
	CAGradientLayer *gradientLayer;
}

@end

@implementation CommonCollectionCell

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if (!gradientLayer) {
		gradientLayer = [CAGradientLayer layer];
		gradientLayer.colors = @[ (__bridge id)([UIColor whiteColor].CGColor), (__bridge id)([UIColor colorWithWhite:0.9 alpha:1.0].CGColor) ];
		gradientLayer.frame = self.bounds;
		[self.layer insertSublayer:gradientLayer atIndex:0];
		
		self.layer.masksToBounds = NO;
		self.layer.shadowOpacity = 0.5;
		self.layer.shadowRadius = 4.0;
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
		self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
		self.layer.borderColor = [UIColor lightGrayColor].CGColor;
		self.layer.borderWidth = 2.0;
	}
}

@end
