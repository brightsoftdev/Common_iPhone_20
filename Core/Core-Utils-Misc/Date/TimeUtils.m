//
//  TimeUtils.m
//  WhereTimeGoes
//
//  Created by qqn_pipi on 09-10-6.
//  Copyright 2009 QQN-PIPI.com. All rights reserved.
//

#import "TimeUtils.h"
NSArray *weekDays = nil; 

static NSArray *getWeekDayArray()
{
    if(weekDays == nil)
    {
        weekDays = [[NSArray alloc]initWithObjects: @"星期日", @"星期一", @"星期二",
                      @"星期三",@"星期四",@"星期五",@"星期六", nil];
    }
    return weekDays;
}



NSDateFormatter *dateFormatter = nil;
static NSDateFormatter *getDateFormatter()
{
    @synchronized(dateFormatter){
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
        }
        return dateFormatter;
    }
}

// return YEAR, MONTH, DAY in NSDateComponents by given NSDate
NSDateComponents *getDateComponents(NSDate *date)
{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];	
	return comps;
}

static NSDateComponents *getChineseDateComponents(NSDate *date)
{
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar] autorelease];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [gregorian components:unitFlags fromDate:date];	
	return comps;
}

static NSDateComponents *getLocalDateComponents(NSDate *date)
{
	NSCalendar *calendar = [NSCalendar currentCalendar];	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit;
	NSDateComponents *comps = [calendar components:unitFlags fromDate:date];	
	return comps;
}

// return whether given date and today is the same day
BOOL isToday(NSDate *date)
{
	// Get Today's YYYY-MM-DD
	NSDateComponents *today_comps = getDateComponents([NSDate date]);
	
	// Given Date's YYYY-MM-DD
	NSDateComponents *select_comps = getDateComponents(date);		
	
	// if it's today, return TODAY
	if ( [today_comps year] == [select_comps year] &&
		[today_comps month] == [select_comps month] &&
		[today_comps day] == [select_comps day]){		
		return YES;
	}
	else {
		return NO;
	}

}

// return whether given date and today is the same day
BOOL isLocalToday(NSDate *date)
{
	// Get Today's YYYY-MM-DD
	NSDateComponents *today_comps = getLocalDateComponents([NSDate date]);
	
	// Given Date's YYYY-MM-DD
	NSDateComponents *select_comps = getLocalDateComponents(date);		
	
	// if it's today, return TODAY
	if ( [today_comps year] == [select_comps year] &&
		[today_comps month] == [select_comps month] &&
		[today_comps day] == [select_comps day]){		
		return YES;
	}
	else {
		return NO;
	}
    
}

BOOL isChineseToday(NSDate *date)
{
	// Get Today's YYYY-MM-DD
	NSDateComponents *today_comps = getChineseDateComponents([NSDate date]);
	
	// Given Date's YYYY-MM-DD
	NSDateComponents *select_comps = getChineseDateComponents(date);		
	
	// if it's today, return TODAY
	if ( [today_comps year] == [select_comps year] &&
		[today_comps month] == [select_comps month] &&
		[today_comps day] == [select_comps day]){		
		return YES;
	}
	else {
		return NO;
	}
    
}

// covert date to string by given locale
NSString *dateToLocaleString(NSDate *date)
{
	NSDateFormatter *dateFormatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	 	 
	NSLocale *locale = [NSLocale currentLocale];
	[dateFormatter setLocale:locale];
	
//	NSLog(@"Date string for locale %@: %@",
//		  [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:date]);

	return [dateFormatter stringFromDate:date]; 
	 
}

// convert date to string in YYYY-MM-DD format
//NSString *dateToString(NSDate *date)
//{
//	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//	
//	[dateFormatter setDateFormat:@"YYYY-MM-DD"];
//	return [dateFormatter stringFromDate:date];	
//}

NSString *dateToChineseString(NSDate *date)
{
    if(date == nil)
        return nil;
	NSDateFormatter *dateFormatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:TIME_ZONE_GMT];
    [dateFormatter setTimeZone:tzGMT];
    [dateFormatter setDateFormat:DATE_CHINESE_FORMAT];
    NSString *period = [dateFormatter stringFromDate:date];
    return period;
}

NSString *dateToChineseStringByFormat(NSDate *date, NSString *format)
{
    if(date == nil)
        return nil;
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:TIME_ZONE_GMT];
    [formatter setTimeZone:tzGMT];
    [formatter setDateFormat:format];
    NSString *period = [formatter stringFromDate:date];
    return period;
}

NSString *dateToString(NSDate *date)
{
    if(date == nil)
        return nil;
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:TIME_ZONE_GMT];
    [formatter setTimeZone:tzGMT];
    [formatter setDateFormat:DATE_FORMAT];
    NSString *period = [formatter stringFromDate:date];
    return period;
}



// covert date to string by given format
NSString *dateToStringByFormat(NSDate *date, NSString *format)
{
    if(date == nil)
        return nil;
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:format];
	return [formatter stringFromDate:date];	
	
}

NSString *dateToUTCStringByFormat(NSDate *date, NSString *format)
{
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	
	return [formatter stringFromDate:date];		
}

// convert string to date by given format
NSDate *dateFromStringByFormat(NSString *string, NSString *format)
{
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:format];
	
	return [formatter dateFromString:string];	
	
}
	 
// convert string to date by given format
NSDate *dateFromUTCStringByFormat(NSString *string, NSString *format)
{
	if (string == nil)
		return nil;
	
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	 
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	 
	return [formatter dateFromString:string];	
	 
}

// convert string to date by given format
NSDate *dateFromChineseStringByFormat(NSString *string, NSString *format)
{
	if (string == nil || [string length] == 0)
		return nil;
	
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
    
	[formatter setDateFormat:format];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:TIME_ZONE_GMT]];
	return [formatter dateFromString:string];	    
    
}

// return start date time of the day
NSDate *getDateStart(NSDate* date)
{
	NSDateComponents* comp = getDateComponents(date);
	
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d 00:00:00", 
							[comp year], [comp month], [comp day]];
	
	return [formatter dateFromString:dateString];
	
}

// return end date time of the day
NSDate *getDateEnd(NSDate* date)
{
	NSDateComponents* comp = getDateComponents(date);
	
	NSDateFormatter *formatter = getDateFormatter(); //[[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d 23:59:59", 
							[comp year], [comp month], [comp day]];
	
	return [formatter dateFromString:dateString];	
}

// next date of given date
NSDate *nextDate(NSDate *date)
{
	return [[[NSDate alloc] initWithTimeInterval:24*3600 sinceDate:date] autorelease];
}

// previous date of given date
NSDate *previousDate(NSDate *date)
{
	return [[[NSDate alloc] initWithTimeInterval:-24*3600 sinceDate:date] autorelease];
	
}

static NSDate *nextNDate(NSDate *date, NSInteger interval)
{
	return [[[NSDate alloc] initWithTimeInterval:24*3600*interval sinceDate:date] autorelease];
	
}

NSString *chineseWeekDayFromDate(NSDate *date)
{
    NSDateComponents *dc = getChineseDateComponents(date);
    [dc setTimeZone:[NSTimeZone timeZoneWithName:TIME_ZONE_GMT]];
    NSInteger weekIndex = [dc weekday];
    if(weekIndex > [getWeekDayArray() count]){
        return @"";
    }
    return [getWeekDayArray() objectAtIndex:weekIndex-1];
}
/*
 // The date in your source timezone (eg. EST)
 NSDate* sourceDate = [NSDate date];
 
 NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
 NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
 
 NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
 NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
 NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
 
 NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate] autorelease];
 */

/*
 NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
 [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
 NSDate* sourceDate = [formatter dateFromString:@"2009-07-04 10:23:23"];
 */


/*
 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
 [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
 
 NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
 
 NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
 [dateFormatter setLocale:usLocale];
 
 NSLog(@"Date for locale %@: %@",
 [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:date]);
 // Output:
 // Date for locale en_US: Jan 2, 2001
 
 NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"];
 [dateFormatter setLocale:frLocale];
 NSLog(@"Date for locale %@: %@",
 [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:date]);
 // Output:
 // Date for locale fr_FR: 2 janv. 2001
*/