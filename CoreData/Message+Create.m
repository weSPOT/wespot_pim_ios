//
//  Message+Create.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/27/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "Message+Create.h"

@implementation Message (Create)

/*!
 *  Updated or inserts a Message found on the Server given a dictionary.
 *
 *  @param mDict Should at least contain messageId, threadId, subject, body, runId and timestamp.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The existing or newly created Message.
 */
+ (Message *) messageWithDictionary:(NSDictionary *) dict
             inManagedObjectContext:(NSManagedObjectContext *) context
{
    Message * message = [self retrieveFromDb:dict withManagedContext:context];
    if ([[dict objectForKey:@"deleted"] boolValue]) {
        if (message) {
            //item is deleted
            [context deleteObject:message];
            message = nil;
        }
        return nil;
    }
    
    if (!message) {
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        
        message.messageId = [NSNumber numberWithLongLong:[[dict objectForKey:@"messageId"] longLongValue]];
        message.threadId = [NSNumber numberWithLongLong:[[dict objectForKey:@"threadId"] longLongValue]];
    }

    message.subject = [dict objectForKey:@"subject"];
    message.body = [dict objectForKey:@"body"];
    
    // Set Linked Objects
    message.run = [Run retrieveRun:[NSNumber numberWithLongLong:[[dict objectForKey:@"runId"] longLongValue]]
             inManagedObjectContext:context];
    
    message.account = [Account retrieveFromDbWithLocalId:[dict objectForKey:@"senderId"] accountType:[dict objectForKey:@"senderProviderId"] withManagedContext:context];
    
 //   "senderId": "116743449349920850150",
 //   "senderProviderId": 2
    
    // Set TimeStamp.
    message.date = [NSNumber numberWithLongLong:[[dict objectForKey:@"date"] longLongValue]];
    
    [INQLog SaveNLog:context];

    return message;
}

/*!
 *  Retrieve a Message from Core Data given a dictionary.
 *
 *  @param mDict Should at least contain messageId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Message or nil.
 */
+ (Message *) retrieveFromDb:(NSDictionary *) dict
          withManagedContext:(NSManagedObjectContext*) context
{
    return [Message retrieveFromDbWithId:[NSNumber numberWithLongLong:[[dict objectForKey:@"messageId"] longLongValue]]
                      withManagedContext:context];
}
/*!
 *  Retrieve a Message from Core Data.
 *
 *  @param messageId The message ID  <#itemId description#>
 *  @param context The NSManagedObjectContext
 *
 *  @return The existing Message or nil
 */
+ (Message *) retrieveFromDbWithId:(NSNumber *) messageId
                withManagedContext:(NSManagedObjectContext*) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", [messageId longLongValue]];
    
    NSError *error = nil;
    NSArray *responsesFromDb = [context executeFetchRequest:request error:&error];
    ELog(error);
    
    if (!responsesFromDb || ([responsesFromDb count] != 1)) {
        return nil;
    } else {
        return [responsesFromDb lastObject];
    }
}

@end
