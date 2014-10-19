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
    // BADGES,
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

@property (weak, nonatomic) IBOutlet UIBarButtonItem *spacerButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *syncButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

- (IBAction)syncButtonAction:(UIBarButtonItem *)sender;
- (IBAction)logoutButtonAction:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSArray *Friends;

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
   
    [self.tableView reloadData];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    Log(@"%@", @"initWithNibName");
//
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Log(@"%@", @"viewDidLoad");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterForeground:)
                                                 name:@"UIApplicationWillEnterForegroundNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    //See http://stackoverflow.com/questions/14739048/uirefreshcontrol-hidden-obscured-by-my-uinavigationcontrollers-uinavigationba
    
    // [self.refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
#warning OPENBADGES TEST CODE AHEAD
    
    //    Account *account = ARLNetwork.CurrentAccount;
    //    NSString *userId = [NSString stringWithFormat:@"%@_%@", [[ARLNetwork elggProviderId:account.accountType] lowercaseString], account.localId];
    //    [ARLNetwork getUserBadges:userId];
    
    //    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    //    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    if (!self.Friends) {
        [self getMyFriends];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Log(@"%@", @"viewWillAppear");
    
    [self adjustLoginButton];

    self.syncButton.enabled = ARLNetwork.networkAvailable;
    self.logoutButton.enabled = ARLNetwork.networkAvailable;
    
    [self.navigationController setToolbarHidden:NO];
    
    if (!self.Friends) {
        [self getMyFriends];
    }
    
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    Log(@"%@", @"viewDidAppear");
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    
    //#warning TEST CODE FOR ABORT
    //[ARLNetwork ShowAbortMessage:@"TEST" message:@"TEST MESSAGE"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    Log(@"%@", @"viewWillDisappear");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) dealloc {
    DLog(@"");
}

- (void)getMyFriends {
    // This should be async and only fired once.
    //
    if (ARLNetwork.networkAvailable) {
        Account *account = [ARLNetwork CurrentAccount];
        
        NSDictionary *usersJson = [ARLNetwork getFriends:account.localId withProviderId:account.accountType];
        
        //{
        //    result =     (
        //                  {
        //                      icon = "http://inquiry.wespot.net/mod/profile/icondirect.php?lastcache=1396854990&joindate=1396854975&guid=32309&size=medium";
        //                      name = "Stefaan Ternier";
        //                      oauthId = "stefaan.ternier";
        //                      oauthProvider = weSPOT;
        //                  }
        //                  );
        //    status = 0;
        //}
        
        self.Friends = (NSArray *)[usersJson objectForKey:@"result"];
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
            return numTools;
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
    
    [cell.detailTextLabel setAttributedText:[[NSMutableAttributedString alloc] initWithString:@""]];

    // Configure the cell...
    switch (indexPath.section) {
        case MYINQUIRES: {
            cell.textLabel.Text = @"My inquiries";
            cell.imageView.image = [UIImage imageNamed:@"inquiry"];
            
            @autoreleasepool {
                ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                NSInteger count = [appDelegate entityCount:@"Inquiry"];
                
                if (count!=0) {
                    NSString *value = [NSString stringWithFormat:@"%d", count];
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
                    NSRange range=[value rangeOfString:value];
                    
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                    
                    [cell.detailTextLabel setAttributedText:string];
                }
            }
        }
            break;
            
        case MYMEDIA: {
            cell.textLabel.Text = @"My media";
            cell.imageView.image = [UIImage imageNamed:@"mymedia"];
           
            @autoreleasepool {
                ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                Account *account = ARLNetwork.CurrentAccount;
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"account.localId = %@ AND account.accountType = %@ AND contentType !=nil AND contentType!=''",
                                          account.localId, account.accountType];
                
                NSInteger count = [appDelegate entityCount:@"Response" predicate:predicate];
                
                if (count!=0) {
                    NSString *value = [NSString stringWithFormat:@"%d", count];
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
                    NSRange range=[value rangeOfString:value];
                    
                    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                    
                    [cell.detailTextLabel setAttributedText:string];
                }
            }
        }
            break;
            
        case TOOLS:
            switch (indexPath.item) {
                case PROFILE :
                    cell.textLabel.Text = @"Profile";
                    cell.imageView.image = [UIImage imageNamed:@"profile"];
                    break;
                    //                case BADGES :
                    //                    cell.textLabel.Text = @"Badges";
                    //                    cell.imageView.image = [UIImage imageNamed:@"badges"];
                    //                    break;
                case FRIENDS :
                    cell.textLabel.Text = @"Friends";
                    cell.imageView.image = [UIImage imageNamed:@"friends"];
                    
                    @autoreleasepool {
                        // ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                        NSInteger count = [self.Friends count]; //[appDelegate entityCount:@"Account"];
                        
                        if (count > 0) {
                            NSString *value = [NSString stringWithFormat:@"%d", count];
                            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
                            NSRange range=[value rangeOfString:value];
                            
                            [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                            
                            [cell.detailTextLabel setAttributedText:string];
                            
                        }
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
                }
                    break;
            }
            break;
            
        case TOOLS: {
            switch (indexPath. item) {
                case PROFILE :
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileView"];
                    break;
                    //                case BADGES :
                    //                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BadgesView"];
                    //                    break;
                case FRIENDS :
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsView"];
                    
                    if ([newViewController respondsToSelector:@selector(setFriends:)]) {
                        [newViewController performSelector:@selector(setFriends:) withObject:self.Friends];
                    }
                    
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
        
        // newViewController = nil;
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

- (void) adjustLoginButton  {
    if (ARLNetwork.isLoggedIn) {
        [self.logoutButton setTitle:NSLocalizedString(@"Logout", nil)];
    } else {
        [self.logoutButton setTitle:NSLocalizedString(@"Login", nil)];
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
    
    self.syncButton.enabled = [reach isReachable];
    self.logoutButton.enabled = [reach isReachable];
}

/*!
 *  Enable or Disable Sync Button depending on Network availability.
 *
 *  @param app <#note description#>
 */
-(void)enterForeground:(UIApplication*)app
{
    self.syncButton.enabled = ARLNetwork.networkAvailable;
    self.logoutButton.enabled = ARLNetwork.networkAvailable;
}

- (IBAction)syncButtonAction:(UIBarButtonItem *)sender {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate respondsToSelector:@selector(syncData)]) {
        [appDelegate performSelector:@selector(syncData)];
    }
    
    [self getMyFriends];
    
    [self.tableView reloadData];
}

- (IBAction)logoutButtonAction:(UIBarButtonItem *)sender {
    UIViewController *newViewController;
    
    ARLAppDelegate.SyncAllowed = NO;
    
    NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
    
    while (YES) {
        if ([ARLAppDelegate.theLock tryLock]) {
            [ARLAppDelegate.theLock unlock];
            break;
        }
        [myRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    // if (![ARLAppDelegate.theLock tryLock]) {
    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:NSLocalizedString(@"Synchronization in progress, logout not possible", @"Synchronization in progress, logout not possible") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
    // [alert show];
    // } else {
    
    if (ARLNetwork.isLoggedIn) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate LogOut];
        
        //#warning not enough to toggle isLoggedIn.
        [self adjustLoginButton];
        
        if (ARLNetwork.isLoggedIn) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info") message:NSLocalizedString(@"Could not log-out",@"Could not log-out") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
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
        [self.navigationController presentViewController:newViewController animated:NO completion:nil];
        
        newViewController=nil;
    }
    
    // [ARLAppDelegate.theLock unlock];
    // }
}

@end
