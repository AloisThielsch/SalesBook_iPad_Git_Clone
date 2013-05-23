//
//  NSString+Crypt.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "NSString+Crypt.h"
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Private)

typedef unsigned char * (* hashing_algorithm_t)(const void *data, CC_LONG len, unsigned char *hash);

- (NSString *)hashAs:(hashing_algorithm_t)algorithm withSize:(size_t)size;

@end

@implementation NSString (Crypt)

- (NSString *)hashAs:(hashing_algorithm_t)algorithm withSize:(size_t)size
{
    if (!self.length)
        return nil;
    
    char const *bytes = self.UTF8String;
    unsigned char hash[size];
    
    algorithm(bytes, strlen(bytes), hash);
    
    NSMutableString *ret = [NSMutableString.alloc initWithCapacity:2 * size];
    
    for (NSInteger i = 0; i < size; ++i)
        [ret appendFormat:@"%02X", hash[i]];
    
    return ret;
}

- (NSString *)stringAsMD5
{
    return [self hashAs:CC_MD5 withSize:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)stringAsSHA256
{
    return [self hashAs:CC_SHA256 withSize:CC_SHA256_DIGEST_LENGTH];
}

@end
