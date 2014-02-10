//
//  INQFriendsActivity.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQFriendsTableViewController.h"

@interface INQFriendsTableViewController ()

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

@property (strong,nonatomic) NSArray *AllUsers;

@end

@implementation INQFriendsTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self setupFetchedResultsController];
    
    if (!self.AllUsers) {
        [self getAllUsers];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [INQCloudSynchronizer syncUsers:appDelegate.managedObjectContext];
}

- (void)getAllUsers {
    NSDictionary *usersJson = [ARLNetwork getUsers];
    
    self.AllUsers = (NSArray *)[usersJson objectForKey:@"result"];
}

- (void)setupFetchedResultsController {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSNumber* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"accountType != %d or localId != %@",
                         [accountType intValue],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]];
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return numGoups;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case FRIENDS:
            return [[self.fetchedResultsController fetchedObjects] count];
        case USERS:
            if (!self.AllUsers) {
                [self getAllUsers];
            }
            return self.AllUsers.count;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * sectionName = @"Error";
    
    switch (section) {
    case FRIENDS:
        sectionName = @"Friends";
        break;
    case USERS:
        sectionName = @"Users";
        break;
    }
    
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    INQFriendsTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
   
    if (cell == nil) {
        cell = [[INQFriendsTableViewItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendsCell"];
    }

    switch (indexPath.section) {
        case FRIENDS : {
            Account *generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
            
            cell.name.text = generalItem.name;
            cell.name.font = [UIFont boldSystemFontOfSize:16.0f];
            
            NSData* icon = [generalItem picture];
            if (icon) {
                cell.icon.image = [UIImage imageWithData:icon];
//            } else {
//                for (NSDictionary *dict in self.AllUsers) {
//                    if ([dict objectForKey:@"oauthId"] == generalItem.localId) {
//                        NSURL *imageURL   = [NSURL URLWithString:[dict objectForKey:@"icon"]];
//                        NSLog(@"[%s] %@", __func__, imageURL);
//                        
//                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//                        if (imageData) {
//                            cell.icon.image = [UIImage imageWithData:imageData];
//                        }
//
//                    }
//                }
            }
        }
            break;
            
        case USERS : {
            cell.name.text = [self.AllUsers[indexPath.item] objectForKey:@"name"];
            
            NSURL *imageURL   = [NSURL URLWithString:[self.AllUsers[indexPath.item] objectForKey:@"icon"]];
            NSLog(@"[%s] %@", __func__, imageURL);
            
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            if (imageData) {
                cell.icon.image = [UIImage imageWithData:imageData];
            }
        }
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    INQFriendsTableViewItemCell *cell = (INQFriendsTableViewItemCell*) [tableView cellForRowAtIndexPath:indexPath];
    cell.name.font = [UIFont systemFontOfSize:16.0f];
}

//-(void) configureCell: (INQFriendsTableViewItemCell *) cell atIndexPath:(NSIndexPath *)indexPath {
//    Account * account = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
//    
//    cell.name.text = account.name;
//    //cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
//    
//    NSData* icon = [account picture];
//    if (icon) {
//        UIImage *image = [UIImage imageWithData:icon];
//        cell.icon.image = image;
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    Account *generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
   
    if (generalItem){
        //veg Silence unused variable warning!
    }
}

@end
