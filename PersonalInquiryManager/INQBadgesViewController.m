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

@implementation INQBadgesViewController

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

- (void) viewDidAppear:(BOOL)animated {
    NSString * badgesUrl = [NSString stringWithFormat:@"http://ariadne.cs.kuleuven.be/navi/?user=%@&account=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    
    [self loadAuthenticateUrl:badgesUrl delegate:self];
    
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id) aDelegate {
    UIWebView *web = (UIWebView*)(self.view.subviews[1]);

    web.delegate = self;
    web.scalesPageToFit = YES;
    
    // self.domain = [[NSURL URLWithString:authenticateUrl] host];
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
}

@end
