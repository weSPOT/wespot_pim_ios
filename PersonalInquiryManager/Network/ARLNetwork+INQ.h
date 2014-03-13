//
//  ARLNetwork+INQ.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork.h"
#import "INQLoginViewController.h"

//#define elgUrl @"http://wespot.kmi.open.ac.uk/services/api/rest/json/?method="
#define elgUrl @"http://inquiry.wespot.net/services/api/rest/json/?method="
//#define elgUrl @"http://dev.inquiry.wespot.net/services/api/rest/json/?method="
#define apiKey @"27936b77bcb9bb67df2965c6518f37a77a7ab9f8"

@interface ARLNetwork (INQ)

+ (id) getFriends : (NSString *) localId withProviderId: (NSNumber *) oauthProvider;
+ (id) getUsers;
+ (id) getInquiries: (NSString *) localId withProviderId: (NSNumber *) oauthProvider;
+ (id) getHypothesis:  (NSNumber *) inquiryId ;
+ (id) getNotes:  (NSNumber *) inquiryId ;

+ (NSString *) elggProviderId: (NSNumber *) oauthProvider;
+ (NSNumber*) elggProviderByName: (NSString  *) oauthProvider;

+ (NSNumber *) getARLearnRunId: (NSNumber* ) inquiryId;
+ (NSNumber *) getARLearnGameId: (NSNumber* ) inquiryId;

+ (BOOL)connectedToNetwork;

@end