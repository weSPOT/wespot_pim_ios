//
//  INQFriendsActivity.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "ARLAppDelegate.h"
#import "ARLNetwork+INQ.h"
#import "INQCloudSynchronizer.h"

@interface INQFriendsTableViewController :  UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSArray *Friends;

@end
