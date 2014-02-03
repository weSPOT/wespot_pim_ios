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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] init];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.webView];
    
    NSDictionary * viewsDictionary =
    [[NSDictionary alloc] initWithObjectsAndKeys: self.webView, @"webView", nil];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[webView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|[webView]|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
}

- (void) viewDidAppear:(BOOL)animated {
    NSString * badgesUrl = [NSString stringWithFormat:@"http://ariadne.cs.kuleuven.be/navi/?user=%@&account=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    [self loadAuthenticateUrl:badgesUrl delegate:self];
    
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id) aDelegate {

    //    self.delegate = aDelegate;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
//    self.domain = [[NSURL URLWithString:authenticateUrl] host];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
