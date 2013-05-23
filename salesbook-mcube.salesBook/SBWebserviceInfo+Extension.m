//
//  SBWebserviceInfo+Extension.m
//  SalesBook
//
//  Created by Andreas Kucher on 24.01.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "SBWebserviceInfo+Extension.h"

@implementation SBWebserviceInfo (Extension)

+ (NSString *)getTimestampForWebservice:(NSString *)webservice
{
    SBWebserviceInfo *info = [SBWebserviceInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"webservice == %@", webservice]];
    
    if (info)
    {
        return [info.timestamp asISO8601FormattedString];
    }
    
    return [[NSDate minimumUnixDate] asISO8601FormattedString]; //Initiales Datum zurückgeben
}

+ (NSString *)getRecordIDForWebservice:(NSString *)webservice
{
    SBWebserviceInfo *info = [SBWebserviceInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"webservice == %@", webservice]];
    
    if (info)
    {
        return [info.recordID stringValue];
    }
    
    return @"0"; //Initiale recordID zurückgeben
}

+ (void)setTimestamp:(NSDate *)date andRecordID:(NSNumber *)number forWebservice:(NSString *)webservice
{
    if (date == nil || number == nil) //Es darf kein Null wert geschrieben werden!
    {
        return;
    }
    
    SBWebserviceInfo *info = [SBWebserviceInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"webservice == %@", webservice]];
    
    if (!info)
    {
        info = [SBWebserviceInfo MR_createEntity];
        info.webservice = webservice;
    }
    
    info.timestamp = date;
    info.recordID = number;
}

@end
