//
//  ARLNetwork+INQ.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <UIKit/UIKit.h>

#import "ARLNetwork.h"
#import "INQLoginViewController.h"

////#define elgUrl @"http://wespot.kmi.open.ac.uk/services/api/rest/json/?method="
////dev.
//#define elgBaseUrl @"http://dev.inquiry.wespot.net/services/api/rest/json/"
//
//#define elgUrl @"http://dev.inquiry.wespot.net/services/api/rest/json/?method="
//
////#define elgUrl @"http://inquiry.wespot.net/services/api/rest/json/?method="

#define apiKey @"27936b77bcb9bb67df2965c6518f37a77a7ab9f8"

#define MISSING_ID 3639020

@interface ARLNetwork (INQ)

+(NSString *) elgUrl;
+(NSString *) elgBaseUrl;
+(BOOL) elgDeveloperMode;

//@property (readonly, nonatomic) NSString *elgUrl;
//@property (readonly, nonatomic) NSString *elgBaseUrl;

+ (id) createInquiry: (NSString *)title description: (NSString *)description;

+ (id) getFriends: (NSString *) localId withProviderId: (NSNumber *) oauthProvider;
+ (id) getUsers;
+ (id) getInquiries: (NSString *) localId withProviderId: (NSNumber *) oauthProvider;

+ (id) getInquiryUsers: (NSString *) localId withProviderId: (NSNumber *) oauthProvider inquiryId: (NSNumber *) inquiryId;

+ (id) getHypothesis: (NSNumber *) inquiryId;
+ (id) getReflection:  (NSNumber *) inquiryId;
+ (id) getNotes: (NSNumber *) inquiryId;
+ (id) getFiles: (NSNumber *) inquiryId;

+ (NSString *) elggProviderId: (NSNumber *) oauthProvider;
+ (NSNumber *) elggProviderByName: (NSString  *) oauthProvider;

+ (NSNumber *) getARLearnRunId: (NSNumber* ) inquiryId;
+ (NSNumber *) getARLearnGameId: (NSNumber* ) inquiryId;

+ (BOOL)networkAvailable;
+ (BOOL)isLoggedIn;

+ (Account *) CurrentAccount;

@end
