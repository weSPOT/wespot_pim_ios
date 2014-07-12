//
//  INQLog.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 6/23/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>

/*!
 *  Log with date-time stamp using NSLog.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define DLog(fmt, ...) if (INQLog.LogOn) { NSLog(@"[%s:%d] "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

/*!
 *  Log error with date-time stamp using NSLog.
 *
 *  @param error The NSError to log.
 */
#define ELog(error) if (INQLog.LogOn && error) { NSLog(@"[%s:%d] %@ [%d]: %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error"), [error code], [error localizedDescription] ); }

/*!
 *  Log an error message with date-time stamp using NSLog.
 */
#define EELog() if (INQLog.LogOn) { NSLog(@"[%s:%d] %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error") ); }

/*!
 *  Log message without date-time stamp using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define CLog(fmt, ...) if (INQLog.LogOn) { CFShow((__bridge CFTypeRef)[NSString stringWithFormat:@"[%s:%d]| "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]); }

/*!
 *  Log message without date-time stamp using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define Log(fmt, ...) CFShow((__bridge CFTypeRef)[NSString stringWithFormat:@"[%s:%d]| "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]);

/*!
 *  Log message without date-time stamp or function:line using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 */
#define RawLog(fmt, ...) CFShow((__bridge CFTypeRef)[NSString stringWithFormat:fmt, ##__VA_ARGS__]);

@interface INQLog : NSObject

+ (BOOL *)LogOn;
//+ (void)setLogOn:(BOOL *)value;

@end
