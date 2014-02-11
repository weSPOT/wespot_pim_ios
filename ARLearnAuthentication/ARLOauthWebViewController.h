//
//  ARLOauthWebViewController.h
//  ARLearn
//
//  Created by Stefaan Ternier on 6/24/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARLNotificationSubscriber.h"

@class ARLOauthListViewController;

@interface ARLOauthWebViewController : UIViewController  <UIWebViewDelegate>

@property (weak, nonatomic) NSString * domain;
@property (strong, nonatomic) UIViewController * selfRef;
@property (strong, nonatomic) UINavigationController *NavigationAfterClose;

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id) aDelegate;

@end
