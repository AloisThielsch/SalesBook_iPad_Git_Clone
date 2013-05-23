//
//  SAGErrorReport.m
//  SalesBook
//
//  Created by Matthias Spohn on 16.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SAGErrorReport.h"
#import "SSZipArchive.h"

@implementation SAGErrorReport

- (void)makeArchive
{
    /* Pfad wo Screenshot liegen soll */
    NSString *fullFileName = [NSString stringWithFormat:@"%@/screenshot.png", [self reportPath]];
    
    /* Den Scrrenshot anlegen */
    NSData * imageData = UIImagePNGRepresentation(self.takeScreenshot);
    [imageData writeToFile:fullFileName atomically:YES];

    /* Wo die ZIP-Datei abgelegt wird */
    NSString *zipReport = [NSString stringWithFormat:@"%@/Report.zip",[self reportPath]];
    
    /* Die Namen der Logfiles holen */
    NSString *logPath = [NSString stringWithFormat:@"%@/Logs/",[self reportPath]];
    NSArray *logFiles = [self listFileAtPath:logPath];

    /* Dateien Sammeln */
    NSMutableArray *inputPaths = [[NSMutableArray alloc] initWithObjects:[[NSBundle bundleWithPath:[self reportPath]] pathForResource:@"screenshot" ofType:@"png"], nil];
    
    for (int idx = 0; idx < (int)[logFiles count]; ++idx)
    {
        [inputPaths addObject:[logPath stringByAppendingPathComponent:logFiles[idx]]];
    }

    /* in ZIP packen und ablegen */
    [SSZipArchive createZipFileAtPath:zipReport withFilesAtPaths:inputPaths];

    /* Den Screenshot löschen */
    [self deleteFile:fullFileName];
}

/** Ort wo die Report Datei abgelegt werden soll **/
- (NSString *)reportPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    return cachesDirectory;
}

/** Datei löschen **/
- (void)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:filePath error:nil];
}

/** Dateinamen aus Directory auslesen **/
- (NSArray *)listFileAtPath:(NSString *)path
{
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
 
    return directoryContent;
}

/** Screenshot **/
- (UIImage *)takeScreenshot
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
    
    return image;
}

@end
