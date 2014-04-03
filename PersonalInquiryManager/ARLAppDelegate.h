//
//  ARLAppDelegate.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 6/13/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Reachability.h"

#import "Account+Create.h"
#import "INQCloudSynchronizer.h"

@interface ARLAppDelegate : UIResponder <UIApplicationDelegate>

+ (NSRecursiveLock *) theLock;

+ (NSString *) jsonString:(NSDictionary *) jsonDictionary;

- (NSInteger *) entityCount:(NSString *) entityName;
- (NSInteger *) entityCount:(NSString *) entityName predicate:(NSPredicate *) predicate;

+ (void) deleteAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name;

+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name;
+ (NSArray *) retrievAllOfEntity: (NSManagedObjectContext *) context enityName:(NSString *) name predicate:(NSPredicate *) predicate;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSNumber *isLoggedIn;
@property (readonly, strong, nonatomic) NSNumber *networkAvailable;

@end
 