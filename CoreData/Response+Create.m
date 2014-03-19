//
//  Response+Create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/15/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Response+Create.h"

@implementation Response (Create)

+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                  withValue:(NSString *) value
     inManagedObjectContext: (NSManagedObjectContext * ) context {
    Response * response = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext: context];
    response.value = value;
    response.generalItem = gi;
    
    response.run = run;
    response.synchronized = [NSNumber numberWithBool:NO];
    response.timeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return response;
}

+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                   withData:(NSData *) data
     inManagedObjectContext: (NSManagedObjectContext * ) context {
    Response * response = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext: context];
    response.value = nil;
    response.data = data;
    response.generalItem = gi;
    response.run = run;
    response.synchronized = [NSNumber numberWithBool:NO];
    response.timeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return response;
}

//+ (void) deleteAll: (NSManagedObjectContext * ) context {
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
//    
//    NSError *error = nil;
//    NSArray *responses = [context executeFetchRequest:request error:&error];
//    if (error) {
//        NSLog(@"error %@", error);
//    }
//    for (id response in responses) {
//        [context deleteObject:response];
//    }
//    
//    error = nil;
//    [context save:&error];
//    if (error) {
//        NSLog(@"[%s] error %@", __func__, error);
//    }
//}

+ (NSArray *) getUnsyncedReponses: (NSManagedObjectContext*) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"synchronized = %d", NO];
    
    NSError *error = nil;
    NSArray *unsyncedResponses = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"error %@", error);
    }
    
    return unsyncedResponses;
}

/*!
 *  Convert NSDictionary to a JSON NSString.
 *
 *  @param jsonDictionary The NSDictionary to convert.
 *
 *  @return The resulting JSON NSString.
 */
+ (NSString*) jsonString:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&error];
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}

+ (void) createTextResponse: (NSString *) text
                    withRun: (Run *)run
            withGeneralItem: (GeneralItem *) generalItem {
    NSDictionary *myDictionary= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 text, @"text", nil];

    [Response initResponse:run forGeneralItem:generalItem
                 withValue:[Response jsonString:myDictionary]
    inManagedObjectContext: generalItem.managedObjectContext];
}

+ (void) createImageResponse:(NSData *) data
                       width: (NSNumber *) width
                       height: (NSNumber *) height
                     withRun: (Run*)run
             withGeneralItem: (GeneralItem *) generalItem {
    
   Response * response = [Response initResponse:run
            forGeneralItem:generalItem
                 withData:data
    inManagedObjectContext: generalItem.managedObjectContext];
    response.width =width;
    response.height = height;
    response.contentType = @"application/jpg";
    response.fileName = @"jpg";
}

+ (void) createVideoResponse:(NSData *) data
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    
    Response * response = [Response initResponse:run
                                  forGeneralItem:generalItem
                                        withData:data
                          inManagedObjectContext: generalItem.managedObjectContext];
    response.contentType = @"video/quicktime";
    response.fileName = @"mov";
}

+ (void) createAudioResponse:(NSData *) data
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    
    Response * response = [Response initResponse:run
                                  forGeneralItem:generalItem
                                        withData:data
                          inManagedObjectContext: generalItem.managedObjectContext];
    response.contentType = @"audio/aac";
    response.fileName = @"m4a";
}

@end
