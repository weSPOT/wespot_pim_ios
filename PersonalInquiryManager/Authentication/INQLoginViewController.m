//
//  INQLoginViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQLoginViewController.h"
//#import "INQMainViewController.h"

@interface INQLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wespotLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameEdit;
@property (weak, nonatomic) IBOutlet UITextField *passwordEdit;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *googleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *linkedinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *twitterButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender;
- (IBAction)googleButtonAction:(UIBarButtonItem *)sender;
- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender;
- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender;
- (IBAction)loginButtonAction:(UIButton *)sender;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (strong, nonatomic) NSString * facebookLoginString;
@property (strong, nonatomic) NSString * googleLoginString;
@property (strong, nonatomic) NSString * linkedInLoginString;
@property (strong, nonatomic) NSString * twitterLoginString;

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (retain, nonatomic) NSMutableURLRequest *originalRequest;
@property (retain, nonatomic) NSString *token;

@end

@implementation INQLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self initOauthUrls];
    
    [self adjustLoginButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.usernameEdit.delegate = self;
    self.passwordEdit.delegate = self;
    
    [self addConstraints];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self adjustLoginButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  Login using Facebook.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)facebookButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:FACEBOOK];
}

/*!
 *  Login using Google.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)googleButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:GOOGLE];
}

/*!
 *  Login using Linked-in.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)linkedinButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:LINKEDIN];
}

/*!
 *  Login using Twitter.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)twitterButtonAction:(UIBarButtonItem *)sender {
    [self performLogin:TWITTER];
}

/*!
 *  Login using WeSpot.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)loginButtonAction:(UIButton *)sender {
    // See http://kemal.co/index.php/2012/02/fetching-data-with-getpost-methods-by-using-nsurlconnection/
   
    //if there is a connection going on just cancel it.
    [self.connection cancel];
    self.token = @"";
    
    //initialize new mutable data
    NSMutableData *data = [[NSMutableData alloc] init];
    self.receivedData = data;
    
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"http://wespot-arlearn.appspot.com/oauth/account/authenticateFw"];
    
    //initialize a request from url
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    self.originalRequest = request;
    
    //set http method
    [request setHTTPMethod:@"POST"];
     
    //initialize a post data
    NSString *postData = [[NSString alloc] initWithString:[[NSString alloc] initWithFormat:@"username=%@&password=%@&originalPage=MobileLogin.html&Login=Submit", self.usernameEdit.text, self.passwordEdit.text]];

    //set request content type we MUST set this value.
    [request setValue:@"text/html; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connection = connection;
    
    //start the connection
    [connection start];
}

/*!
 *  Handles Redirects of the Wespot Login and looks for the accessToken in the query string.
 *
 *  @param connection       <#connection description#>
 *  @param request          <#request description#>
 *  @param redirectResponse <#redirectResponse description#>
 *
 *  @return <#return value description#>
 */
-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) redirectResponse;
    
    int statusCode = [httpResponse statusCode];
    
    NSLog (@"HTTP status %d", statusCode);
    
    // http statuscodes between 300 & 400 is a redirect ...
    if (httpResponse && statusCode >= 300 && statusCode < 400)
    {
        NSLog(@"willSendRequest (from %@ to %@)", redirectResponse.URL, request.URL);
    }
    
    NSLog(@"HTTP request %@", self.connection.originalRequest.URL);
    
    if (redirectResponse)
    {
        NSMutableURLRequest *newRequest = [self.originalRequest mutableCopy]; // original request
        [newRequest setURL: [request URL]];
        
        NSLog (@"query to %@", newRequest.URL.query);
        NSLog (@"redirected to %@", newRequest.URL);
        
        
        NSString *query = [request URL].query;
        NSArray *array = [query componentsSeparatedByString:@"&"];
        for (NSString *item in array) {
            if ([item rangeOfString:@"accessToken="].location != NSNotFound) {
               self.token = [item substringFromIndex:[@"accessToken=" length]];
            }
        }

        return newRequest;
    }
    else
    {
        NSLog (@"original %@" , request.URL);
        
        return request;
    }
}

/*!
 *  This method might be calling more than one times according to incoming data size.
 *
 *  @param connection <#connection description#>
 *  @param data       <#data description#>
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

/*!
 *  If there is an error occured, this method will be called by connection.
 *
 *  @param connection <#connection description#>
 *  @param error      <#error description#>
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.token = @"";
    
    // NSLog(@"%@" , error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/*!
 *  If data is successfully received, this method will be called by connection.
 *
 *  @param connection <#connection description#>
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    // initialize convert the received data to string with UTF8 encoding
    //    NSString *htmlSTR = [[NSString alloc] initWithData:self.receivedData
    //                                              encoding:NSUTF8StringEncoding];

    // NSLog(@"%@" , htmlSTR);
    
    if ([self.token length]!=0) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Got an accessToken" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alert show];
        
        //Copied from ARLOauthWebViewController.m
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"auth"];
        
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSDictionary *accountDetails = [ARLNetwork accountDetails];
        
        [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
        
        NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
        
        [[ARLNotificationSubscriber sharedSingleton] registerAccount:fullId];
        
        [self navigateBack];
    }
}

- (void)navigateBack {
    if (ARLNetwork.isLoggedIn) {
        UIViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
        
        if (ARLNetwork.isLoggedIn) {
            UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
          
            if ([appDelegate respondsToSelector:@selector(clearDatabase)]) {
                [appDelegate performSelector:@selector(clearDatabase)];
                if ([appDelegate respondsToSelector:@selector(syncData)]) {
                    [appDelegate performSelector:@selector(syncData)];
                }
            }
        }
 
        
        [self.navigationController presentViewController:mvc animated:YES completion:nil];
        
        
    }else {
        [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"] animated:YES  completion:nil];
    }
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self navigateBack];
}

- (void)performLogin:(NSInteger)serviceId {
    [self initOauthUrls];
    
    ARLOauthWebViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
   
    svc.NavigationAfterClose = [self.storyboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    
    [self.navigationController pushViewController:svc animated:YES];
    
    switch (serviceId) {
        case FACEBOOK:
            [svc loadAuthenticateUrl: self.facebookLoginString delegate:svc];
            break;
        case GOOGLE:
            [svc loadAuthenticateUrl: self.googleLoginString delegate:svc];
            break;
        case LINKEDIN:
            [svc loadAuthenticateUrl: self.linkedInLoginString delegate:svc];
            break;
        case TWITTER:
            [svc loadAuthenticateUrl: self.twitterLoginString delegate:svc];
            break;
    }
}

- (void) initOauthUrls {
    NSDictionary* network = [ARLNetwork oauthInfo];
    
    for (NSDictionary* dict in [network objectForKey:@"oauthInfoList"]) {
        NSLog(@"[%s] %@", __func__, [dict objectForKey:@"providerId"]);
        switch ([(NSNumber*)[dict objectForKey:@"providerId"] intValue]) {
            case FACEBOOK:
                self.facebookLoginString = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&display=page&redirect_uri=%@&scope=publish_stream,email", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
            case GOOGLE:
                self.googleLoginString = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&scope=profile+email", [dict objectForKey:@"redirectUri"], [dict objectForKey:@"clientId"]];
                break;
            case LINKEDIN:
                self.linkedInLoginString = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=r_fullprofile+r_emailaddress+r_network&state=BdhOU9fFb6JcK5BmoDeOZbaY58&redirect_uri=%@", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
                break;
            case TWITTER:
                self.twitterLoginString = [NSString stringWithFormat:@"%@?twitter=init", [dict objectForKey:@"redirectUri"]];
                break;
                
        }
    }
}

- (void) adjustLoginButton  {
    if (ARLNetwork.isLoggedIn) {
        NSLog(@"Logout");
    } else {
        NSLog(@"Login");
    }
}

- (void) addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
        self.wespotLabel,   @"wespot",
        self.usernameEdit,  @"username",
        self.passwordEdit,  @"password",
        self.loginButton,   @"login",
        self.view,          @"view",
        self.scrollView,    @"scroll",
        self.background,    @"background",
        nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.wespotLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameEdit.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordEdit.translatesAutoresizingMaskIntoConstraints = NO;
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.background.translatesAutoresizingMaskIntoConstraints = NO;
 
    // Size UIScrollView to View.
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeWidth
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeHeight
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeLeft
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeLeft
                               multiplier:1.0
                               constant:0]];

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[wespot(84)]-[username]-[password]-[login]",10 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
 
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
   [self.view addConstraint:[NSLayoutConstraint
                                constraintWithItem:self.wespotLabel
                                attribute:NSLayoutAttributeCenterX
                                relatedBy:NSLayoutRelationEqual
                                toItem:self.view
                                attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.usernameEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.passwordEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.loginButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];

    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[username(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[password(==300)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[login(==200)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Background
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"H:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

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

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    //Dismiss the keyboard.
    [textField resignFirstResponder];

    //Add action you want to call here.
    if ([textField isEqual:self.passwordEdit]) {
        [self loginButtonAction:self.loginButton];
    }
    
    return YES;
}

@end
