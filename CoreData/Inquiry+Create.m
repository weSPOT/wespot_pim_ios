//
//  Inquiry+Create.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Inquiry+Create.h"

@implementation Inquiry (Create)

/*!
 *  Retrieve or creates an Inquiry given a dictionary.
 *
 *  @param inquiryDict Should at least contain description, inquiryId and title. Optional is icon.
 *  @param context     The NSManagedObjectContext.
 *
 *  @return The requested Inquiry.
 */
+ (Inquiry *) inquiryWithDictionary: (NSDictionary *) inquiryDict inManagedObjectContext: (NSManagedObjectContext *) context {
    Inquiry *inquiry = [self retrieveFromDb:inquiryDict withManagedContext:context];
    if (!inquiry) {
        inquiry = [NSEntityDescription insertNewObjectForEntityForName:@"Inquiry" inManagedObjectContext:context];
    }
    inquiry.desc = [inquiryDict objectForKey:@"description"];
    inquiry.inquiryId = [inquiryDict objectForKey:@"inquiryId"];
    inquiry.title = [inquiryDict objectForKey:@"title"];

    NSURL  *url = [NSURL URLWithString:[inquiryDict objectForKey:@"icon"]];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData ){
        inquiry.icon = urlData;
    }
    
    [INQLog SaveNLog:context];

    return inquiry;
}

/*!
 *  Retrieves an Inquiry from the database given a dictionary.
 *
 *  @param inqDict Should at least contain InquiryId.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Inquiry.
 */
+ (Inquiry *) retrieveFromDb: (NSDictionary *) inqDict withManagedContext: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inquiry"];
  
    request.predicate = [NSPredicate predicateWithFormat:@"inquiryId = %@", [inqDict objectForKey:@"inquiryId"]];
    
    NSArray *inquiryFromDb = [context executeFetchRequest:request error:nil];
    
    if (!inquiryFromDb) {
        return nil;
    } else {
        return [inquiryFromDb lastObject];
    }
}

/*!
 *  Retrieves an Inquiry from the database given an Id.
 *
 *  @param inquiryId The Id of the Inquiry we want.
 *  @param context The NSManagedObjectContext.
 *
 *  @return The requested Inquiry.
 */
+ (Inquiry *) retrieveFromDbWithInquiryId: (NSNumber *) inquiryId withManagedContext: (NSManagedObjectContext *) context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inquiry"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"inquiryId = %@", inquiryId];
    
    NSArray *inquiryFromDb = [context executeFetchRequest:request error:nil];
    
    if (!inquiryFromDb) {
        return nil;
    } else {
        return [inquiryFromDb lastObject];
    }
}

@end
