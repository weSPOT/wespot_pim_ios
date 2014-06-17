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

- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@end

@implementation ARLOauthWebViewController

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController setToolbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
}

-(void)viewDidDisappear:(BOOL)animated
{
    // http://stackoverflow.com/questions/10018418/uiwebview-not-freeing-all-live-bytes-using-arc
    [self.webView setDelegate:nil];
    [self.webView loadHTMLString: @"" baseURL: nil];
    //    [self.webView stopLoading];
    //    [self.webView removeFromSuperview];
    
    [super viewDidDisappear:animated];
    
    //    self.webView = nil;
    //    self.NavigationAfterClose = nil;
    
    //    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    //    [NSURLCache setSharedURLCache:sharedCache];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
}

- (void)loadAuthenticateUrl:(NSString *)authenticateUrl name:(NSString *) name delegate:(id) aDelegate {
    [self deleteARLearnCookie];

    self.domain = [[NSURL URLWithString:authenticateUrl] host];
    
    @autoreleasepool {
//        [self.webView loadHTMLString:[NSString stringWithFormat:@"<h1>Connecting to %@.</h1>", name] baseURL:nil];
//        
       [CATransaction flush];
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authenticateUrl]]];
        //cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0]];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
   
    NSString *urlAsString =request.URL.description;
  
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
        @autoreleasepool {
            NSArray *listItems = [urlAsString componentsSeparatedByString:@"accessToken="];
            NSString *lastObject =[listItems lastObject];
            
            listItems = [lastObject componentsSeparatedByString:@"&"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[listItems objectAtIndex:0] forKey:@"auth"];
            
            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSDictionary *accountDetails = [ARLNetwork accountDetails];
            
            [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
            [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
            [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
            
            NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
            
            [[ARLNotificationSubscriber sharedSingleton] registerAccount:fullId];
        }
        
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
        return YES;
    }
    
    return YES;
}

-(void) close {
    if (self.NavigationAfterClose) {
        [self.navigationController presentViewController:self.NavigationAfterClose animated:NO completion:nil];
        
        self.NavigationAfterClose = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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

/*!
 *  Handle the Back Button.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    if (self.NavigationAfterClose) {
        [self.navigationController presentViewController:self.NavigationAfterClose animated:NO completion:nil];
        
        self.NavigationAfterClose = nil;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
