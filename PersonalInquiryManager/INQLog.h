//
//  INQLog.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 6/23/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>

//#define INQLogFormat(s,...) \
//[MLog logFile:__FILE__ lineNumber:__LINE__ \
//format:(s),##__VA_ARGS__]
//
//#define \
//if (INQLog.LogOn) {\
//  NSLog([NSString )\
//}

/*!
 *  Log with date-time stamp using NSLog.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 *
 *  @return void
 */
#define DLog(fmt, ...) if (INQLog.LogOn) { NSLog(@"[%s:%d] "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); }

#define ELog(error) if (INQLog.LogOn && error) { NSLog(@"[%s:%d] %@ [%d]: %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error"), [error code], [error localizedDescription] ); }

#define EELog() if (INQLog.LogOn) { NSLog(@"[%s:%d] %@", __PRETTY_FUNCTION__, __LINE__, NSLocalizedString(@"Error", @"Error") ); }

/*!
 *  Log without date-time stamp using CFShow.
 *
 *  @param fmt The Format String
 *  @param ... The Arguments.
 *
 *  @return void
 */
#define CLog(fmt, ...) if (INQLog.LogOn) { CFShow((__bridge CFTypeRef)[NSString stringWithFormat:@"[%s:%d]| "fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]); }

@interface INQLog : NSObject

+ (BOOL *)LogOn;
+ (void)setLogOn:(BOOL *)value;

@end
