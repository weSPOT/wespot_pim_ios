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

@interface ARLNetwork (INQ)

//+(NSString *) elgUrl;
+(NSString *) elgBaseUrl;

+(BOOL) elgDeveloperMode;

+(NSInteger *) defaultInquiryVisibility;
+(NSInteger *) defaultInquiryMembership;

+ (id) createInquiry: (NSString *)title description:(NSString *)description visibility: (NSNumber *) visibility membership: (NSNumber *) membership;

+ (id) getFriends: (NSString *) localId withProviderId: (NSNumber *) oauthProvider;
+ (id) getUsers;
+ (id) getInquiries: (NSString *) localId withProviderId: (NSNumber *) oauthProvider;

+ (id) getInquiryUsers: (NSString *) localId withProviderId: (NSNumber *) oauthProvider inquiryId: (NSNumber *) inquiryId;

+ (id) getHypothesis: (NSNumber *) inquiryId;
+ (id) getQuestions: (NSNumber *) inquiryId;
+ (id) getReflection:  (NSNumber *) inquiryId;
+ (id) getNotes: (NSNumber *) inquiryId;
+ (id) getFiles: (NSNumber *) inquiryId;
+ (id) getSchools;

+ (NSString *) elggProviderId: (NSNumber *) oauthProvider;
+ (NSNumber *) elggProviderByName: (NSString  *) oauthProvider;

+ (NSNumber *) getARLearnRunId: (NSNumber* ) inquiryId;
+ (NSNumber *) getARLearnGameId: (NSNumber* ) inquiryId;

+ (BOOL)networkAvailable;
+ (BOOL)isLoggedIn;

+ (void)ShowAbortMessage: (NSString *) title message:(NSString *) message;
+ (void)ShowAbortMessage: (NSError *) error func:(NSString *)func;

+ (Account *) CurrentAccount;

@end
