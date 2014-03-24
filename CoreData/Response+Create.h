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

+ (Response *) responseWithDictionary: (NSDictionary *) respDict inManagedObjectContext: (NSManagedObjectContext * ) context;

+ (Response *) initResponse: (Run *) run forGeneralItem:(GeneralItem *) gi withValue:(NSString *) value inManagedObjectContext: (NSManagedObjectContext * ) context;
+ (Response *) initResponse: (Run *) run forGeneralItem:(GeneralItem *) gi withData:(NSData *) data inManagedObjectContext:(NSManagedObjectContext * ) context;

+ (NSArray *) getUnsyncedReponses: (NSManagedObjectContext*) context;
+ (NSArray *) getReponsesWithoutMedia: (NSManagedObjectContext*) context;

+ (void) createTextResponse: (NSString *) text withRun: (Run*)run withGeneralItem: (GeneralItem*) generalItem ;
+ (void) createImageResponse:(NSData *) imageUrl width: (NSNumber*) width height: (NSNumber*) height withRun: (Run*)run withGeneralItem: (GeneralItem*) generalItem;
+ (void) createVideoResponse:(NSData *) data
                     withRun: (Run*)run
             withGeneralItem: (GeneralItem*) generalItem;
+ (void) createAudioResponse:(NSData *) data
                     withRun: (Run*)run
             withGeneralItem: (GeneralItem*) generalItem;

@end
