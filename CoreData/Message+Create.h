//
//  Message+Create.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/27/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "Message.h"
#import "Run+ARLearnBeanCreate.h"

@interface Message (Create)

+ (Message *) messageWithDictionary:(NSDictionary *) dict
             inManagedObjectContext:(NSManagedObjectContext *) context;

+ (Message *) retrieveFromDb:(NSDictionary *) dict
                withManagedContext:(NSManagedObjectContext *) context;
+ (Message *) retrieveFromDbWithId:(NSNumber *) itemId
                withManagedContext:(NSManagedObjectContext *) context;

@end
