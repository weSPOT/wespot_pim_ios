//
//  INQBadgesViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQBadgesViewController.h"

@interface INQBadgesViewController ()

@end

/*!
 *  NOTE: The UINavigationBar is added and positioned manually so does not originate fro a navigation controller (yet).
 */
@implementation INQBadgesViewController

/*!
 *  Position NavigationBar and WebView manually with constraints.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable some conflicting XCODE habits.
    //
    ((UIView*)(self.view.subviews[0])).translatesAutoresizingMaskIntoConstraints = NO;
    ((UIView*)(self.view.subviews[1])).translatesAutoresizingMaskIntoConstraints = NO;
    
    // Remove constraints.
    [self.view removeConstraints:[self.view constraints]];
    
    NSDictionary * viewsDictionary =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     self.view.subviews[0], @"navbar",
     self.view.subviews[1], @"web",
     nil];
    
    NSString *constraint;
    
    //http://www.idev101.com/code/User_Interface/sizes.html
    //
    constraint = @"V:|-20-[navbar]-[web]-|";
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    constraint = @"H:|-5-[navbar]-5-|";
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    constraint = @"H:|-5-[web]-5-|";
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*!
 *  Load Content.
 *
 *  @param animated Animation is enabled if YES.
 */
- (void) viewDidAppear:(BOOL)animated {
    NSString * badgesUrl = [NSString stringWithFormat:@"http://ariadne.cs.kuleuven.be/navi/?user=%@&account=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    
    [self loadAuthenticateUrl:badgesUrl delegate:self];
    
}

/*!
 *  Setup UIWebViewDelegate's based Authentication.
 *
 *  NOTE: Seems ununsed.
 *
 *  @param authenticateUrl The Url to Authenticate against.
 *  @param aDelegate       The Delegate.
 */
- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id) aDelegate {
    UIWebView *web = (UIWebView*)(self.view.subviews[1]);

    web.delegate = self;
    web.scalesPageToFit = YES;
    
    // self.domain = [[NSURL URLWithString:authenticateUrl] host];
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
}

@end
