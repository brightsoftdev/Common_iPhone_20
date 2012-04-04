//
//  TimeUtils.h
//  WhereTimeGoes
//
//  Created by qqn_pipi on 09-10-6.
//  Copyright 2009 QQN-PIPI.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_DATE_FORMAT		@"yyyyMMddHHmmss"
#define TIME_ZONE_GMT           @"Asia/Shanghai"
#define DATE_FORMAT             @"yyyy-MM-dd"
#define DATE_CHINESE_FORMAT     @"yyyy年MM月dd日"


NSDateComponents *getDateComponents(NSDate *date);

BOOL isToday(NSDate *date);

BOOL isChineseToday(NSDate *date);

BOOL isLocalToday(NSDate *date);

NSString *dateToLocaleString(NSDate *date);

NSString *dateToString(NSDate *date);

NSString *dateToChineseString(NSDate *date);

NSString *dateToChineseStringByFormat(NSDate *date, NSString *format);

NSString *dateToStringByFormat(NSDate *date, NSString *format);

NSString *dateToUTCStringByFormat(NSDate *date, NSString *format);

NSDate *dateFromStringByFormat(NSString *string, NSString *format);

NSDate *dateFromUTCStringByFormat(NSString *string, NSString *format);

NSDate *getDateStart(NSDate* date);

NSDate *getDateEnd(NSDate* date);

NSDate *nextDate(NSDate *date);

NSDate *previousDate(NSDate *date);

NSDate *dateFromChineseStringByFormat(NSString *string, NSString *format);

NSString *chineseWeekDayFromDate(NSDate *date);