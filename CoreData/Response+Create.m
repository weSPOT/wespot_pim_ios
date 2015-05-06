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
    response.account = [ARLNetwork CurrentAccount];
    
    [INQLog SaveNLog:context];
    
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
    
    response.lat = [NSNumber numberWithDouble:(double)(ARLAppDelegate.CurrentLocation.latitude)];
    response.lng = [NSNumber numberWithDouble:(double)(ARLAppDelegate.CurrentLocation.longitude)];
    
    [INQLog SaveNLog:context];
    
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
               inManagedObjectContext: (NSManagedObjectContext *) context
{
    Response *response = [self retrieveFromDb:respDict withManagedContext:context];
    
    // deleted = 0;
    // generalItemId = 4596856252268544;
    // responseId = 4524418407596032;
    // responseValue = "{\"text\":\"\"}";
    // runId = 5117857260109824;
    // timestamp = 1395396382116;
    // type = "org.celstec.arlearn2.beans.run.Response";
    // userEmail = "2:101754523769925754305";
    // lat
    // lng
    
    if ([[respDict objectForKey:@"deleted"] boolValue] ||
        [[respDict objectForKey:@"revoked"] boolValue]) {
        if (response) {
            //item is deleted
            [context deleteObject:response];
            
            [INQLog SaveNLog:context];
            
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
    
    if ([response.responseId isEqualToNumber:[NSNumber numberWithInt:0]] &&
        [response.account.localId isEqualToString:[ARLNetwork CurrentAccount].localId] &&
        [response.account.accountType isEqualToNumber:[ARLNetwork CurrentAccount].accountType]
        ) {
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
            response.responseType = [NSNumber numberWithInt:PHOTO];
        } else if ([valueDict objectForKey:@"videoUrl"]) {
            response.fileName = [valueDict objectForKey:@"videoUrl"];
            response.contentType = @"video/quicktime";
            response.responseType = [NSNumber numberWithInt:VIDEO];
        } else if ([valueDict objectForKey:@"audioUrl"]) {
            response.fileName = [valueDict objectForKey:@"audioUrl"];
            if ([response.fileName hasSuffix:@".m4a"]) {
                response.contentType = @"audio/aac";
            } else  if ([response.fileName hasSuffix:@".mp3"]) {
                response.contentType = @"audio/mp3";
            } else  if ([response.fileName hasSuffix:@".amr"]) {
                response.contentType = @"audio/amr";
            } else {
                // Fallback.
                response.contentType = @"audio/aac";
            }
            response.responseType = [NSNumber numberWithInt:AUDIO];
        } else if ([valueDict objectForKey:@"text"]) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            response.value = jsonString;//[valueDict objectForKey:@"text"];
            response.responseType = [NSNumber numberWithInt:TEXT];
        } else if ([valueDict objectForKey:@"value"]) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            response.value = jsonString;//[valueDict objectForKey:@"value"];
            response.responseType = [NSNumber numberWithInt:NUMBER];
        }
    }
    
    // Remove the account type to get the localAccountId?
    NSString *mail = [respDict objectForKey:@"userEmail"];
    NSString *type = [mail substringToIndex:1];
    
    for (int i=INTERNAL ; i<numServices; i++) {
        mail = [mail stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d:",i] withString:@""];
    }
    
    // Set Linked Objects
    // Account *owner = [Account retrieveFromDbWithLocalId:mail accountType:type withManagedContext:context];
    Account *owner = [Account retrieveFromDbWithLocalId:mail
                                            accountType:type
                                     withManagedContext:context];
    
    if (owner) {
        response.account = owner;
    }
    
    response.generalItem = [GeneralItem retrieveFromDbWithId:[NSNumber numberWithLongLong:[[respDict objectForKey:@"generalItemId"] longLongValue]]
                                          withManagedContext:context];
    response.run = [Run retrieveRun:[NSNumber numberWithLongLong:[[respDict objectForKey:@"runId"] longLongValue]]
             inManagedObjectContext:context];
    
    // Set TimeStamp.
    response.timeStamp = [NSNumber numberWithLongLong:[[respDict objectForKey:@"timestamp"] longLongValue]];
    response.revoked = [NSNumber numberWithBool:NO];
    
    if (!response.account && [ARLNetwork networkAvailable]) {
        NSDictionary *acc = [ARLNetwork getUserInfo:response.run.runId
                                             userId:mail
                                         providerId:type];
        
        response.account = [Account accountWithDictionary:acc
                                   inManagedObjectContext:context];
    }
    
    [INQLog SaveNLog:context];

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
    ELog(error);
    
    if (!responsesFromDb || ([responsesFromDb count] != 1)) {
        
        // NOTE:    If no record found, try matching on responseId = 0, timestamp + account
        //          These will be the unsynced ones, where we do not know the responseId yet.
        //
        //          In responseWithDictionary the zero responseId will be replaced.
        //
        //          These records can only originate from us but an extra account check won't hurt!
        //
        NSFetchRequest *request2 = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
        request2.predicate = [NSPredicate predicateWithFormat:@"responseId = 0 and timeStamp = %lld && account.accountType = %d && account.localId = %@",
                              [[giDict objectForKey:@"timestamp"] longLongValue],
                              [[ARLNetwork CurrentAccount].accountType intValue],
                              [ARLNetwork CurrentAccount].localId
                              ];
        
        NSError *error2 = nil;
        NSArray *responsesFromDb2 = [context executeFetchRequest:request2 error:&error2];
        ELog(error2);
        
        if (!responsesFromDb2 || ([responsesFromDb2 count] != 1)) {
            return nil;
        } else {
            return [responsesFromDb2 lastObject];
        }
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
    
    request.predicate = [NSPredicate predicateWithFormat:@"synchronized=NULL OR synchronized=%d", NO];
    
    NSError *error = nil;
    NSArray *unsyncedResponses = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    return unsyncedResponses;
}

/*!
 *  Get all Responses where synchronized is NO.
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of Responses.
 */
+ (NSArray *) getRevokedReponses: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"revoked=%d", YES];
    
    NSError *error = nil;
    NSArray *revokedResponses = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    return revokedResponses;
}

/*!
 *  Get all Responses where no media is downloaded (where data is NULL but fileName is !NULL).
 *
 *  @param context The NSManagedObjectContext.
 *
 *  @return An array of Responses.
 */
+ (NSArray *) getReponsesWithoutMedia:(NSManagedObjectContext *)context
                        generalItemId:(NSNumber *) generalItemId {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(generalItem.generalItemId = %@ AND data = %@ AND thumb = %@) AND fileName != %@", generalItemId, NULL, NULL, NULL];
    
    NSError *error = nil;
    NSArray *unsyncedResponses = [context executeFetchRequest:request error:&error];
    if (error) {
        ELog(error);
    } else {
        // DLog(@"Found %d Responses without Media or Thumbnail", unsyncedResponses.count);
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
+ (NSArray *) getMyReponsesWithoutMedia: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Response"];
    
    Account *account = ARLNetwork.CurrentAccount;
    
    request.predicate = [NSPredicate predicateWithFormat:@"(data = %@ AND thumb = %@) AND fileName != %@ AND account.localId = %@ AND account.accountType = %@",
                         NULL, NULL, NULL,
                         account.localId, account.accountType];
    
    NSError *error = nil;
    NSArray *unsyncedResponses = [context executeFetchRequest:request error:&error];
    if (error) {
        ELog(error);
    } else {
        // DLog(@"Found %d Responses without Media or Thumbnail", unsyncedResponses.count);
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
 *  @param text        The Response Text.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createTextResponse: (NSString *) text
                    withRun: (Run *)run
            withGeneralItem: (GeneralItem *) generalItem {
    NSDictionary *myDictionary= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 text, @"text", nil];
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                      withValue:[Response jsonString:myDictionary]
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.responseType = [NSNumber numberWithInt:TEXT];
    response.revoked = [NSNumber numberWithBool:NO];
    response.synchronized = [NSNumber numberWithBool:NO];
}

/*!
 *  Create a Numerical Response for a GeneralItem of a Run.
 *
 *  @param value       The Response Value.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createValueResponse: (NSString *) value
                     withRun: (Run *)run
             withGeneralItem: (GeneralItem *) generalItem {
    NSDictionary *myDictionary= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 value, @"value", nil];
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                      withValue:[Response jsonString:myDictionary]
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.responseType = [NSNumber numberWithInt:NUMBER];
    response.revoked = [NSNumber numberWithBool:NO];
    response.synchronized = [NSNumber numberWithBool:NO];
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
+ (void) createImageResponse: (NSData *) data
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
    response.responseType = [NSNumber numberWithInt:PHOTO];
    
    u_int32_t random = arc4random();
    response.fileName =[NSString stringWithFormat:@"%u.%@", random, @"jpg"];
    
//    // Create thumb here...
    UIImage *img = [[UIImage alloc] initWithData:data];
    response.thumb = UIImageJPEGRepresentation([img thumbnailImage:320 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault], 1.0);
    
    response.account = [ARLNetwork CurrentAccount];
    response.revoked = [NSNumber numberWithBool:NO];
    response.synchronized = [NSNumber numberWithBool:NO];
}

/*!
 *  Create an Video Response for a GeneralItem of a Run.
 *
 *  @param data        The Video as NSData.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createVideoResponse:(NSData *)data
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *)generalItem {
    
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                       withData:data
                         inManagedObjectContext:generalItem.managedObjectContext];
    
    response.contentType = @"video/quicktime";
    response.responseType = [NSNumber numberWithInt:VIDEO];

    u_int32_t random = arc4random();
    response.fileName =[NSString stringWithFormat:@"%u.%@", random, @"mov"];
    
    response.account = [ARLNetwork CurrentAccount];
    response.revoked = [NSNumber numberWithBool:NO];
    response.synchronized = [NSNumber numberWithBool:NO];
}

/*!
 *  Create an Audio Response for a GeneralItem of a Run.
 *
 *  @param data        The Audio as NSData.
 *  @param run         The Run.
 *  @param generalItem The GeneralItem.
 */
+ (void) createAudioResponse:(NSData *)data
                     withRun:(Run *)run
             withGeneralItem:(GeneralItem *)generalItem
                    fileName:(NSString *)fileName
{
    Response *response = [Response initResponse:run
                                 forGeneralItem:generalItem
                                       withData:data
                         inManagedObjectContext:generalItem.managedObjectContext];
   
    if ([fileName hasSuffix:@".m4a"]) {
        response.contentType = @"audio/aac";
    } else  if ([fileName hasSuffix:@".mp3"]) {
        response.contentType = @"audio/mp3";
    } else  if ([fileName hasSuffix:@".amr"]) {
        response.contentType = @"audio/amr";
    } else {
        // Fallback.
        response.contentType = @"audio/aac";
    }

    response.responseType = [NSNumber numberWithInt:AUDIO];
    
    //    u_int32_t random = arc4random();
    response.fileName = fileName;//[NSString stringWithFormat:@"%u.%@", random, @"mp3"];
    
    response.account = [ARLNetwork CurrentAccount];
    response.revoked = [NSNumber numberWithBool:NO];
    response.synchronized = [NSNumber numberWithBool:NO];
}

@end
