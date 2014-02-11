//
//  INQFriendsActivity.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"
#import "INQIconTextTableViewItemCell.h"
#import "ARLAppDelegate.h"
#import "ARLNetwork+INQ.h"
#import "INQCloudSynchronizer.h"

@interface INQFriendsTableViewController :  UITableViewController   <NSFetchedResultsControllerDelegate>

//CoreDataTableViewController
/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, groups) {
    /*!
     *  My Friends.
     */
    FRIENDS = 0,
    
    /*!
     *  Available Users in Run.
     */
    USERS,
    
    /*!
     *  Number of items in this NS_ENUM
     */
    numGoups,
};

@property (strong, nonatomic) NSArray *AllUsers;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
