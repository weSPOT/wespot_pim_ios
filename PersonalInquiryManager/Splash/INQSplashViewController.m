//
//  IMViewController.m
//  InqueryManager
//
//  Created by Wim van der Vegt on 1/30/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INQSplashViewController.h"

@interface INQSplashViewController ()

@property (strong, nonatomic) NSArray *pages;

- (IBAction)weSpotButtonAction:(UIButton *)sender;
- (IBAction)googleButtonAction:(UIButton *)sender;
- (IBAction)facebookButtonAction:(UIButton *)sender;
- (IBAction)linkedinButtonAction:(UIButton *)sender;
- (IBAction)twitterButtonAction:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *weSpotButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *linkedinButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (retain, nonatomic) NSMutableURLRequest *originalRequest;
@property (retain, nonatomic) NSString *token;

@property (strong, nonatomic) NSString *facebookLoginString;
@property (strong, nonatomic) NSString *googleLoginString;
@property (strong, nonatomic) NSString *linkedInLoginString;
@property (strong, nonatomic) NSString *twitterLoginString;

@end

@implementation INQSplashViewController

#pragma - mark system

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self.weSpotButton setHidden:YES];
    [self.orLabel setHidden:YES];
    [self.googleButton setHidden:YES];
    [self.facebookButton setHidden:YES];
    [self.linkedinButton setHidden:YES];
    [self.twitterButton setHidden:YES];
    
    [self initOauthUrls];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    if (ARLNetwork.isLoggedIn) {
        ARLAppDelegate.SyncAllowed = YES;
        
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
        
        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController presentViewController:newViewController animated:NO completion:nil];
            
            newViewController = nil;
            
            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [appDelegate doRegisterForAPN:[UIApplication sharedApplication]];
            
            // Log("Initial Sync at Startup");
            
            // if ([appDelegate respondsToSelector:@selector(syncData)]) {
            NSInteger *count = [appDelegate entityCount:@"Inquiry"];
            if (count) {
                //
            } else {
                [appDelegate syncData];
            }
            // }
        }
        
        return;
    }
    
    [self.weSpotButton setHidden:NO];
    [self.orLabel setHidden:NO];
    [self.googleButton setHidden:NO];
    [self.facebookButton setHidden:NO];
    // [self.linkedinButton setHidden:NO];
    // [self.twitterButton setHidden:NO];
    
    ARLAppDelegate.SyncAllowed = NO;
    
    //Clear what's still in the tables.
    // Log("Clearing Database");
    
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    [ARLAccountDelegator resetAccount:appDelegate.managedObjectContext];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //WARNING: Disabled the NSPageViewController for now (no decent content).
    
    // Create the data model
    //    self.pageTitles = @[@"1-Over 200 Tips and Tricks", @"2-Discover Hidden Features", @"3-Bookmark Favorite Tip", @"4-Free Regular Update"];
    //    self.pageImages = @[@"page1", @"page2", @"page3", @"page4"];
    
    // Create page view controller
    //    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashPageViewController"];
    //    self.pageViewController.dataSource = self;
    //
    //    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    //    for (int i=0;i<4;i++) {
    //        [tmp addObject:[self viewControllerAtIndex:i]];
    //    }
    //    self.pages = [[NSArray alloc] initWithArray:tmp];
    //
    //    NSArray *viewControllers = [[NSMutableArray alloc] initWithObjects:[self.pages objectAtIndex:0], nil];
    //    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    //
    //    // Change the size of page view controller
    //    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    //WARNING: Disabled the NSPageViewController for now (no decent content).
    //[self addChildViewController:_pageViewController];
    //[self.view addSubview:_pageViewController.view];
    
    //[self.pageViewController didMoveToParentViewController:self];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
    
    [self addConstraints];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.pages =nil;
    self.pageTitles = nil;
    self.pageImages = nil;
    // self.pageViewController = nil;
    self.backgroundImage = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (INQSplashContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    INQSplashContentViewController *pageContentViewController = (INQSplashContentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SplashContentViewController"];
    
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
//{
//    NSUInteger index = ((INQSplashContentViewController *)viewController).pageIndex;
//
//    if ((index == 0) || (index == NSNotFound)) {
//        return nil;
//    }
//
//    index--;
//
//    return [self.pages objectAtIndex:index]; //[self viewControllerAtIndex:index];
//}
//
//- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
//{
//    NSUInteger index = ((INQSplashContentViewController *)viewController).pageIndex;
//
//    if (index == NSNotFound) {
//        return nil;
//    }
//
//    index++;
//
//    if (index == [self.pageTitles count]) {
//        return nil;
//    }
//
//    return [self.pages objectAtIndex:index]; //[self viewControllerAtIndex:index];
//}
//
//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//    return [self.pageTitles count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return ((INQSplashContentViewController *)pageViewController).pageIndex;
//}

//- (IBAction)loginButtonButtonTap:(UIButton *)sender {
//    if (ARLNetwork.networkAvailable) {
//        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigation"];
//
//        if (newViewController) {
//            // Move to another UINavigationController or UITabBarController etc.
//            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
//            [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
//
//            newViewController = nil;
//        }
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")message:NSLocalizedString(@"Not online, login not possible", @"Not online, login not possible") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
//        [alert show];
//    }
//}

- (void) addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.backgroundImage,  @"background",
                                     self.weSpotButton,     @"weSpotButton",
                                     self.orLabel,          @"orLabel",
                                     self.facebookButton,   @"facebookButton",
                                     self.googleButton,     @"googleButton",
                                     self.linkedinButton,   @"linkedinButton",
                                     self.twitterButton,    @"twitterButton",
                                     nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.weSpotButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.googleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkedinButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:[weSpotButton]-[orLabel]-[facebookButton]-[googleButton]-[linkedinButton]-[twitterButton]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.weSpotButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.orLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.facebookButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.googleButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.linkedinButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.twitterButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[weSpotButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[facebookButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[googleButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[linkedinButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[twitterButton(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Background
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"H:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

///*!
// *  Enable or Disable Login Button depending on Network availability.
// *
// *  @param note <#note description#>
// */
//-(void)reachabilityChanged:(NSNotification*)note
//{
//    Reachability *reach = [note object];
//
//    self.loginButton.enabled=[reach isReachable];
//}

- (IBAction)weSpotButtonAction:(UIButton *)sender {
    if (ARLNetwork.networkAvailable) {
        UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginNavigation"];
        
        if (newViewController) {
            // Move to another UINavigationController or UITabBarController etc.
            // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
            [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
            
            newViewController = nil;
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")message:NSLocalizedString(@"Not online, login not possible", @"Not online, login not possible") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
        [alert show];
    }
}

/*!
 *  Login using Google.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)googleButtonAction:(UIButton *)sender {
    [self performLogin:GOOGLE];
}

/*!
 *  Login using Facebook.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)facebookButtonAction:(UIButton *)sender {
    [self performLogin:FACEBOOK];
}

/*!
 *  Login using Linked-in.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)linkedinButtonAction:(UIButton *)sender {
    [self performLogin:LINKEDIN];
}

/*!
 *  Login using Twitter.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)twitterButtonAction:(UIButton *)sender {
    [self performLogin:TWITTER];
}

/*!
 *  If data is successfully received, this method will be called by connection.
 *
 *  @param connection <#connection description#>
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if ([self.token length]!=0) {
        //Copied from ARLOauthWebViewController.m
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"auth"];
        
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSDictionary *accountDetails = [ARLNetwork accountDetails];
        
        [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
        
        // veg 26-06-2014 disabled because notification api is disabled. moved to login.
//        NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
//        [ARLNetwork registerAccount:fullId];
        
        [self navigateBack];
    }
}

/*!
 *  Handle the Back Button.
 */
- (void)navigateBack {
    if (ARLNetwork.isLoggedIn) {
        UIViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
        
        if (ARLNetwork.isLoggedIn) {
            UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
            if ([appDelegate respondsToSelector:@selector(syncData)]) {
                [appDelegate performSelector:@selector(syncData)];
            }
        }
        
        [self.navigationController presentViewController:mvc animated:YES completion:nil];
        
    } else {
        [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"] animated:YES  completion:nil];
    }
}

/*!
 *  Perform the actual Login.
 *
 *  @param serviceId <#serviceId description#>
 */
- (void)performLogin:(NSInteger)serviceId {
    [self initOauthUrls];
    
    ARLOauthWebViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
    
    svc.NavigationAfterClose = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    switch (serviceId) {
        case FACEBOOK:
            [svc loadAuthenticateUrl: self.facebookLoginString name:@"Facebook" delegate:svc];
            break;
        case GOOGLE:
            [svc loadAuthenticateUrl: self.googleLoginString name:@"Google" delegate:svc];
            break;
        case LINKEDIN:
            [svc loadAuthenticateUrl: self.linkedInLoginString name:@"Linked-in" delegate:svc];
            break;
        case TWITTER:
            [svc loadAuthenticateUrl: self.twitterLoginString name:@"Twitter" delegate:svc];
            break;
    }
}

/*!
 *  Initialize the Oauth Urls for the various services supported.
 */
- (void) initOauthUrls {
    NSDictionary* network = [ARLNetwork oauthInfo];
    
    for (NSDictionary* dict in [network objectForKey:@"oauthInfoList"]) {
        switch ([(NSNumber*)[dict objectForKey:@"providerId"] intValue]) {
            case FACEBOOK:
                self.facebookLoginString = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&display=page&redirect_uri=%@&scope=publish_stream,email", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
                
            case GOOGLE:
                self.googleLoginString = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&scope=profile+email", [dict objectForKey:@"redirectUri"], [dict objectForKey:@"clientId"]];
                break;
                
            case LINKEDIN:
                self.linkedInLoginString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=r_fullprofile+r_emailaddress+r_network&state=BdhOU9fFb6JcK5BmoDeOZbaY58&redirect_uri=%@", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
                
            case TWITTER:
                self.twitterLoginString = [NSString stringWithFormat:@"%@?twitter=init", [dict objectForKey:@"redirectUri"]];
                break;
                
        }
    }
}

@end
