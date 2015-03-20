//
//  IQNDiscussViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ARLNetwork+INQ.h"

#import "INQutils.h"

#import "Inquiry+Create.h"

@interface INQDiscussViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSNumber *inquiryId;

@end


