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

/*!
 *  Load Content.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*!
 *  Load and Align Content.
 *
 *  @param animated Animation is enabled if YES.
 */
- (void) viewWillAppear:(BOOL)animated {
    NSString * badgesUrl = [NSString stringWithFormat:@"http://ariadne.cs.kuleuven.be/navi/?user=%@&account=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
    
    [self loadAuthenticateUrl:badgesUrl delegate:self];
}

/*!
 *  Align Content.
 *
 *  @param animated Animation is enabled if YES.
 */
- (void) viewDidAppear:(BOOL)animated {
//    NSString * badgesUrl = [NSString stringWithFormat:@"http://ariadne.cs.kuleuven.be/navi/?user=%@&account=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"accountLocalId"], [[NSUserDefaults standardUserDefaults] objectForKey:@"accountType"]];
//    
//    [self loadAuthenticateUrl:badgesUrl delegate:self];
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
    UIWebView *web = (UIWebView*)(self.view);

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
