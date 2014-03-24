//
//  SynchronizationBookKeeping.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/24/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SynchronizationBookKeeping : NSManagedObject

@property (nonatomic, retain) NSNumber * context;
@property (nonatomic, retain) NSNumber * lastSynchronization;
@property (nonatomic, retain) NSString * type;

@end
