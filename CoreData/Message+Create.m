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
 *  Updated or inserts a Message found on the Server.
 *
 *  @param mDict The Dictionary
 *  @param context  The NSManagedObjectContext
 *
 *  @return The existing or newly created Message.
 */
+ (Message *) messageWithDictionary:(NSDictionary *)mDict
             inManagedObjectContext:(NSManagedObjectContext *)context
{
    Message * message = [self retrieveFromDb:mDict withManagedContext:context];
    if ([[mDict objectForKey:@"deleted"] boolValue]) {
        if (message) {
            //item is deleted
            [context deleteObject:message];
        }
        return nil;
    }
    
    if (!message) {
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        
        message.messageId = [NSNumber numberWithLongLong:[[mDict objectForKey:@"messageId"] longLongValue]];
        message.threadId = [NSNumber numberWithLongLong:[[mDict objectForKey:@"threadId"] longLongValue]];
    }

    message.subject = [mDict objectForKey:@"subject"];
    message.body = [mDict objectForKey:@"body"];
    
    // Set Linked Objects
    message.run = [Run retrieveRun:[NSNumber numberWithLongLong:[[mDict objectForKey:@"runId"] longLongValue]]
             inManagedObjectContext:context];
    
    // Set TimeStamp.
    message.date = [NSNumber numberWithLongLong:[[mDict objectForKey:@"timestamp"] longLongValue]];
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }

    return message;
}

/*!
 *  Retrieve a Message from Core Data.
 *
 *  @param mDict The Dictionary
 *  @param context The NSManagedObjectContext
 *
 *  @return The existing Message or nil
 */
+ (Message *) retrieveFromDb:(NSDictionary *)mDict
          withManagedContext:(NSManagedObjectContext*)context
{
    return [Message retrieveFromDbWithId:[NSNumber numberWithLongLong:[[mDict objectForKey:@"messageId"] longLongValue]]
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
+ (Message *) retrieveFromDbWithId:(NSNumber *)messageId
                withManagedContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %lld", [messageId longLongValue]];
    
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

@end
