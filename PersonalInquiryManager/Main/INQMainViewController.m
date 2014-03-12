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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
  
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.loginButton) {
        self.spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.syncButton = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self action:@selector(syncButtonButtonTap:)];
        self.loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:self action:@selector(loginButtonButtonTap:)];

        self.toolbarItems = [NSArray arrayWithObjects:self.spacerButton, self.syncButton, self.loginButton,nil];
    }

    [self adjustLoginButton];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}

-(void)loginButtonButtonTap:(id)sender {
    UIViewController *newViewController;
    
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [ARLAccountDelegator deleteCurrentAccount:appDelegate.managedObjectContext];
      
        //#warning not enough to toggle isLoggedIn.
        [self adjustLoginButton];
  
        newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"];
    } else {
        newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigation"];
    }
    
    if (newViewController) {
        // Move to another UINavigationController or UITabBarController etc.
        // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
        [self.navigationController presentViewController:newViewController animated:YES completion:nil];
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

    // Configure the cell...
    switch (indexPath.section) {
        case MYINQUIRES: {
                cell.textLabel.Text = @"My inquiries";
                cell.imageView.image = [UIImage imageNamed:@"inquiry"];
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

/*!
 *  Sets the isLoggedIn property of the AppDelegate.
 */
- (NSNumber *)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil];
}

- (Account *) fetchCurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate performSelector:@selector(fetchCurrentAccount) withObject:nil];
}

- (void) adjustLoginButton  {
    [self fetchCurrentAccount];
    
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil)];
    } else {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil)];
    }
}

@end
