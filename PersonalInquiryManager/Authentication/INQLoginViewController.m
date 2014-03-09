//
//  INQLoginViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQLoginViewController.h"
//#import "INQMainViewController.h"

@interface INQLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wespotLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameEdit;
@property (weak, nonatomic) IBOutlet UITextField *passwordEdit;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *googleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *linkedinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *twitterButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender;
- (IBAction)googleButtonAction:(UIBarButtonItem *)sender;
- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender;
- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender;
- (IBAction)loginButtonAction:(UIButton *)sender;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (strong, nonatomic) NSString * facebookLoginString;
@property (strong, nonatomic) NSString * googleLoginString;
@property (strong, nonatomic) NSString * linkedInLoginString;
@property (strong, nonatomic) NSString * twitterLoginString;

@end

@implementation INQLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self initOauthUrls];
    
    [self adjustLoginButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.usernameEdit.delegate = self;
    self.passwordEdit.delegate = self;
    
    [self addConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self adjustLoginButton];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    [self adjustLoginButton];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:FACEBOOK];
}

- (IBAction)googleButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:GOOGLE];
}

- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:LINKEDIN];
}

- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:TWITTER];
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self fetchCurrentAccount];
    
    NSLog(@"[%s] IsLoggedIn: %@", __func__, self.isLoggedIn);
    
    if ([self.isLoggedIn isEqualToNumber: [NSNumber numberWithBool:YES]]) {
        UIViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
        
        if ([mvc respondsToSelector:@selector(sync_data)]) {
            [mvc performSelector:@selector(sync_data)];
        }

        [self.navigationController presentViewController:mvc animated:YES completion:nil];
    }else {
        [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"] animated:YES  completion:nil];
    }
}

- (void)performLogin:(NSInteger)serviceId {
    [self initOauthUrls];
    
    ARLOauthWebViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
   
    svc.NavigationAfterClose = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    switch (serviceId) {
        case FACEBOOK:
            [svc loadAuthenticateUrl: self.facebookLoginString delegate:svc];
            break;
        case GOOGLE:
            [svc loadAuthenticateUrl: self.googleLoginString delegate:svc];
            break;
        case LINKEDIN:
            [svc loadAuthenticateUrl: self.linkedInLoginString delegate:svc];
            break;
        case TWITTER:
            [svc loadAuthenticateUrl: self.twitterLoginString delegate:svc];
            break;
    }
}

- (void) initOauthUrls {
    NSDictionary* network = [ARLNetwork oauthInfo];
    
    for (NSDictionary* dict in [network objectForKey:@"oauthInfoList"]) {
        NSLog(@"[%s] %@", __func__, [dict objectForKey:@"providerId"]);
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
    
//    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
//        self.navigationItem.title = NSLocalizedString(@"Logout", nil);
//    } else {
//        self.navigationItem.title = NSLocalizedString(@"Login", nil);orientat
//    }
}

- (void) addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
        self.wespotLabel,   @"wespot",
        self.usernameEdit,  @"username",
        self.passwordEdit,  @"password",
        self.loginButton,   @"login",
        self.view,          @"view",
        self.scrollView,    @"scroll",
        self.background,    @"background",
        nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.wespotLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameEdit.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordEdit.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.background.translatesAutoresizingMaskIntoConstraints = NO;
 
    // Size UIScrollView to View.
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeWidth
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeHeight
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeLeft
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeLeft
                               multiplier:1.0
                               constant:0]];

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[wespot(84)]-[username]-[password]-[login]",10 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
 
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
   [self.view addConstraint:[NSLayoutConstraint
                                constraintWithItem:self.wespotLabel
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                toItem:self.view
                                attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.usernameEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.passwordEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.loginButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];

    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[username(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[password(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[login(==200)]"
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

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) tabbarHeight {
    return self.tabBarController.tabBar.bounds.size.height;
}

-(UIInterfaceOrientation) interfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboard.
    [textField resignFirstResponder];

    //Add action you want to call here.
    if ([textField isEqual:self.passwordEdit]) {
        [self loginButtonAction:self.loginButton];
    }
    
    return YES;
}

@end
