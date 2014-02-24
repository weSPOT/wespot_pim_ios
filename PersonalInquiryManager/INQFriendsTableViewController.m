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
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, friends) {
    /*!
     *  Add a Friend.
     */
    ADD = 0,
    /*!
     *  Friends.
     */
    FRIENDS,
    /*!
     *  Number of Inquires
     */
    numFriends
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSArray *AllUsers;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQFriendsTableViewController

-(NSString*) cellIdentifier {
    return  @"friendsCell1";
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self.navigationController setToolbarHidden:YES];
    
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
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

#pragma mark - Table view data source

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return numFriends;
}

/*!
 *  Return the number of Rows in a Section.
 *
 *  @param tableView The Table to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case ADD:
            return 1;
        case FRIENDS:
            return [[self.fetchedResultsController fetchedObjects] count];
    }
    
    // Error
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case ADD:
            return @"";
        case FRIENDS:
            return @"Friends";
    }
    
    // Error
    return @"";
}

/*!
 *  Return the Tab/Users/veg/Developer/PersonalInquiryManager/PersonalInquiryManager/INQFriendsTableViewController.mle Data one Cell at a Time.
 *
 *  @param tableView The Table to be served.
 *  @param indexPath The IndexPath of the TableCell.
 *
 *  @return The Cell Content.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case ADD:
            cell.textLabel.text = @"Add friend";
            break;
        case FRIENDS:{
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Account *generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            cell.textLabel.text = generalItem.name;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
          
            NSData* icon = [generalItem picture];
            if (icon) {
                cell.imageView.image = [UIImage imageWithData:icon];
            } else {
                // Fixup for Friends Icons do not show immediately (icon property is empty).
                // LocalId == oauthId
                for (NSDictionary *dict in self.AllUsers) {
                    if ([[dict objectForKey:@"oauthId"] isEqualToString:generalItem.localId]) {
                        NSURL *imageURL   = [NSURL URLWithString:[dict objectForKey:@"icon"]];
                        
                        //NSLog(@"[%s] USERS %@", __func__, [dict objectForKey:@"oauthId"]);
                        
                        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                        if (imageData) {
                            cell.imageView.image = [UIImage imageWithData:imageData];
                        }
                        
                        break;
                    }
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case ADD: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        case FRIENDS:
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:ip];
    
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        }
    }
}

@end
