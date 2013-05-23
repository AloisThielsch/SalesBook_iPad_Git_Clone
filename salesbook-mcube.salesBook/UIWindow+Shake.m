//
//  UIWindow+Shake.m
//  SalesBook
//
//  Created by Andreas Kucher on 16.05.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "UIWindow+Shake.h"

@implementation UIWindow (Shake)

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        [super motionEnded:motion withEvent:event];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationMotionShake object:nil];
    }
}

@end
