//
//  INQGeneralItemTableViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNetwork.h"
#import "ARLCloudSynchronizer.h"
#import "Run.h"

@interface INQGeneralItemTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Run *run;

@end
