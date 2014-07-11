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
    // ADD = 0,
    /*!
     *  Friends.
     */
    FRIENDS = 0,
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

-(NSString *) cellIdentifier {
    return  @"friendsCell";
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    [self.navigationController setToolbarHidden:YES];
    
    [self setupFetchedResultsController];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.AllUsers) {
        [self getAllUsers];
    }
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [INQCloudSynchronizer syncUsers:appDelegate.managedObjectContext];
        });
    }
}

- (void)getAllUsers {
    // This should be async and only fired once.
    //
    NSDictionary *usersJson = [ARLNetwork getUsers];
    
    self.AllUsers = (NSArray *)[usersJson objectForKey:@"result"];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    [request setFetchBatchSize:8];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSNumber* accountType = [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"];
    request.predicate = [NSPredicate predicateWithFormat:
                         @"accountType != %d or localId != %@",
                         [accountType intValue],
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"]];
    
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return ;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (NSManagedObject *obj in deletedObjects) {
        if ([[obj entity].name isEqualToString:@"Account"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            // [self.tableView reloadData];
            return;
        }
    }
    
    // See if there are any Inquiry objects added and if so, reload the tableView.
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
    for (NSManagedObject *obj in insertedObjects) {
        if ([[obj entity].name isEqualToString:@"Account"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [self.tableView reloadData];
            return;
        }
    }
    
    // If no Inquiry objecst are added, look for updates and refresh them.
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    
    for (NSManagedObject *obj in updatedObjects) {
        if ([[obj entity].name isEqualToString:@"Account"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [self.tableView reloadData];
            return;
        }
    }
}

/*!
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//        case ADD:
//            return 1;
        case FRIENDS:
            return [[self.fetchedResultsController fetchedObjects] count];
    }
    
    // Error
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
//        case ADD:
//            return @"";
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
    
    // cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    
    switch (indexPath.section) {
//        case ADD:
//            cell.textLabel.text = @"Add friend";
//            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
//            break;
        case FRIENDS:{
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Account *account = ((Account*)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            cell.textLabel.text = account.name;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            NSData* icon = [account picture];
            if (icon) {
                cell.imageView.image = [UIImage imageWithData:icon];
            } else {
                // Fixup for Friends Icons do not show immediately (icon property is empty).
                // LocalId == oauthId
                for (NSDictionary *dict in self.AllUsers) {
                    if ([[dict objectForKey:@"oauthId"] isEqualToString:account.localId]) {
                        @autoreleasepool {
                            NSURL *imageURL   = [NSURL URLWithString:[dict objectForKey:@"icon"]];
                   
                            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                            if (imageData) {
                                cell.imageView.image = [UIImage imageWithData:imageData];
                            }
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
//        case ADD: {
//            UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFriendsView"];
//            
//            if ([newViewController respondsToSelector:@selector(AllUsers)]) {
//                [newViewController performSelector:@selector(AllUsers) withObject:self.AllUsers];
//            }
//            
//            [self.navigationController pushViewController:newViewController animated:YES];
//        }
        case FRIENDS:
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:ip];
    
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        }
    }
}

/*!
 *  Set Color of Table Sections to White.
 *
 *  @param tableView <#tableView description#>
 *  @param view      <#view description#>
 *  @param section   <#section description#>
 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    // view.tintColor = [UIColor blackColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}


@end
