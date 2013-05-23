//
//  SBMedia+Extensions.h
//  SalesBook
//
//  Created by Andreas Kucher on 12.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBMedia.h"

@interface SBMedia (Extensions)

+ (SBMedia *)createNewMedia;

+ (SBMedia *)getMediaWithUniqueID:(NSString *)uniqueID;

- (void)deleteMediaObject;

+ (void)checkMediaFilesToBeDeleted;
+ (int)countMediaReferences:(NSString *)path;
+ (void)deleteMediaFile:(NSString *)path;

- (UIImage *)getImage;

- (BOOL)isAlreadyDownloaded;

- (NSString *)fullFilename;
- (NSURL *)mediaBaseURLWithFullFilename;

+ (NSString *)userMediaDirectory;
+ (NSString *)baseMediaDirectory;

- (BOOL)isMediaValid;
- (BOOL)copyToUserMedia;

@end