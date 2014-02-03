//
//  INQCloudSynchronizer.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARLAppDelegate.h"
#import "ARLNetwork+INQ.h"
#import "Account+Create.h"
#import "Inquiry+Create.h"

@interface INQCloudSynchronizer : NSObject

@property (nonatomic, readwrite) BOOL syncUsers;
@property (nonatomic, readwrite) BOOL syncInquiries;

@property (strong, nonatomic)  NSManagedObjectContext * context;
@property (strong, nonatomic)  NSManagedObjectContext * parentContext;

+ (void) syncUsers: (NSManagedObjectContext*) context;
+ (void) syncInquiries: (NSManagedObjectContext*) context;

@end
