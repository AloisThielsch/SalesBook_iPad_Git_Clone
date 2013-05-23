//
//  NSDate+Extensions.m
//  SalesBook
//
//  Created by Andreas Kucher on 14.12.12.
//  Copyright (c) 2012 Siller AG. All rights reserved.
//

#import "NSDate+Extensions.h"

// Private Helper functions
@interface NSDate (Private)

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
          hours:(int)hours minutes:(int)minutes seconds:(int)seconds;

+ (void)zeroOutTimeComponents:(NSDateComponents **)components;

+ (NSDate *)midnightOfDate:(NSDate *)date;

@end

@implementation NSDate (Extensions)

+ (NSDate *)midnightOfDate:(NSDate *)date
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Start out by getting just the year, month and day components of the specified date.
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    
    // Zero out the hour, minute and second components.
    [self zeroOutTimeComponents:&components];
    
    // Convert the components back into a date and return it.
    return [gregorianCalendar dateFromComponents:components];
}

- (NSDate *)midnight
{
    return [NSDate midnightOfDate:self];
}

- (NSDate *)yesterday
{
	return [[NSDate date] ago:0 months:0 weeks:0 days:1 hours:0 minutes:0 seconds:0];
}

- (NSDate *)today
{
	return [NSDate midnightOfDate:[NSDate date]];
}

- (NSDate *)tomorrow
{
	return [[NSDate date] advance:0 months:0 weeks:0 days:1 hours:0 minutes:0 seconds:0];
}

- (int)day
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *comp = [cal components:NSDayCalendarUnit fromDate:self];

    return comp.day;
}

- (int)month
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *comp = [cal components:NSMonthCalendarUnit fromDate:self];

    return comp.month;
}

- (int)year
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateComponents *comp = [cal components:NSYearCalendarUnit fromDate:self];

    return comp.year;
}

- (int)halfOfMonth
{
    return self.day < 16 ? 1 : 2;
}

- (NSString *)asISO8601FormattedString
{    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return [formatter stringFromDate:self];
}

- (NSString *)asLocalizedString
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [formatter stringFromDate:self];
}


- (NSString *)asCustomFieldDate
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [formatter stringFromDate:self];
}

- (NSString *)asWortmannFormattedString
{
    //1H01 = 01.-15.01. eines Monats
    //2H03 = 16.-31.03. eines Monats

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];

    NSMutableString *result = [NSMutableString new];
    
    if (components.day < 16)
    {
        [result appendFormat:@"1H"];
    }
    else
    {
        [result appendFormat:@"2H"];
    }
    
    if (components.month <= 9)
    {
        [result appendFormat:@"0"];
    }
    
    [result appendFormat:@"%u", components.month];

    return result;
}

+ (NSDate *)minimumUnixDate
{    
    return [NSDate dateWithTimeIntervalSince1970:0];
}

#pragma mark -
#pragma mark Other Calculations

- (NSDate *)advance:(int)years months:(int)months weeks:(int)weeks days:(int)days
			  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
	NSDateComponents *comps = [NSDateComponents new];
	[comps setYear:years];
	[comps setMonth:months];
	[comps setWeek:weeks];
	[comps setDay:days];
	[comps setHour:hours];
	[comps setMinute:minutes];
	[comps setSecond:seconds];
    
	return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:self options:0];
}

- (NSDate *)ago:(int)years months:(int)months weeks:(int)weeks days:(int)days
		  hours:(int)hours minutes:(int)minutes seconds:(int)seconds
{
    
    return [self advance:years*-1 months:months*-1 weeks:weeks*-1 days:days*-1
                   hours:hours*-1 minutes:minutes*-1 seconds:seconds*-1];
}

#pragma mark - Private Helper functions

+ (void)zeroOutTimeComponents:(NSDateComponents **)components
{
    [*components setHour:0];
    [*components setMinute:0];
    [*components setSecond:0];
}

+ (NSString *)nowAsLocalizedString
{
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [dateFormatter stringFromDate:today];
}

@end