//
//  SAGAppDelegate.h
//  SalesBook
//
//  Created by Andreas Kucher on 13.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDFileLogger.h"

#import <HockeySDK/HockeySDK.h>

@interface SAGAppDelegate : UIResponder <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate, BITUpdateManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDFileLogger *fileLogger;

- (NSString *)getLogFilesContentWithMaxSize:(NSInteger)maxSize;

@end
