//
//  Message.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 7/14/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Run;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * threadId;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Run *run;

@end
