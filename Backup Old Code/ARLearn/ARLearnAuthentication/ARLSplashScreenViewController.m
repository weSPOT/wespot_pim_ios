//
//  ARLSplashScreenViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/10/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLSplashScreenViewController.h"

@interface ARLSplashScreenViewController (UIConstraintBasedLayoutDebugging)

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation ARLSplashScreenViewController

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

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
//     return (interfaceOrientation == UIInterfaceOrientationPortrait) ;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/*!
 *  Load Content.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.loggedInView.layer setCornerRadius:10.0f];
    [self.loggedInView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loggedInView.layer setBorderWidth:1.5f];
}

/*!
 *  Add Gradient underneath the other Views.
 */
- (void) addGradient {
    UIColor *darkOp = [UIColor colorWithRed:(99.0f/256.0f) green:(187.0f/256.0f) blue:(255.0f/256.0f)alpha:0.5];
    UIColor *lightOp = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.01];
    
    NSLog(@"[%s]", __func__);
    
    // Create the gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    // Set colors
    gradient.colors = [NSArray arrayWithObjects:
                       (id)lightOp.CGColor,
                       (id)darkOp.CGColor,
                       nil];
    
    // Set bounds
    gradient.frame = self.view.bounds;
    
    // Add the gradient to the view
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.view setNeedsDisplay];
}

/*!
 *  Sets the isLoggedIn property of the AppDelegate.
 */
- (void)doUpdateLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(setIsLoggedIn:) withObject: [NSNumber numberWithBool:self.account!=nil?YES:NO]];
}

/*!
 *  Sets the isLoggedIn property of the AppDelegate.
 */
- (NSNumber *)isLoggedIn {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];

    return [appDelegate performSelector:@selector(isLoggedIn) withObject: nil];
}

/*!
 *  Load and Align Content.
 *
 *  @param animated Animation is enabled if YES.
 */
- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"[%s]", __func__);
    
    [self CurrentAccount];
    [self createViewsProgrammatically];
    
    [self.loggedInView setAccount:self.account];
    
    [self doUpdateLoggedIn];
    
    if (self.isLoggedIn!=0 || self.isLoggedIn==nil) {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
    }
    
    [self doUpdateLayout];
}

/*!
 *  Align Content.
 *
 *  @param animated Animation is enabled if YES.
 */
- (void) viewDidAppear:(BOOL)animated {
    NSLog(@"[%s]", __func__);
    
    [super viewDidAppear:animated];
    
    [self doUpdateLayout];
}

- (void) createViewsProgrammatically {
    [self createLoginButton];
    [self createARLearnImage];
    
    NSLog(@"[%s]", __func__);
    
    if (self.isLoggedIn) {
        [self createLoggedInView];
        [self createMyRunsButton];
        [self createGamesButton];
        
        self.gamesButton.hidden= YES;
    } else {
        [self.loggedInView removeFromSuperview];
        [self.myRunsButton removeFromSuperview];
        [self.gamesButton removeFromSuperview];
        
        self.loggedInView = nil;
        self.myRunsButton = nil;
        self.gamesButton = nil;
    }
    
    [self doUpdateLayout];
}

- (void) createLoggedInView {
    if (!self.loggedInView) {
        self.loggedInView = [[ARLLoggedInView alloc] init];
        [self.view addSubview:self.loggedInView];
    }
}

- (void) createARLearnImage {
    if (!self.arlearnImage) {
        self.arlearnImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arlearn_logo_background.png"]];
        self.arlearnImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.arlearnImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.arlearnImage];
    }
}

- (void) createLoginButton {
    if (!self.loginButton) {
        self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.loginButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.loginButton];
    }
    
    if (self.isLoggedIn) {
        [self.loginButton setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    }
}

- (void) createMyRunsButton {
    if (!self.myRunsButton) {
        self.myRunsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.myRunsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.myRunsButton addTarget:self action:@selector(myRunsClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.myRunsButton];
    }
    [self.myRunsButton setTitle:NSLocalizedString(@"MyRuns", nil) forState:UIControlStateNormal];
}

- (void) createGamesButton {
    if (!self.gamesButton) {
        self.gamesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.gamesButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.gamesButton addTarget:self action:@selector(gamesClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.gamesButton];
    }
    [self.gamesButton setTitle:NSLocalizedString(@"MyGames", nil) forState:UIControlStateNormal];
}

- (void) setPortraitConstraints {
    NSDictionary * viewsDictionary;
    NSString* verticalContstraint;
    
    NSLog(@"[%s]", __func__);
    
    [self.view removeConstraints:[self.view constraints]];
    
    if (self.account) {
        viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
            self.myRunsButton, @"myRunsButton",
            self.loginButton,  @"loginButton",
            self.loggedInView, @"loggedInView",
            self.arlearnImage, @"arlearnImage",
           //self.gamesButton, @"gamesButton",
           nil];

        // verticalContstraint = @"V:|-[loggedInView(==100)]-[arlearnImage(==150)]-(>=10)-[loginButton]-[myRunsButton]-[gamesButton]-|";

        verticalContstraint = [NSString stringWithFormat:@"V:|-%@-[loggedInView(==100)]-[arlearnImage(==150)]-(>=10)-[loginButton]-[myRunsButton]-%@-|",
                                [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8],
                                [NSNumber numberWithInteger:self.tabbarHeight +8]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[myRunsButton]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
//      [self.view addConstraints:[NSLayoutConstraint
//                                 constraintsWithVisualFormat:@"H:|-[gamesButton]-|"
//                                 options:NSLayoutFormatDirectionLeadingToTrailing
//                                 metrics:nil
//                                 views:viewsDictionary]];
         [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[loggedInView]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
    } else {
        viewsDictionary= [[NSDictionary alloc] initWithObjectsAndKeys:
            self.arlearnImage, @"arlearnImage",
            self.loginButton,  @"loginButton",
            nil];
        
        verticalContstraint = [NSString stringWithFormat:@"V:|-%@-[arlearnImage(==150)]-(>=10)-[loginButton(==40)]-|",
                               [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8]];
    }
    
    NSLog(@"[%s] %@", __func__, verticalContstraint);

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalContstraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[arlearnImage]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[loginButton]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

- (void) setLandscapeConstraints {
    NSDictionary * viewsDictionary;
    NSString *verticalConstraint;
    
    NSLog(@"[%s]", __func__);
    
    [self.view removeConstraints:[self.view constraints]];
    
    if (self.account) {
       viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
            self.myRunsButton, @"myRunsButton",
            self.loginButton,  @"loginButton",
            self.loggedInView, @"loggedInView",
            self.arlearnImage, @"arlearnImage",
            // self.gamesButton,  @"gamesButton",
            nil];
    
        verticalConstraint = [NSString stringWithFormat:@"V:|-%@-[loggedInView(==80)]-(>=20)-[loginButton]-[myRunsButton]-|",
                                          [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%@-[arlearnImage(==100)]|",
                                                                [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8]]
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[arlearnImage(==200)]-[loggedInView]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[arlearnImage(==200)]-[myRunsButton]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        
        //        [self.view addConstraints:[NSLayoutConstraint
        //                                   constraintsWithVisualFormat:@"H:|-[arlearnImage(==200)]-[gamesButton]-|"
        //                                   options:NSLayoutFormatDirectionLeadingToTrailing
        //                                   metrics:nil
        //                                   views:viewsDictionary]];
    } else {
        viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.loginButton,  @"loginButton",
                          self.arlearnImage, @"arlearnImage",
                          nil];
        
        verticalConstraint = [NSString stringWithFormat:@"V:|-%@-[arlearnImage(==150)]-(>=10)-[loginButton(==40)]-|",
                               [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[arlearnImage]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
    }
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalConstraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    
    // NOTE: buttons in the right sidebar?
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[loginButton]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

- (void)doUpdateLayout
{
    if ((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
        [self setLandscapeConstraints];
    } else {
        [self setPortraitConstraints];
    }
    
    if (self.view.layer.sublayers.count>0 && [self.view.layer.sublayers[0] isKindOfClass:[CAGradientLayer class]]) {
        [[self.view.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    }

    [self addGradient];
}

/*!
 *  Re-apply Constrants and Gradient.
 *
 *  @param fromInterfaceOrientation The new orientation.
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self doUpdateLayout];
}

- (void) CurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(CurrentAccount) withObject:nil];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void) loginClicked {
    if (self.account) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [ARLAccountDelegator deleteCurrentAccount:appDelegate.managedObjectContext];
        self.account = nil;
        [self doUpdateLoggedIn];
        [self createViewsProgrammatically];
    } else {
        ARLOauthViewController *controller = [[ARLOauthViewController alloc] init];
        
        [self presentViewController:controller animated:TRUE completion:nil];
    }
}

- (void) myRunsClicked {
    UINavigationController * monitorMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"myRunsID"];
    [self presentViewController:monitorMenuViewController animated:NO completion:nil];
}

- (void) gamesClicked {
    UINavigationController * monitorMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"gameLibrary"];
 
    [self presentViewController:monitorMenuViewController animated:NO completion:nil];
}

@end
