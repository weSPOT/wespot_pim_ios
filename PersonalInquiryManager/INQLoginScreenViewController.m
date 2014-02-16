//
//  INQSplashScreenViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQLoginScreenViewController.h"

@interface INQLoginScreenViewController (UIConstraintBasedLayoutDebugging)

@end

@implementation INQLoginScreenViewController

//@synthesize account = _account;

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchCurrentAccount];
    
    [self createLoginButton];
    [self adjustLoginButton];
}

- (Account *) fetchCurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate performSelector:@selector(fetchCurrentAccount) withObject:nil];
}

/*!
 *  Sets the isLoggedIn property of the AppDelegate.
 */
- (NSNumber *)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    
    return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil];
}

/*!
 *  Outlet for Login Button Click.
 *
 *  If clicked (and not logged-in) we swap the default (splash logo/login) for the oauth login view.
 *
 *  If clicked (and logged-in) we swap the view for the default (splash logo/login) view.
 */
- (void) loginClicked {  
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [ARLAccountDelegator deleteCurrentAccount:appDelegate.managedObjectContext];

        [self adjustLoginButton];
    } else {
        INQOauthViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginServices"];
        
        [self.navigationController pushViewController:controller animated:YES];
        // [self presentViewController:controller animated:TRUE completion:nil];
    }
}

- (void) createLoginButton {
    if (!self.loginButton) {
        self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.loginButton];
        
        NSDictionary * viewsDictionary;
        
        viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                           self.loginButton,  @"loginButton",
                           nil];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"V:|-[loginButton]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[loginButton]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
    }
}

- (void) adjustLoginButton  {
    if (self.isLoggedIn == [NSNumber numberWithBool:YES]) {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    }
}

@end
