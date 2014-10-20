//
//  INQCloudSynchronizer.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pthread.h>

#import "ARLAppDelegate.h"
#import "ARLNetwork+INQ.h"
#import "Account+Create.h"
#import "Inquiry+Create.h"
#import "Message+Create.h"

//#import "TestAccount+Lazy.h"

@interface INQCloudSynchronizer : NSObject

@property (nonatomic, readwrite) BOOL syncUsers;
@property (nonatomic, readwrite) BOOL syncInquiries;
@property (nonatomic, readwrite) BOOL syncInquiry;
@property (nonatomic, readwrite) BOOL syncInquiryUsers;
@property (nonatomic, readwrite) BOOL syncMessages;

@property (strong, nonatomic)  NSNumber *inquiryId;

@property (strong, nonatomic)  NSManagedObjectContext *context;
@property (strong, nonatomic)  NSManagedObjectContext *parentContext;

+ (void) syncUsers: (NSManagedObjectContext *) context;
+ (void) syncInquiries: (NSManagedObjectContext *) context;
+ (void) syncInquiry: (NSManagedObjectContext *) context inquiryId:(NSNumber *) inquiryId;
+ (void) syncInquiryUsers: (NSManagedObjectContext *) context inquiryId:(NSNumber *) inquiryId;
+ (void) syncMessages: (NSManagedObjectContext *) context inquiryId:(NSNumber *) inquiryId;

@end
