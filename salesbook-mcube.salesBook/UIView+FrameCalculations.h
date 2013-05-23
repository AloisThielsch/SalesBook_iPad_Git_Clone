//
//  UIView+FrameCalculations.h
//  corp_Common
//
//  Created by Frank Wittmann on 05.09.12.
//  Copyright (c) 2012 Heidelberg mobil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(FrameCalculations)

@property (nonatomic, assign) CGPoint $origin;
@property (nonatomic, assign) CGSize $size;
@property (nonatomic, assign) CGFloat $x, $y, $width, $height;
@property (nonatomic, assign) CGFloat $left, $top, $right, $bottom;

@end
