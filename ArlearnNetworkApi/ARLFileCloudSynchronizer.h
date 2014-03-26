//
//  ARLFileCloudSynchronizer.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/16/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pthread.h>

#import "ARLNetwork.h"
#import "ARLAppDelegate.h"
#import "GeneralItemData+Extra.h"

@interface ARLFileCloudSynchronizer : NSObject

@property (strong, nonatomic)  NSManagedObjectContext * context;
@property (strong, nonatomic)  NSManagedObjectContext * parentContext;

@property (nonatomic, readwrite) BOOL syncGeneralItems;
@property (nonatomic, readwrite) BOOL syncResponses;

- (void) createContext: (NSManagedObjectContext*) mainContext;

- (void) sync;

+ (void) syncGeneralItems: (NSManagedObjectContext*) context;
+ (void) syncResponseData: (NSManagedObjectContext*) context;

//+ (void)downloadImageWithURL:(Response *)resp completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;

@end
