//
//  CurrentItemVisibility.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 3/24/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GeneralItem, Run;

@interface CurrentItemVisibility : NSManagedObject

@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) GeneralItem *item;
@property (nonatomic, retain) Run *run;

@end
