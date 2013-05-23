//
//  SBWebserviceInfo+Extension.h
//  SalesBook
//
//  Created by Andreas Kucher on 24.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBWebserviceInfo.h"

@interface SBWebserviceInfo (Extension)

+ (NSString *)getTimestampForWebservice:(NSString *)webservice;
+ (NSString *)getRecordIDForWebservice:(NSString *)webservice;

+ (void)setTimestamp:(NSDate *)date andRecordID:(NSNumber *)number forWebservice:(NSString *)webservice;

@end
