//
//  MainViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/6/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQMainViewController.h"

@interface INQMainViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, groups) {
    /*!
     *  My Inquires.
     */
    MYINQUIRES = 0,
    /*!
     *  My Media.
     */
    MYMEDIA,
    /*!
     *  Profiles/Badges/Friends.
     */
    TOOLS,
    /*!
     *  Number of Groups
     */
    numGroups
};

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, tools) {
    /*!
     *  Profile.
     */
    PROFILE = 0,
    /*!
     *  Badges.
     */
    BADGES,
    /*!
     *  Friends.
     */
    FRIENDS,
    /*!
     *  Number of Tools
     */
    numTools
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) UIBarButtonItem *spacerButton;
@property (strong, nonatomic) UIBarButtonItem *syncButton;
@property (strong, nonatomic) UIBarButtonItem *loginButton;

@end

@implementation INQMainViewController

-(NSString*) cellIdentifier {
    return  @"mainPartCell";
}

/*!
 *  See http://stackoverflow.com/questions/13387378/uirefreshcontrol-uitableview-stuck-while-refreshing
 *
 *  @param refresh <#refresh description#>
 */
- (void)refreshTable:(UIRefreshControl *)refresh  {
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.tableView reloadData];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [refresh endRefreshing];
//            [self.refreshControl endRefreshing];
//        });
//    });
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return ;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
   
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:MYINQUIRES], nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    //See http://stackoverflow.com/questions/14739048/uirefreshcontrol-hidden-obscured-by-my-uinavigationcontrollers-uinavigationba
    
    [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.loginButton) {
        self.spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.syncButton = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self action:@selector(syncButtonButtonTap:)];
        self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonButtonTap:)];

        self.toolbarItems = [NSArray arrayWithObjects:self.spacerButton, self.syncButton, self.loginButton,nil];
    }

    [self.navigationController setToolbarHidden:NO];
    
    [self adjustLoginButton];
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
}

-(void)loginButtonButtonTap:(id)sender {
    UIViewController *newViewController;
    
    NSLog(@"[%s] %@",__func__, ARLAppDelegate.theLock);
    
    if (![ARLAppDelegate.theLock tryLock]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Synchronization in progress, logout not possible" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        if (ARLNetwork.isLoggedIn) {
            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [ARLAccountDelegator deleteCurrentAccount:appDelegate.managedObjectContext];
            
            //#warning not enough to toggle isLoggedIn.
            [self adjustLoginButton];
            
            if (ARLNetwork.isLoggedIn) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Cound not log-out" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
            } else {
                newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"];
            }
        } else {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigation"];
        }
        
        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController presentViewController:newViewController animated:YES completion:nil];
        }

        [ARLAppDelegate.theLock unlock];
    }
}

- (void)syncButtonButtonTap:(id)sender {
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
   
    if ([appDelegate respondsToSelector:@selector(syncData)]) {
        [appDelegate performSelector:@selector(syncData)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numGroups;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section){
        case MYINQUIRES:
            return @"";
        case MYMEDIA:
            return @"";
        case TOOLS:
            return @"";
    }
    
    // Error
    return @"";
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
        case MYINQUIRES:
            return 1;
        case MYMEDIA:
            return 1;
        case TOOLS:
            return 3;
    }
    return 0;
}

/*!
 *  Return the Table Data one Cell at a Time.
 *
 *  @param tableView The Table to be served.
 *  @param indexPath The IndexPath of the TableCell.
 *
 *  @return The Cell Content.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // cell.backgroundColor = [UIColor clearColor];
    
    [cell.detailTextLabel setAttributedText:[[NSMutableAttributedString alloc]initWithString:@""]];

    // Configure the cell...
    switch (indexPath.section) {
        case MYINQUIRES: {
            cell.textLabel.Text = @"My inquiries";
            cell.imageView.image = [UIImage imageNamed:@"inquiry"];
            
            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSInteger count = [appDelegate entityCount:@"Inquiry"];
            
            if (count!=0) {
                NSString *value = [[NSString alloc] initWithFormat:@"%d", count];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:value];
                NSRange range=[value rangeOfString:value];
                
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                
                [cell.detailTextLabel setAttributedText:string];
            }
        }
            break;
        case MYMEDIA: {
            cell.textLabel.Text = @"My media";
            cell.imageView.image = [UIImage imageNamed:@"collect-data"];
        }
            break;
        case TOOLS:
            switch (indexPath.item) {
                case PROFILE :
                    cell.textLabel.Text = @"Profile";
                    cell.imageView.image = [UIImage imageNamed:@"profile"];
                    break;
                case BADGES :
                    cell.textLabel.Text = @"Badges";
                    cell.imageView.image = [UIImage imageNamed:@"badges"];
                    break;
                case FRIENDS :
                    cell.textLabel.Text = @"Friends";
                    cell.imageView.image = [UIImage imageNamed:@"friends"];
                    
                    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    NSInteger count = [appDelegate entityCount:@"Account"];
                    
                    if (count > 1) {
                        NSString *value = [[NSString alloc] initWithFormat:@"%d", count - 1];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:value];
                        NSRange range=[value rangeOfString:value];
                        
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                        
                        [cell.detailTextLabel setAttributedText:string];

                    }
                    break;
            }
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newViewController;
    
    // Create the new ViewController.
    switch (indexPath.section) {
        case MYINQUIRES:
            switch (indexPath.item) {
               default:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyInquiriesView"];
                    break;
            }
            break;
            
        case MYMEDIA:
            switch (indexPath.item) {
                default: {
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
                    
                    if ([newViewController respondsToSelector:@selector(setAccount:)]) {
                        [newViewController performSelector:@selector(setAccount:) withObject:[ARLNetwork CurrentAccount]];
                    }
                    
//                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                  [alert show];
                }
                    break;
            }
            break;

        case TOOLS: {
            switch (indexPath. item) {
                case PROFILE :
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
                    break;
                case BADGES :
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BadgesView"];
                    break;
                case FRIENDS :
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsView"];
                    break;
            }
            }
            break;
            
        default:
            break;
    }
    
    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

- (void) adjustLoginButton  {
    if (ARLNetwork.isLoggedIn) {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil)];
    } else {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil)];
    }
}

/*!
 *  Enable or Disable Sync Button depending on Network availability.
 *
 *  @param note <#note description#>
 */
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    self.syncButton.enabled=[reach isReachable];
    self.loginButton.enabled=[reach isReachable];
}

@end
