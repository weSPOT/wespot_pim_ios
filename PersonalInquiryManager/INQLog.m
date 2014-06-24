//
//  INQLog.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 6/23/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//


#import "INQLog.h"
#import "ARLAppDelegate.h"

/*!
 *  See http://iphonedevsdk.com/forum/iphone-sdk-development/6319-a-better-nslog-selectively-turning-logging-off.html
 *  See http://stackoverflow.com/questions/969130/how-to-print-out-the-method-name-and-line-number-and-conditionally-disable-nslog
 *  See http://github.com/InderKumarRathore/MLog/blob/master/MLog.h
 */

@implementation INQLog

static BOOL _logOn = YES;

//+ (void)setLogOn:(BOOL *)value
//{
//	_logOn = value;
//    
//}

+ (BOOL *)LogOn {
    _logOn = [[NSUserDefaults standardUserDefaults] boolForKey:ENABLE_LOGGING];
    return _logOn;
}

@end
