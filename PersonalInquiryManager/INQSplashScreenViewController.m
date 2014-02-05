//
//  INQSplashScreenViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQSplashScreenViewController.h"

@implementation INQSplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.loggedInView) {
        NSLog(@"[%s] hide tabBar", __func__);
        self.tabBarController.tabBar.hidden = YES;
    } else {
        self.tabBarController.tabBar.hidden = NO;
    }
}

/*!
 *  Create the ARLEarn Logo UIImageView.
 */
- (void) createARLearnImage {
    if (!self.arlearnImage) {
        self.arlearnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wespot_logo.png"]];
        self.arlearnImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.arlearnImage.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.view addSubview:self.arlearnImage];
    }
}

/*!
 *  Override creation of My Runs UIButton.
 *
 *  Note: Create a hidden one so base class keeps working.
 */
- (void) createMyRunsButton {
    if (!self.myRunsButton) {
        self.myRunsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.myRunsButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.myRunsButton addTarget:self action:@selector(myRunsClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.myRunsButton];
    }
    [self.myRunsButton setTitle:@"To Hide" forState:UIControlStateNormal];
    self.myRunsButton.hidden= YES;
}

/*!
 *  Outlet for Login Button Click.
 *
 *  If clicked (and not logged-in) we swap the default (splash logo/login) for the oauth login view.
 *
 *  If clicked (and logged-in) we swap the view for the default (splash logo/login) view.
 */
- (void) loginClicked {
    
    if (self.account) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [ARLAccountDelegator deleteCurrentAccount:appDelegate.managedObjectContext];
        
        self.account = nil;
        self.tabBarController.tabBar.hidden = YES;
        
        [self createViewsProgrammatically];
    } else {
        ARLOauthViewController *controller = [[INQOauthViewController alloc] init];
        
        [self presentViewController:controller animated:TRUE completion:nil];
    }
}

@end
