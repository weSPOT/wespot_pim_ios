//
//  ARLFileCloudSynchronizer.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/16/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#include <pthread.h>

#import "ARLNetwork.h"
#import "ARLAppDelegate.h"
#import "GeneralItemData+Extra.h"

@interface ARLFileCloudSynchronizer : NSObject

@property (strong, nonatomic)  NSManagedObjectContext *context;
@property (strong, nonatomic)  NSManagedObjectContext *parentContext;

@property (nonatomic, readwrite) BOOL syncGeneralItems;
@property (nonatomic, readwrite) BOOL syncResponses;
@property (nonatomic, readwrite) BOOL syncMyResponses;
@property (nonatomic, readwrite) NSNumber *generalItemId;

@property (strong, nonatomic)  NSNumber *responseType;

- (void) createContext: (NSManagedObjectContext*) mainContext;

- (void) sync;

+ (void) syncGeneralItems: (NSManagedObjectContext *) context;
+ (void) syncResponseData: (NSManagedObjectContext *) context
            generalItemId: (NSNumber *) generalItemId
             responseType: (NSNumber *) responseType;
+ (void) syncMyResponseData: (NSManagedObjectContext *) context
               responseType: (NSNumber *) responseType;
@end
