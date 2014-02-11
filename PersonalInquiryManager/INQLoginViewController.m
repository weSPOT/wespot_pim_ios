//
//  INQLoginViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQLoginViewController.h"

@interface INQLoginViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, services) {
    /*!
     *  Facebook.
     */
    FACEBOOK = 0,
    /*!
     *  Google.
     */
    GOOGLE = 1,
    /*!
     *  Linked-in
     */
    LINKEDIN = 2,
    /*!
     *  Twitter.
     */
    TWITTER = 3,
};

@property (weak, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *googleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *linkedinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *twitterButton;

- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender;
- (IBAction)googleButtonAction:(UIBarButtonItem *)sender;
- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender;
- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender;
- (IBAction)loginButtonAction:(UIButton *)sender;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@end

@implementation INQLoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self adjustLoginButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self adjustLoginButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self adjustLoginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)googleButtonAction:(UIBarButtonItem *)sender {
    ARLOauthWebViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
    svc.NavigationAfterClose = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabs"];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    [svc loadAuthenticateUrl:  @"https://accounts.google.com/o/oauth2/auth?redirect_uri=http://streetlearn.appspot.com/oauth/google&response_type=code&client_id=594104153413-8ddgvbqp0g21pid8fm8u2dau37521b16.apps.googleusercontent.com&approval_prompt=force&scope=profile+email" delegate:svc];
}

- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)loginButtonAction:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
       [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainTabs"] animated:YES  completion:nil];
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
        self.navigationItem.title = NSLocalizedString(@"Logout", nil);
    } else {
        self.navigationItem.title = NSLocalizedString(@"Login", nil);
    }
}

@end
