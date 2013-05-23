//
//  SBMedia+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 12.02.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBMedia+Extensions.h"

#import "SBCustomer+Extensions.h"
#import "SBVariant+Extensions.h"

#import "SAGLoginManager.h"
#import "SAGSyncManager.h"

#import <CommonCrypto/CommonDigest.h>

@implementation SBMedia (Extensions)

+ (SBMedia *)createNewMedia
{
    SBMedia *media = [SBMedia MR_createEntity];
    
    media.uniqueID = [NSString generateUniqueID]; //generateUniqueID
    media.creationDate = [NSDate date]; //Anlage Datum aufheben
    
    return media;
}

+ (SBMedia *)getMediaWithUniqueID:(NSString *)uniqueID
{
    return [SBMedia MR_findFirstByAttribute:@"uniqueID" withValue:uniqueID];
}

#pragma mark - relationships

- (void)setCustomerNumber:(NSString *)customerNumber
{
    [self willChangeValueForKey:@"customerNumber"];
    [self setPrimitiveValue:customerNumber forKey:@"customerNumber"];
    [self didChangeValueForKey:@"customerNumber"];
    
    [self setCustomer:[SBCustomer getCustomerWithCustomerNumber:customerNumber]];
}

- (void)setVariantNumber:(NSString *)variantNumber //Ist hier ein Transiant property und wird nicht persistiert!
{
    [self willChangeValueForKey:@"variantNumber"];
    [self setPrimitiveValue:variantNumber forKey:@"variantNumber"];
    [self didChangeValueForKey:@"variantNumber"];
    
    SBVariant *variant = [SBVariant getVariantWithVariantNumber:variantNumber];
    
    if (variant == nil)
    {
        DDLogError(@"## Media Error: %@ variant not found! %@", variantNumber, self.uniqueID);
        return;
    }
    
    [self addVariantsObject:variant];
}

#pragma mark - media access

- (UIImage *)getImage
{
    if ([[NSURL fileURLWithPath:[self userMediaFullPathWithFilename]] checkResourceIsReachableAndReturnError:nil] == NO)
    {
        return [UIImage imageNamed:@"image.png"];
    }
   
    return  [UIImage imageWithContentsOfFile:[self userMediaFullPathWithFilename]];
}

- (BOOL)isAlreadyDownloaded
{
    //Prüfen ob das Medium für den User schon existiert
    NSURL *userMediaURL = [NSURL fileURLWithPath:[self userMediaFullPathWithFilename]];
    
    if ([userMediaURL checkResourceIsReachableAndReturnError:NULL] == YES)
    {
        if ([self isMediaValid]) //mit dem richtigen HashCode
        {
            return YES;
        }
        
        DDLogInfo(@"WRONG HASHCODE FOR EXISTING FILE -> DELETE: %@", self.fullFilename);
        
        [SBMedia deleteMediaFile:[self userMediaFullPathWithFilename]]; //Den Link löschen
        [SBMedia deleteMediaFile:[self baseMediaFullPathWithFilename]]; //Das Basismedium löschen
    }
    else if ([[NSURL fileURLWithPath:[self baseMediaFullPathWithFilename]] checkResourceIsReachableAndReturnError:NULL] == YES && [self isMediaValid]) //Prüfen ob das Medium im Allgemeinen Ordner schon exisitert
    {
        DDLogInfo(@"USE EXISTING FILE -> %@", self.fullFilename);
        
        [self copyToUserMedia];
        
        return YES;
    }
    
    return NO;
}

- (void)deleteMediaObject
{
    // Medienverzeichnis des Users
    NSURL *userMediaURL = [NSURL fileURLWithPath:[self userMediaFullPathWithFilename]];
    
    // Allgemeiner Medien Zielordner
    NSURL *mediaBaseURL = [NSURL fileURLWithPath:[self baseMediaFullPathWithFilename]];
    
    if ([userMediaURL checkResourceIsReachableAndReturnError:NULL] == YES)
    {
        DDLogInfo(@"USER MEDIA DELETED: %@", userMediaURL);
        [SBMedia deleteMediaFile:userMediaURL.path];
    }
    
    if ([mediaBaseURL checkResourceIsReachableAndReturnError:NULL] == YES)
    {
        if ([SBMedia countMediaReferences:mediaBaseURL.path] == 1)
        {
            DDLogInfo(@"BASE MEDIA DELETED: %@", mediaBaseURL);
            [SBMedia deleteMediaFile:mediaBaseURL.path];
        }
    }
    
    [self MR_deleteEntity];
}

#pragma mark - class methods

/** Count Hardlinks auf File **/
+ (int)countMediaReferences:(NSString *)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:path error:nil];
    
    if (attrs != nil)
    {
        return [[attrs objectForKey:NSFileReferenceCount] intValue];
    }
    else
    {
        return 0;
    }
}

+ (void)checkMediaFilesToBeDeleted
{
    NSMutableString *storePath = [NSMutableString stringWithString:[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]];
    
    [storePath appendFormat:@"/Media/"];
    
    int count = 0;
    
    for (NSString *fileName in [[NSFileManager defaultManager] enumeratorAtPath:storePath])
    {
        if ([fileName isEqualToString:@".DS_Store"]) continue;
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", storePath, fileName];
        
        if ([SBMedia countMediaReferences:filePath] == 1)
        {
            [self deleteMediaFile:filePath];
            count++;
        }
    }
    
    DDLogInfo(@"%d Media files deleted!", count);
}

/** Resource löschen **/
+ (void)deleteMediaFile:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:nil];
    }
}

#pragma mark - internal Functions

- (BOOL)isMediaValid
{
    if (self.hashCode == nil)
    {
        self.hashCode = [self getMediaHash];
        
        return YES;
    }
    
    return [self.hashCode isEqual:[self getMediaHash]];
}

- (NSString *)getMediaHash
{
    @autoreleasepool
    {
        NSData *media = [NSData dataWithContentsOfFile:[self baseMediaFullPathWithFilename]];
        
        unsigned char result[16];
        CC_MD5([media bytes], [media length], result);
        NSString *mediaHash = [NSString stringWithFormat:
                               @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                               result[0], result[1], result[2], result[3],
                               result[4], result[5], result[6], result[7],
                               result[8], result[9], result[10], result[11],
                               result[12], result[13], result[14], result[15]
                               ];
        
        return [mediaHash lowercaseString];
    }
}

/* Hardlink mit dem neuen Dateinamen auf die vorhanden Datei anlegen */
- (BOOL)copyToUserMedia
{
    @autoreleasepool
    {
        // Allgemeiner Medien Zielordner
        NSURL *sourceURL = [NSURL fileURLWithPath:[self baseMediaFullPathWithFilename]];
        
        // Datei nicht in iCloud und iTunes sichern
        [SAGHelper addSkipBackupAttributeToItemAtURL:sourceURL];
        
        // Medienverzeichnis des Users
        NSURL *destinationURL = [NSURL fileURLWithPath:[self userMediaFullPathWithFilename]];
        
        if ([destinationURL checkResourceIsReachableAndReturnError:NULL] == NO)
        {
            NSError *err = nil;
            [[NSFileManager defaultManager] linkItemAtURL:sourceURL toURL:destinationURL error:&err];
            
            // Datei nicht in iCloud und iTunes sichern
            [SAGHelper addSkipBackupAttributeToItemAtURL:destinationURL];
            
            if (err)
            {
                return NO;
            }
        }
        
        return YES;
    }
}


- (NSURL *)mediaBaseURLWithFullFilename
{
    return [NSURL fileURLWithPath:[self baseMediaFullPathWithFilename]];
}

#pragma mark - alles was mit Pfad angeben zu tun hat...

- (NSString *)fullFilename
{
    return [NSString stringWithFormat:@"%@.%@", self.fileName, self.fileNameExtension];
}

- (NSString *)userMediaFullPathWithFilename
{
    return [NSString stringWithFormat:@"%@%@", [SBMedia userMediaDirectory], self.fullFilename];
}

- (NSString *)baseMediaFullPathWithFilename
{
    return [NSString stringWithFormat:@"%@%@", [SBMedia baseMediaDirectory], self.fullFilename];
}

+ (NSString *)baseMediaDirectory;
{
    NSMutableString *storePath = [NSMutableString stringWithString:[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]];
    
    [storePath appendFormat:@"/Media/"];
    
    [SAGHelper createDirectoryAtPath:storePath];
    
    return storePath;
}

+ (NSString *)userMediaDirectory
{
    NSMutableString *storePath = [NSMutableString stringWithString:[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject]];
    
    [storePath appendFormat:@"/Media/%@-%@/", [[SAGLoginManager sharedManger] serverID], [[SAGLoginManager sharedManger] username]];
    
    [SAGHelper createDirectoryAtPath:storePath];
    
    return storePath;
}

@end