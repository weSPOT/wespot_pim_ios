//
//  GeneralItemVisibility.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/24/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeneralItem, Run;

@interface GeneralItemVisibility : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * generalItemId;
@property (nonatomic, retain) NSNumber * runId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * timeStamp;
@property (nonatomic, retain) Run *correspondingRun;
@property (nonatomic, retain) GeneralItem *generalItem;

@end
