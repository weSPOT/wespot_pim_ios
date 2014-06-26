//
//  ARLOauthWebViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 6/24/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
// veg 26-06-2014 disabled because notification api is disabled.
//#import "ARLNotificationSubscriber.h"
#import "INQMainViewController.h"
#import "ARLCloudSynchronizer.h"
#import "ARLAppDelegate.h"

@class ARLOauthListViewController;

@interface ARLOauthWebViewController : UIViewController  <UIWebViewDelegate>

@property (weak, nonatomic) NSString * domain;
@property (strong, nonatomic) UINavigationController *NavigationAfterClose;

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl name:(NSString *) name delegate:(id) aDelegate;

@end
