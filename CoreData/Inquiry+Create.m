//
//  Inquiry+Create.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "Inquiry+Create.h"

@implementation Inquiry (Create)

+ (Inquiry *) inquiryWithDictionary: (NSDictionary *) inquiryDict inManagedObjectContext: (NSManagedObjectContext * ) context {
    Inquiry * inquiry = [self retrieveFromDb:inquiryDict withManagedContext:context];
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
    
    NSError *error = nil;
    [context save:&error];
    if (error) {
        NSLog(@"[%s] error %@", __func__, error);
    }
    
    return inquiry;
}

+ (Inquiry *) retrieveFromDb: (NSDictionary *) inqDict withManagedContext: (NSManagedObjectContext*) context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inquiry"];
    request.predicate = [NSPredicate predicateWithFormat:@"inquiryId = %@", [inqDict objectForKey:@"inquiryId"]];
    NSArray *inquiryFromDb = [context executeFetchRequest:request error:nil];
    if (!inquiryFromDb) {
        return nil;
    } else {
        return [inquiryFromDb lastObject];
    }
}

@end
