//
//  UIWindow+Shake.h
//  SalesBook
//
//  Created by Andreas Kucher on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Shake)

- (BOOL)canBecomeFirstResponder;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end
