//
//  Response+Create.h
//  ARLearn
//
//  Created by Stefaan Ternier on 7/15/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Response.h"
#import "Run+ARLearnBeanCreate.h"
#import "Account+Create.h"
#import "GeneralItem+ARLearnBeanCreate.h"
#import "ARLFileCloudSynchronizer.h"

@interface Response (Create)

typedef NS_ENUM (NSInteger, ResponseTypes) {
    UNKNOWN = 0,
    PHOTO   = 1,
    VIDEO   = 2,
    AUDIO   = 3,
    TEXT    = 4,
    NUMBER  = 5
};

+ (Response *) responseWithDictionary: (NSDictionary *) respDict
               inManagedObjectContext: (NSManagedObjectContext *) context;

+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                  withValue:(NSString *) value
     inManagedObjectContext: (NSManagedObjectContext *) context;

+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                   withData:(NSData *) data
     inManagedObjectContext:(NSManagedObjectContext *) context;

+ (NSArray *) getUnsyncedReponses: (NSManagedObjectContext *) context;

+ (NSArray *) getRevokedReponses: (NSManagedObjectContext *) context;

+ (NSArray *) getReponsesWithoutMedia: (NSManagedObjectContext *) context
                        generalItemId:(NSNumber *) generalItemId;

+ (NSArray *) getMyReponsesWithoutMedia: (NSManagedObjectContext *) context;

+ (void) createTextResponse:(NSString *) text
                    withRun:(Run*)run
            withGeneralItem:(GeneralItem *) generalItem;

+ (void) createValueResponse:(NSString *) value
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *) generalItem;

+ (void) createImageResponse:(NSData *) imageUrl
                       width:(NSNumber*) width
                      height:(NSNumber *) height
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *) generalItem;

+ (void) createVideoResponse:(NSData *) data
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *) generalItem;

+ (void) createAudioResponse:(NSData *) data
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *) generalItem
                    fileName:(NSString *) fileName;

@end
