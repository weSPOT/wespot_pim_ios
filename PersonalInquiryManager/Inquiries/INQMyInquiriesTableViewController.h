//
//  INQMyInquiriesViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLAppDelegate.h"
#import "ARLNetwork+INQ.h"

#import "ARLCloudSynchronizer.h"
#import "INQCloudSynchronizer.h"

#import "Inquiry+Create.h"

@interface INQMyInquiriesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@end
