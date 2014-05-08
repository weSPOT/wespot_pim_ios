//
//  Response+Create.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/15/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Response+Create.h"

@implementation Response (Create)

/*!
 *  Creates a new Response in Core Data.
 *
 *  @param run     The Run.
 *  @param gi      The GeneralItem.
 *  @param value   The Response Value
 *  @param context The NSManagedObjectContext.
 *
 *  @return The newly created Response.
 */
+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                  withValue:(NSString *) value
     inManagedObjectContext: (NSManagedObjectContext *) context {
    Response *response = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext: context];
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

/*!
 *  Creates a new Response in Core Data.
 *
 *  @param run     The Run.
 *  @param gi      The GeneralItem.
 *  @param value   The Response Data
 *  @param context The NSManagedObjectContext.
 *
 *  @return The newly created Response.
 */
+ (Response *) initResponse: (Run *) run
             forGeneralItem:(GeneralItem *) gi
                   withData:(NSData *) data
     inManagedObjectContext: (NSManagedObjectContext *) context {
    
    Response *response = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext: context];
    
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

/*!
 *  Updated or inserts a Response found on the Server.
 *  Only for new records the responsId is savedß.
 *  For existing records, the synchronized is not touched.
 *
 *  @param respDict Should at least contain responseId, userEmail, generalItemId, runId and timestamp. Optional are [imageUrl, height, width] | videoUrl | audioUrl | text | number.
 *  @param context  The NSManagedObjectContext
 *
 *  @return The existing or newly created Response.
 */
+ (Response *) responseWithDictionary: (NSDictionary *) respDict
               inManagedObjectContext: (NSManagedObjectContext *) context {
    Response *response = [self retrieveFromDb:respDict withManagedContext:context];
    
    // deleted = 0;
    // generalItemId = 4596856252268544;
    // responseId = 4524418407596032;
    // responseValue = "{\"text\":\"\"}";
    // runId = 5117857260109824;
    // timestamp = 1395396382116;
    // type = "org.celstec.arlearn2.beans.run.Response";
    // userEmail = "2:101754523769925754305";
    
    if ([[respDict objectForKey:@"deleted"] boolValue]) {
        if (response) {
            //item is deleted
            [context deleteObject:response];
            response = nil;
        }
        return nil;
    }
    
    if (!response) {
        response = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext:context];
        
        // NOTE: Only newly downloaded responses are automatically marked as synced.
        //       The existing once do not have the synchronized field updated.
        response.synchronized = [NSNumber numberWithBool:YES];
        response.responseId = [NSNumber numberWithLongLong:[[respDict objectForKey:@"responseId"] longLongValue]];
    }
    
    NSError *e = nil;
    NSData *data = [[respDict objectForKey:@"responseValue"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *valueDict = [NSJSONSerialization JSONObjectWithData:data
                                                              options: NSJSONReadingMutableContainers
                                                                error: &e];
    
    // Set responseValue specific fields.
    if (valueDict) {
        if ([valueDict objectForKey:@"imageUrl"]) {
            response.height = [NSNumber numberWithInt:[[valueDict objectForKey:@"height"] integerValue]];
            response.width = [NSNumber numberWithInt:[[valueDict objectForKey:@"width"] integerValue]];
            response.fileName = [valueDict objectForKey:@"imageUrl"];
            response.contentType = @"application/jpg";
        } else if ([valueDict objectForKey:@"videoUrl"]) {
            response.fileName = [valueDict objectForKey:@"videoUrl"];
            response.contentType = @"video/quicktime";
        } else if ([valueDict objectForKey:@"audioUrl"]) {
            response.fileName = [valueDict objectForKey:@"audioUrl"];
            response.contentType = @"audio/aac";
        } else if ([valueDict objectForKey:@"text"]) {
#warning Implement Text
        } else if ([valueDict objectForKey:@"number"]) {
#warning Implement Number
        }
    }

    // Remove the account type to get the localAccountId?
    NSString *mail = [respDict objectForKey:@"userEmail"];
    NSString *type = [mail substringToIndex:1];
    mail = [mail stringByReplacingOccurrencesOfString:@"2:" withString:@""];
    
    // Set Linked Objects
    response.account = [Account retrieveFromDbWithLocalId:mail accountType:type withManagedContext:context];
    response.generalItem = [GeneralItem retrieveFromDbWithId:[NSNumber numberWithLongLong:[[respDict objectForKey:@"generalItemId"] longLongValue]]
                                          withManagedContext:context];
    response.run = [Run retrieveRun:[NSNumber numberWithLongLong:[[respDict objectForKey:@"runId"] longLongValue]]
             inManagedObjectContext:context];
    
    // Set TimeStamp.
    response.timeStamp = [NSNumber numberWithLongLong:[[respDict objectForKey:@"timestamp"] longLongValue]];
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
#warning schedule sync for file/url here?
    
    //    if (!response.data && response.fileName) {
    //        [ARLFileCloudSynchronizer syncResponses:context];
    //    }
    
    return response;
}

/*!
 *  Retrieve a Response from Core Data.
 *
 *  @param giDict  Should at least contain responseId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Response.
 */
+ (Response *) retrieveFromDb: (NSDictionary *) giDict withManagedContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"responseId = %lld", [[giDict objectForKey:@"responseId"] longLongValue]];
    
    NSError *error = nil;
    NSArray *responsesFromDb = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"error %@", error);
    }
    if (!responsesFromDb || ([responsesFromDb count] != 1)) {
        return nil;
    } else {
        return [responsesFromDb lastObject];
    }
}

/*!
 *  Get all Responses where synchronized is NO.
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of Responses.
 */
+ (NSArray *) getUnsyncedReponses: (NSManagedObjectContext *) context {
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
 *  Get all Responses where no media is downloaded (where data is NULL but fileName is !NULL).
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of Responses.
 */
+ (NSArray *) getReponsesWithoutMedia: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(data = %@ AND thumb = %@) AND fileName != %@", NULL, NULL, NULL];
    
    NSError *error = nil;
    NSArray *unsyncedResponses = [context executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"error %@", error);
    } else {
        NSLog(@"[%s] Found %d Responses without Media or Thumbnail", __func__, unsyncedResponses.count);
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
+ (NSString *) jsonString:(NSDictionary *) jsonDictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&error];
    
    return [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
}


/*!
 *  Create a Textual Response for a GeneralItem of a Run.
 *
 *  @param text        The Resoponse Text.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createTextResponse: (NSString *) text
                    withRun: (Run *)run
            withGeneralItem: (GeneralItem *) generalItem {
    NSDictionary *myDictionary= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 text, @"text", nil];
    
    [Response initResponse:run forGeneralItem:generalItem
                 withValue:[Response jsonString:myDictionary]
     
    inManagedObjectContext: generalItem.managedObjectContext];
}

/*!
 *  Create an Image Response for a GeneralItem of a Run.
 *
 *  @param data        The Image as NSData.
 *  @param width       The Image Width.
 *  @param height      The Image Height.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createImageResponse:(NSData *) data
                       width: (NSNumber *) width
                      height: (NSNumber *) height
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                       withData:data
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.width =width;
    response.height = height;
    response.contentType = @"application/jpg";
    response.fileName = @"jpg";
}

/*!
 *  Create an Video Response for a GeneralItem of a Run.
 *
 *  @param data        The Video as NSData.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createVideoResponse:(NSData *) data
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                       withData:data
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.contentType = @"video/quicktime";
    response.fileName = @"mov";
}

/*!
 *  Create an Audio Response for a GeneralItem of a Run.
 *
 *  @param data        The Audio as NSData.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createAudioResponse:(NSData *) data
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                       withData:data
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.contentType = @"audio/aac";
    response.fileName = @"m4a";
}

@end
