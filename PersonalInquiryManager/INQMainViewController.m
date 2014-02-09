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
    TOOLS = 1,
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
    BADGES = 1,
    /*!
     *  Friends.
     */
    FRIENDS = 2,
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQMainViewController

-(NSString*) cellIdentifier {
    return  @"mainPartCell";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"login" style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonButtonTap:)];
    
    [self fetchCurrentAccount];
    
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        [loginButton setTitle:NSLocalizedString(@"logout", nil)];
    } else {
        [loginButton setTitle:NSLocalizedString(@"login", nil)];
    }
    
    self.navigationItem.rightBarButtonItem = loginButton;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

-(void)loginButtonButtonTap:(id)sender {
    //[self performSegueWithIdentifier:@"GotoLogin" sender:sender];
    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
    [self.navigationController pushViewController:newViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.section) {
        case MYINQUIRES: {
                cell.textLabel.Text = @"My inquiries";
            }
            break;
        case TOOLS:
            switch (indexPath.item) {
                case PROFILE :
                     cell.textLabel.Text = @"Profile";
                    break;
                case BADGES :
                    cell.textLabel.Text = @"Badges";
                    break;
                case FRIENDS :
                    cell.textLabel.Text = @"Friends";
                    break;
            }
            break;
    }
    
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *sectionName;
//    switch (section)
//    {
//            
//    }
//    
//}

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
                case PROFILE : {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                    }
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

@end
