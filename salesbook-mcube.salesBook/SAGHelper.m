//
//  SAGHelper.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "SAGHelper.h"

#import "SAGLoginManager.h"

#import "XMLHelper.h"
#import "XMLAttribute.h"
#import "XMLDocument.h"
#import "XMLElement.h"

#import "WTStatusBar.h"

@interface SAGHelper (private)

+ (bool)createDirectoryAtPath:(NSString *)path;

@end

@implementation SAGHelper

#pragma mark - Folders

+ (NSString *)applicationDocumentsDirectory
{    
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)applicationPrivateDocumentsDirectory
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:applicationName];
    
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:storePath  isDirectory:&isDirectory];
    
    if (exists == NO)
    {
        [self createDirectoryAtPath:storePath];
    }
    
    return storePath;
}

+ (NSString *)applicationLogDirectory
{
    NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"Logs"];
    
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:storePath  isDirectory:&isDirectory];
    
    if (exists == NO)
    {
        [self createDirectoryAtPath:storePath];
    }
    
    return storePath;
}

#pragma mark - FileStuff

+ (bool)createDirectoryAtPath:(NSString *)path {
    
    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    NSError *error = nil;
    
    if (exists == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error)
    {
        NSLog(@"Could not create %@ with error %@", path, error);
        return NO;
    }
    
    return YES;
}

+ (bool)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: [URL path]])
    {
        NSLog(@"File %@ does not exist", [URL relativeString]);
        
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    
    return success;
}

+ (NSString *)getAppVersion
{    
    return [NSString stringWithFormat:@"SalesBook NG %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

+ (void)playSound:(NSString *)name withExtension:(NSString *)extension
{
    [[SAGLoginManager sharedManger] playSound:name withExtension:extension];
}

#pragma mark - xml template

+ (void)sendReportWithMessage:(NSString *)errorMessage withDictionary:(NSDictionary *)userInfo andScreenshot:(UIImage *)screenshot includeLog:(BOOL)includeLog
{
    if ([[SAGLoginManager sharedManger] username].length == 0 || [[SAGLoginManager sharedManger] password].length == 0)
    {
        DDLogError(@"Error Report - Creation Error!"); //TODO: Remove when mCube das trotzdem akzeptiert!
        return;
    }
    
    XMLDocument *doc = [XMLHelper xmlHeader];
    
    XMLElement *rootElement = [doc rootElement];
    
    XMLElement *payload = [XMLElement elementWithName:@"payload"];
    
    [payload addAttributeNamed:@"type" withValue:@"errorReport"];
    [payload addAttributeNamed:@"version" withValue:@"1.0"];
    [rootElement appendValue:@"payload"];
    [rootElement addChild:payload];
    
    XMLElement *nextNode = [XMLElement elementWithName:@"ErrorMessage"];
    [nextNode appendValue:[XMLHelper replaceUnwantedCharacters:errorMessage]];
    
    [payload addChild:nextNode];
    
    if (includeLog)
    {
        XMLElement *errorLog = [XMLElement elementWithName:@"ErrorLog"];
        
        NSData *dataLog = [[XMLHelper replaceUnwantedCharacters:[(SAGAppDelegate *)[[UIApplication sharedApplication] delegate] getLogFilesContentWithMaxSize:5000]] dataUsingEncoding:NSUTF8StringEncoding];
    
        [errorLog appendValue:[XMLHelper getXMLValue:dataLog]];
        [payload addChild:errorLog];
    }

    if (screenshot)
    {
        nextNode = [XMLElement elementWithName:@"ScreenShot"];
        [nextNode appendValue:[XMLHelper getXMLValue:UIImageJPEGRepresentation(screenshot, 0.7)]];
        [payload addChild:nextNode];
    }
    
    if (userInfo)
    {
        XMLElement *dict = [XMLElement elementWithName:@"UserInfo"];
        
        NSArray *sortedKeys = [[userInfo allKeys] sortedArrayUsingSelector: @selector(compare:)];
        
        for (NSString *key in sortedKeys)
        {
            nextNode = [XMLElement elementWithName:key];
            [nextNode appendValue:[XMLHelper getXMLValue:[userInfo objectForKey:key]]];
            [dict addChild:nextNode];
        }
        
        [payload addChild:dict];
    }
    
    NSString *prettyXML = [doc prettyXML];
    
    NSError *fileError;
    
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [NSString generateUniqueID], [[SAGLoginManager sharedManger] serverID]];
    
    [[prettyXML dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[NSString stringWithFormat:@"%@/%@", [SAGHelper applicationLogDirectory], filename] options:NSDataWritingAtomic error:&fileError];
    
    if (fileError)
    {
        DDLogError(@"### TQ: ERROR: CAN`T WRITE REPORT TO FILE: %@", fileError.localizedDescription);
    }
    else
    {
        DDLogInfo(@"### TQ: SUCCESFULL WRITTEN REPORT TO FILE: %@", filename);
    }
}

/** Screenshot **/
+ (UIImage *)takeScreenshot
{
    // Create a graphics context with the target size
    // Use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //User Interaction
    [self playSound:@"camera" withExtension:@"aif"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Screenshot was taken!", @"Screenshot")];
    });
    
    return image;
}

@end
