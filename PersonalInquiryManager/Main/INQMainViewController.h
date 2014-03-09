//
//  MainViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/6/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account+Create.h"
#import "INQCloudSynchronizer.h"
#import "ARLAccountDelegator.h"

@interface INQMainViewController : UITableViewController

+ (void)sync_data;

@end
