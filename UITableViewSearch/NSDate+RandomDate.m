//
//  NSDate+RandomDate.m
//  UITableViewSearch
//
//  Created by Sergey Reshetnyak on 4/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import "NSDate+RandomDate.h"

@implementation NSDate (RandomDate)

- (NSDate *)randomDateInYearOfDate {
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [currentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    
    [comps setMonth:arc4random_uniform(12)];
    
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[currentCalendar dateFromComponents:comps]];
    
    [comps setDay:arc4random_uniform((int)range.length)];
    
    return [currentCalendar dateFromComponents:comps];
}

@end
