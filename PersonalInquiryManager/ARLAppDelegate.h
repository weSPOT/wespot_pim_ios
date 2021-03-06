//
//  ARLAppDelegate.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 6/13/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "Reachability.h"

#import "Account+Create.h"
#import "INQCloudSynchronizer.h"
//#import "ARLNotificationSubscriber.h"

#define DEVELOPMENT_MODE    @"enable_development_mode"
#define PROXY_MODE          @"enable_proxy_mode"
#define INQUIRY_VISIBILITY  @"inquiry_visibility"
#define INQUIRY_MEMBERSHIP  @"inquiry_membership"
#define GIT_HASH            @"git_hash"
#define APP_VERSION         @"app_version"
#define MODEL_VERSION       @"model_version"
#define ENABLE_LOGGING      @"enable_logging"

@interface ARLAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>

+ (NSRecursiveLock *) theLock;
+ (NSCondition *) theAbortLock;

+ (BOOL) SyncAllowed;
+ (void) setSyncAllowed:(BOOL) value;

+ (CLLocationCoordinate2D) CurrentLocation;

+ (NSString *) jsonString:(NSDictionary *) jsonDictionary;

- (NSInteger *) entityCount:(NSString *) entityName;
- (NSInteger *) entityCount:(NSString *) entityName predicate:(NSPredicate *) predicate;

+ (void) deleteAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name;

+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name;
+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name predicate:(NSPredicate *) predicate;

- (void)doRegisterForAPN:(UIApplication *)application;

- (void) LogOut;

- (void) syncData;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSNumber *isLoggedIn;
@property (readonly, strong, nonatomic) NSNumber *networkAvailable;

@property (readonly, strong, nonatomic) Account *CurrentAccount;

@property (readonly, nonatomic) NSString *modelVersion;

@end
