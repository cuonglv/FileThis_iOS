//
//  DateHandler.m
//  TKD
//
//  Created by decuoi on 5/30/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "DateHandler.h"
#import "Constants.h"


@implementation DateHandler


+ (NSString*)yyyyMMddStringFromDateComps:(NSDateComponents*)dateComps {
    NSString *result = [NSString stringWithFormat:@"%i", dateComps.year];
    
    if (dateComps.month < 10)
        result = [result stringByAppendingFormat:@"-0%i", dateComps.month];
    else
        result = [result stringByAppendingFormat:@"-%i", dateComps.month];
    
    if (dateComps.day < 10)
        result = [result stringByAppendingFormat:@"-0%i", dateComps.day];
    else
        result = [result stringByAppendingFormat:@"-%i", dateComps.day];
    
    return result;
}

+ (NSString*)stringFromYear:(int)year month:(int)month day:(int)day {
    NSString *result = [NSString stringWithFormat:@"%i", year];
    
    if (month < 10)
        result = [result stringByAppendingFormat:@"-0%i", month];
    else
        result = [result stringByAppendingFormat:@"-%i", month];
    
    if (day < 10)
        result = [result stringByAppendingFormat:@"-0%i", day];
    else
        result = [result stringByAppendingFormat:@"-%i", day];
    
    return result;
}

+ (NSString*)displayedStringFromYear:(int)year month:(int)month day:(int)day {
    NSString *result;
    
    if (month < 10)
        result = [NSString stringWithFormat:@"0%i", month];
    else
        result = [NSString stringWithFormat:@"%i", month];
    
    if (day < 10)
        result = [result stringByAppendingFormat:@"/0%i", day];
    else
        result = [result stringByAppendingFormat:@"/%i", day];
    
    result = [result stringByAppendingFormat:@"/%i", year];
    
    return result;
}

+ (NSString*)characterStringFromYear:(int)year month:(int)month day:(int)day {
    NSString *result = [kMonthsOfYear objectAtIndex:month-1];
    
    if (day < 10)
        result = [result stringByAppendingFormat:@" 0%i", day];
    else
        result = [result stringByAppendingFormat:@" %i", day];
    
    result = [result stringByAppendingFormat:@", %i", year];
    
    return result;
}

+ (NSString*)stringFromDate:(NSDateComponents*)date {
    return [DateHandler stringFromYear:date.year month:date.month day:date.day];
}

+ (NSString*)displayedStringFromDate:(NSDateComponents*)date {
    if (date)
        return [DateHandler displayedStringFromYear:date.year month:date.month day:date.day];
    else
        return @"";
}

+ (NSString*)stringFromDateTime:(NSDateComponents*)date {
    NSString *result = [NSString stringWithFormat:@"%i", date.year];
    
    if (date.month < 10)
        result = [result stringByAppendingFormat:@"-0%i", date.month];
    else
        result = [result stringByAppendingFormat:@"-%i", date.month];
    
    if (date.day < 10)
        result = [result stringByAppendingFormat:@"-0%i", date.day];
    else
        result = [result stringByAppendingFormat:@"-%i", date.day];
    
    if (date.hour < 10)
        result = [result stringByAppendingFormat:@" 0%i", date.hour];
    else
        result = [result stringByAppendingFormat:@" %i", date.hour];
    
    if (date.minute < 10)
        result = [result stringByAppendingFormat:@":0%i", date.minute];
    else
        result = [result stringByAppendingFormat:@":%i", date.minute];
    
    return result;
}

+ (NSString*)stringFromFullDateTime:(NSDateComponents*)date {
    NSString *result = [NSString stringWithFormat:@"%i", date.year];
    
    if (date.month < 10)
        result = [result stringByAppendingFormat:@"-0%i", date.month];
    else
        result = [result stringByAppendingFormat:@"-%i", date.month];
    
    if (date.day < 10)
        result = [result stringByAppendingFormat:@"-0%i", date.day];
    else
        result = [result stringByAppendingFormat:@"-%i", date.day];
    
    if (date.hour < 10)
        result = [result stringByAppendingFormat:@" 0%i", date.hour];
    else
        result = [result stringByAppendingFormat:@" %i", date.hour];
    
    if (date.minute < 10)
        result = [result stringByAppendingFormat:@":0%i", date.minute];
    else
        result = [result stringByAppendingFormat:@":%i", date.minute];
    
    if (date.second < 10)
        result = [result stringByAppendingFormat:@":0%i", date.second];
    else
        result = [result stringByAppendingFormat:@":%i", date.second];
    
    return result;
}

+ (NSString*)xmlStringFromDate:(NSDateComponents*)date {
    return [NSString stringWithFormat:@"%@ 00:00:00.000 GMT",[DateHandler stringFromYear:date.year month:date.month day:date.day]];
}

+ (NSString*)xmlStringFromDateTime:(NSDateComponents*)dateTime {
    return [NSString stringWithFormat:@"%@:00.000 GMT",[DateHandler stringFromDateTime:dateTime]];
}

+ (NSString*)characterStringFromDate:(NSDateComponents*)date {
    return [DateHandler characterStringFromYear:date.year month:date.month day:date.day];
}

+ (NSDateComponents*)dateComponentsFromString:(NSString*)dateString {
    if ([dateString length] < 10)
        return nil;
    
    NSDateComponents *result = [[NSDateComponents alloc] init];
    result.year = [[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
    result.month = [[dateString substringWithRange:NSMakeRange(5, 2)] intValue];
    result.day = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
    return result;
}

+ (NSDateComponents*)datetimeComponentsFromString:(NSString*)dateString {
    if ([dateString length] < 20)
        return nil;
    
    NSDateComponents *result = [[NSDateComponents alloc] init];
    result.year = [[dateString substringWithRange:NSMakeRange(0, 4)] intValue];
    result.month = [[dateString substringWithRange:NSMakeRange(5, 2)] intValue];
    result.day = [[dateString substringWithRange:NSMakeRange(8, 2)] intValue];
    result.hour = [[dateString substringWithRange:NSMakeRange(11, 2)] intValue];
    result.minute = [[dateString substringWithRange:NSMakeRange(14, 2)] intValue];
    result.second = [[dateString substringWithRange:NSMakeRange(17, 2)] intValue];
    return result;
}

+ (NSDate*)dateFromString:(NSString*)dateString {
    NSDateComponents *comps = [DateHandler dateComponentsFromString:dateString];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar dateFromComponents:comps];
}

+ (NSDateComponents*)dateComponentsFromDate:(NSDate*)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
}

+ (NSDateComponents*)dateComponentsFromYear:(int)year month:(int)month day:(int)day {
    NSDateComponents *ret = [[NSDateComponents alloc] init];
    ret.year = year;
    ret.month = month;
    ret.day = day;
    return ret;
}

/* + (NSDateComponents*)gmtDateComponentsFromDate:(NSDate*)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
} */

+ (NSDateComponents*)dateTimeComponentsFromDate:(NSDate*)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
}

+ (NSDateComponents*)timeComponentsFromDate:(NSDate*)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:date];
}

+ (NSDate*)dateFromDateComponents:(NSDateComponents*)dateComponents {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar dateFromComponents:dateComponents];
}

/* + (NSDate*)gmtDateFromDateComponents:(NSDateComponents*)dateComponents {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return [calendar dateFromComponents:dateComponents];
} */

+ (NSComparisonResult)compareDate:(NSDate*)date1 andDate:(NSDate*)date2 { //nil = infinite date (very small date)
    if (date2 == nil) {
        if (date1) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
    
    if (date1 == nil) // && date2 != nil
        return NSOrderedAscending;
    
    float difference = [date1 timeIntervalSinceDate:date2];
    if (difference < 0)
        return NSOrderedAscending;
    else if (difference == 0)
        return NSOrderedSame;
    else
        return NSOrderedDescending;
}

+ (NSComparisonResult)compareDateComponents:(NSDateComponents*)dateComps1 andDateComponents:(NSDateComponents*)dateComps2 { //nil = infinite date (very small date)
    if (dateComps2 == nil) {
        if (dateComps1) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
    
    if (dateComps1 == nil) // && date2 != nil
        return NSOrderedAscending;
    
    if (dateComps1.year < dateComps2.year) {
        return NSOrderedAscending;
    } else if (dateComps1.year > dateComps2.year) {
        return NSOrderedDescending;
    } else if (dateComps1.month < dateComps2.month) {   //now, years are equal
        return NSOrderedAscending;
    } else if (dateComps1.month > dateComps2.month) {
        return NSOrderedDescending;
    } else if (dateComps1.day < dateComps2.day) {   //now, months are equal
        return NSOrderedAscending;
    } else if (dateComps1.day > dateComps2.day) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

+ (NSComparisonResult)compareDateTimeComponents:(NSDateComponents*)dateComps1 andDateTimeComponents:(NSDateComponents*)dateComps2 { //nil = infinite date (very large date)
    NSComparisonResult ret = [DateHandler compareDateComponents:dateComps1 andDateComponents:dateComps2];
    if (ret == NSOrderedSame) {
        if (dateComps1.hour < dateComps2.hour) {
            return NSOrderedAscending;
        } else if (dateComps1.hour > dateComps2.hour) {
            return NSOrderedDescending;
        } else if (dateComps1.minute < dateComps2.minute) {   //now, years are equal
            return NSOrderedAscending;
        } else if (dateComps1.minute > dateComps2.minute) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }
    return ret;
}

+ (BOOL)isDateComponents:(NSDateComponents*)dateComps betweenDateComponents:(NSDateComponents*)dateComps1 andDateComponents:(NSDateComponents*)dateComps2 {
    NSComparisonResult result = [DateHandler compareDateComponents:dateComps1 andDateComponents:dateComps];
    if (result == NSOrderedDescending)
        return NO;
    
    result = [DateHandler compareDateComponents:dateComps andDateComponents:dateComps2];
    if (result == NSOrderedDescending)
        return NO;
    
    return YES;
}

+ (BOOL)isToday:(NSDateComponents*)dateComps {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayDateComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    return (dateComps.year == todayDateComps.year && dateComps.month == todayDateComps.month && dateComps.day == todayDateComps.day);
}


+ (NSComparisonResult)compareWithToday:(NSDateComponents*)dateComps {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayDateComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    return [DateHandler compareDateComponents:dateComps andDateComponents:todayDateComps];
}

+ (void)addMonth:(int)monthAdded toDateComps:(NSDateComponents*)dateComps {
    int newMonth = monthAdded + dateComps.month;
    if (newMonth > 0) {
        while (newMonth > 12) {
            dateComps.year++;
            newMonth -= 12;
        }
    } else {
        while (newMonth < 0) {
            dateComps.year--;
            newMonth += 12;
        }
    }
    dateComps.month = newMonth;
    
    if (newMonth == 4 || newMonth == 6 || newMonth == 9 || newMonth == 11) {
        if (dateComps.day > 30)
            dateComps.day = 30;
    } else if (newMonth == 2) {
        if (dateComps.year % 4 == 0 && dateComps.year % 100 != 0) { //leap year
            if (dateComps.day > 29)
                dateComps.day = 29;
        } else {
            if (dateComps.day > 28)
                dateComps.day = 28;
        }
    }
}

+ (NSString*)stringFromHour:(int)h minute:(int)m {
    NSString *ret;
    if (h < 10)
        ret = [NSString stringWithFormat:@"0%i",h];
    else
        ret = [NSString stringWithFormat:@"%i",h];
    
    if (m < 10)
        ret = [ret stringByAppendingFormat:@":0%i",m];
    else
        ret = [ret stringByAppendingFormat:@":%i",m];
    
    return ret;
}

+ (NSString*)shortStringFromHour:(int)h minute:(int)m {
    NSString *ret;
    ret = [NSString stringWithFormat:@"%i",h];
    
    if (m < 10)
        ret = [ret stringByAppendingFormat:@":0%i",m];
    else
        ret = [ret stringByAppendingFormat:@":%i",m];
    
    return ret;
}

+ (NSString*)stringFromTime:(NSDateComponents*)timeComps {
    return [DateHandler stringFromHour:timeComps.hour minute:timeComps.minute];
}

+ (NSString*)stringAMPMFromHour:(int)h minute:(int)m {
    NSString *ret;
    
    if (h == 0) {
        h = 12;
        ret = @"AM";
    } else if (h == 12) {
        ret = @"PM";
    } else if (h > 12) {
        h -= 12;
        ret = @"PM";
    } else
        ret = @"AM";
    
    if (m < 10)
        ret = [NSString stringWithFormat:@"0%i %@",m,ret];
    else
        ret = [NSString stringWithFormat:@"%i %@",m,ret];
    
    return [NSString stringWithFormat:@"%i:%@",h,ret];
}

+ (NSString*)shortStringAMPMFromHour:(int)h minute:(int)m {
    NSString *ret;
    
    if (h == 0) {
        h = 12;
        ret = @"AM";
    } else if (h == 12) {
        ret = @"PM";
    } else if (h > 12) {
        h -= 12;
        ret = @"PM";
    } else
        ret = @"AM";
    
    if (m == 0)
        return [NSString stringWithFormat:@"%i%@",h,ret];   //for example: 4PM
    
    if (m < 10)
        ret = [NSString stringWithFormat:@"0%i%@",m,ret];
    else
        ret = [NSString stringWithFormat:@"%i%@",m,ret];
    
    return [NSString stringWithFormat:@"%i:%@",h,ret];
}

+ (NSString*)stringAMPMFromTime:(NSDateComponents*)timeComps {
    return [DateHandler stringAMPMFromHour:timeComps.hour minute:timeComps.minute];
}

+ (NSString*)displayedStringFromDateTime:(NSDateComponents*)dateComps {
    NSString *ret;
    
    if (dateComps.month < 10)
        ret = [NSString stringWithFormat:@"0%i",dateComps.month];
    else
        ret = [NSString stringWithFormat:@"%i",dateComps.month];
    
    if (dateComps.day < 10)
        ret = [ret stringByAppendingFormat:@"/0%i",dateComps.day];
    else
        ret = [ret stringByAppendingFormat:@"/%i",dateComps.day];
    
    ret = [ret stringByAppendingFormat:@"/%i",dateComps.year];
    
    if (dateComps.hour < 10)
        ret = [ret stringByAppendingFormat:@" 0%i",dateComps.hour];
    else
        ret = [ret stringByAppendingFormat:@" %i",dateComps.hour];
    
    if (dateComps.minute < 10)
        ret = [ret stringByAppendingFormat:@":0%i",dateComps.minute];
    else
        ret = [ret stringByAppendingFormat:@":%i",dateComps.minute];
    
    return ret;
}

+ (NSDate*)today {  //today 00:00:00
    return [DateHandler dateFromDateComponents:[DateHandler dateComponentsFromDate:[NSDate date]]];
}

+ (NSDateComponents*)todayDateComps {
    return [DateHandler dateComponentsFromDate:[NSDate date]];
}

+ (BOOL)isCurrentMonth:(int)m year:(int)y {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComps = [calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    return (dateComps.month == m && dateComps.year == y);
}

+ (NSString *)dateToString:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    
    return stringFromDate;
}

+ (NSDateComponents*)lastDateOfMonth:(int)month year:(int)year {
    int finalDayOfMonth;
    
    if (month == 2) {
        if (year % 4 == 0 && year % 100 != 0)
            finalDayOfMonth = 29;
        else
            finalDayOfMonth = 28;
    } else if (month == 4 || month == 6 || month == 9 || month == 11)
        finalDayOfMonth = 30;
    else
        finalDayOfMonth = 31;
    
    NSDateComponents *ret = [[NSDateComponents alloc] init];
    ret.year = year;
    ret.month = month;
    ret.day = finalDayOfMonth;
    
    return ret;
}

+ (int)getNumDays:(NSDateComponents *)fromDateComps toDate:(NSDateComponents *)toDateComps {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:[DateHandler dateFromDateComponents:fromDateComps] toDate:[DateHandler dateFromDateComponents:toDateComps] options:0];
    return components.day;
}

+ (int)getDiffDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    return components.day;
}

+ (int)getDiffYearsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit fromDate:startDate toDate:endDate options:0];
    return components.year;
}

+ (NSDate *)getNextDateOf:(NSDate *)fromDate distanceDay:(int)distanceDay distanceMonth:(int)distanceMonth distanceYear:(int)distanceYear {
    NSDateComponents* deltaComps = [[NSDateComponents alloc] init];
    [deltaComps setDay:distanceDay];
    [deltaComps setMonth:distanceMonth];
    [deltaComps setYear:distanceYear];
    return [[NSCalendar currentCalendar] dateByAddingComponents:deltaComps toDate:fromDate options:0];
}

+ (int)getCurrentYear {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *yearComp = [calendar components:NSYearCalendarUnit fromDate:date];
    return yearComp.year;
}

+ (int)getNumberOfDaysInMonth:(int)month year:(int)year {
    if (month == 4 || month == 6 || month == 9 || month == 11)
        return 30;
    
    if (month == 2) {
        if (year % 4 == 0 && year % 100 != 0) //leap year
            return 29;
        
        return 28;
    }
    
    return 31;
}

+ (NSString*)displayedMonthYearStringForDateComps:(NSDateComponents*)dateComps {
    if (dateComps.day == -1) {
        if (dateComps.month == -1) {
            return [NSString stringWithFormat:@"%i",dateComps.year];
        } else {
            return [NSString stringWithFormat:@"%@, %i", [kShortMonthsOfYear objectAtIndex:dateComps.month-1],dateComps.year];
        }
    } else {
        NSString *dayString;
        if (dateComps.day < 10)
            dayString = [NSString stringWithFormat:@"0%i",dateComps.day];
        else
            dayString = [NSString stringWithFormat:@"%i",dateComps.day];
        
        return [NSString stringWithFormat:@"%@ %@, %i",[kShortMonthsOfYear objectAtIndex:dateComps.month-1],dayString,dateComps.year];
    }
}

+ (NSString*)displayedMonthYearStringFromDateComps:(NSDateComponents*)dateComps1 toDateComps:(NSDateComponents*)dateComps2 {
    if ([DateHandler compareDateComponents:dateComps1 andDateComponents:dateComps2] == NSOrderedSame)
        return [DateHandler displayedMonthYearStringForDateComps:dateComps1];
    
    return [NSString stringWithFormat:@"%@ - %@",[DateHandler displayedMonthYearStringForDateComps:dateComps1],[DateHandler displayedMonthYearStringForDateComps:dateComps2]];
}

+ (NSString *)getDateStringFrom:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

@end
