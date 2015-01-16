//
//  INQGeneralItemTableViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "UIViewController+UI.h"

#import "ARLNetwork.h"
#import "ARLCloudSynchronizer.h"
#import "ARLAppDelegate.h"
#import "Run.h"
#import "Action+Create.h"

@interface INQGeneralItemTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Inquiry *inquiry;

@end
