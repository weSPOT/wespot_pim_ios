//
//  Response.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/25/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, GeneralItem, Run;

@interface Response : NSManagedObject

@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * responseId;
@property (nonatomic, retain) NSNumber * synchronized;
@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) GeneralItem *generalItem;
@property (nonatomic, retain) Run *run;

@end
