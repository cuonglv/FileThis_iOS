//
//  DateHandler.h
//  TKD
//
//  Created by decuoi on 5/30/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDaysOfWeek             [NSArray arrayWithObjects:@"SUN", @"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT", nil]

#define kCapitalizedMonthsOfYear [NSArray arrayWithObjects:@"JANUARY",@"FEBRUARY",@"MARCH",@"APRIL",@"MAY",@"JUNE",@"JULY",@"AUGUST",@"SEPTEMBER",@"OCTOBER",@"NOVEMBER",@"DECEMBER",nil]

#define kMonthsOfYear [[NSArray alloc] initWithObjects:@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December",nil]
#define kShortMonthsOfYear [[NSArray alloc] initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec",nil]

@interface DateHandler : NSObject {

}

+ (NSString*)yyyyMMddStringFromDateComps:(NSDateComponents*)dateComps;
+ (NSString*)stringFromYear:(int)year month:(int)month day:(int)day;
+ (NSString*)displayedStringFromYear:(int)year month:(int)month day:(int)day;
+ (NSString*)characterStringFromYear:(int)year month:(int)month day:(int)day;

+ (NSString*)stringFromDate:(NSDateComponents*)date;
+ (NSString*)displayedStringFromDate:(NSDateComponents*)date;

+ (NSString*)stringFromDateTime:(NSDateComponents*)date;
+ (NSString*)stringFromFullDateTime:(NSDateComponents*)date;
+ (NSString*)xmlStringFromDate:(NSDateComponents*)date;
+ (NSString*)xmlStringFromDateTime:(NSDateComponents*)dateTime;
+ (NSString*)characterStringFromDate:(NSDateComponents*)date;



+ (NSDateComponents*)dateComponentsFromString:(NSString*)dateString;
+ (NSDateComponents*)datetimeComponentsFromString:(NSString*)dateString;
+ (NSDateComponents*)timeComponentsFromDate:(NSDate*)date;
+ (NSDate*)dateFromString:(NSString*)dateString;

+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date;
+ (NSDateComponents*)dateComponentsFromYear:(int)year month:(int)month day:(int)day;
+ (NSDateComponents*)dateTimeComponentsFromDate:(NSDate*)date;

//+ (NSDateComponents*)gmtDateComponentsFromDate:(NSDate*)date;

+ (NSDate*)dateFromDateComponents:(NSDateComponents*)dateComponents;
//+ (NSDate*)gmtDateFromDateComponents:(NSDateComponents*)dateComponents;

+ (NSComparisonResult)compareDate:(NSDate*)date1 andDate:(NSDate*)date2;
+ (NSComparisonResult)compareDateComponents:(NSDateComponents*)dateComps1 andDateComponents:(NSDateComponents*)dateComps2;
+ (NSComparisonResult)compareDateTimeComponents:(NSDateComponents*)dateComps1 andDateTimeComponents:(NSDateComponents*)dateComps2;
+ (BOOL)isDateComponents:(NSDateComponents*)dateComps betweenDateComponents:(NSDateComponents*)dateComps1 andDateComponents:(NSDateComponents*)dateComps2;
+ (BOOL)isToday:(NSDateComponents*)dateComps;
+ (NSComparisonResult)compareWithToday:(NSDateComponents*)dateComps;

+ (void)addMonth:(int)month toDateComps:(NSDateComponents*)dateComps;

+ (NSString*)stringFromHour:(int)h minute:(int)m;
+ (NSString*)shortStringFromHour:(int)h minute:(int)m;
+ (NSString*)stringFromTime:(NSDateComponents*)timeComps;

+ (NSString*)stringAMPMFromHour:(int)h minute:(int)m;
+ (NSString*)shortStringAMPMFromHour:(int)h minute:(int)m;
+ (NSString*)stringAMPMFromTime:(NSDateComponents*)timeComps;

+ (NSString*)displayedStringFromDateTime:(NSDateComponents*)dateComps;

+ (NSDate*)today;
+ (NSDateComponents*)todayDateComps;

+ (BOOL)isCurrentMonth:(int)m year:(int)y;
+ (NSString *)dateToString:(NSDate *)date;

+ (NSDateComponents*)lastDateOfMonth:(int)month year:(int)year;
+ (int)getNumDays:(NSDateComponents *)fromDateComps toDate:(NSDateComponents *)toDateComps;
+ (int)getDiffDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;
+ (int)getDiffYearsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;
+ (NSDate *)getNextDateOf:(NSDate *)fromDate distanceDay:(int)distanceDay distanceMonth:(int)distanceMonth distanceYear:(int)distanceYear;

+ (int)getCurrentYear;
+ (int)getNumberOfDaysInMonth:(int)month year:(int)year;

+ (NSString*)displayedMonthYearStringForDateComps:(NSDateComponents*)dateComps;
+ (NSString*)displayedMonthYearStringFromDateComps:(NSDateComponents*)dateComps1 toDateComps:(NSDateComponents*)dateComps2;
+ (NSString *)getDateStringFrom:(NSDate *)date withFormat:(NSString *)format;
@end
