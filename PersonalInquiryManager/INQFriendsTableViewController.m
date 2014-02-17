//
//  INQFriendsActivity.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQFriendsTableViewController.h"

@interface INQFriendsTableViewController ()

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
    return 1;
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

    return [[self.fetchedResultsController fetchedObjects] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Friends";
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

    // Configure the cell...
    
    Account *generalItem = ((Account*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
}

@end
