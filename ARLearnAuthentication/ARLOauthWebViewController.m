//
//  ARLOauthWebViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 6/24/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLOauthWebViewController.h"
#import "ARLAccountDelegator.h"
#import "ARLAppDelegate.h"
#import "Account+create.h"

@interface ARLOauthWebViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ARLOauthWebViewController

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl delegate:(id) aDelegate {
    [self deleteARLearnCookie];

    self.domain = [[NSURL URLWithString:authenticateUrl] host];
    
    UIWebView *web = (UIWebView *)self.view;
    
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   
    NSString * urlAsString =request.URL.description;
  
    NSLog(@"[%s] %@",__func__, request.URL.absoluteString);
    if (!urlAsString)
    {
        return YES;
    }
    
    if (!([urlAsString rangeOfString:@"twitter?denied="].location == NSNotFound)) {
        [self close];
        return YES;
    }

    if (!([urlAsString rangeOfString:@"error=access_denied"].location == NSNotFound)) {
        [self close];
        return YES;
    }
    
    if (!([urlAsString rangeOfString:@"oauth.html?accessToken="].location == NSNotFound)) {
        NSArray *listItems = [urlAsString componentsSeparatedByString:@"accessToken="];
        NSString * lastObject =[listItems lastObject];
        
        listItems = [lastObject componentsSeparatedByString:@"&"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[listItems objectAtIndex:0] forKey:@"auth"];
        
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSDictionary *accountDetails = [ARLNetwork accountDetails];

        [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];

        NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
        
        [[ARLNotificationSubscriber sharedSingleton] registerAccount:fullId];
        
        [self close];
        
        return YES;
        
    } else if (!([urlAsString rangeOfString:@"about:blank"].location == NSNotFound)) {
        return YES;
        
    } else if (!([urlAsString rangeOfString:@"accounts.google.com/o/oauth2/approval?"].location == NSNotFound)) {
        return YES;
        
    } else if (!([urlAsString rangeOfString:@"google?code="].location == NSNotFound)) {
        return YES;
        
    } else if (!([urlAsString rangeOfString:@"o/oauth2/auth?redirect_uri"].location == NSNotFound)) {
        return YES;
        
    } else if (!([urlAsString rangeOfString:@"appspot.com/oauth"].location == NSNotFound)) {
        return YES;
        
    }else if (!([urlAsString rangeOfString:@"authenticate?oauth_token="].location == NSNotFound)) {
        return YES;
        
    }else if (!([urlAsString rangeOfString:@"oauth/twitter?oauth_token="].location == NSNotFound)) {
        return YES;
        
    }else if (!([urlAsString rangeOfString:@"https://api.twitter.com/oauth/authenticate"].location == NSNotFound)) {
        return YES;
        
    }else if (!([urlAsString rangeOfString:@"dialog/oauth"].location == NSNotFound)) {
        return YES;
        
    }else {
        NSLog(@"not found %@", urlAsString);
        return YES;
    }
    
    return YES;
}

-(void) close {
    if (self.NavigationAfterClose) {
        
//        if ([self.NavigationAfterClose respondsToSelector:@selector(sync_data)]) {
//            [self.NavigationAfterClose performSelector:@selector(sync_data)];
//        }
        
        [INQMainViewController sync_data];
        
        [self.navigationController presentViewController:self.NavigationAfterClose animated:YES  completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        // ß[self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) deleteARLearnCookie {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        if ([[cookie name] isEqualToString:@"arlearn.AccessToken"]) {
            [cookieJar deleteCookie:cookie];
        }
    }
}

@end
