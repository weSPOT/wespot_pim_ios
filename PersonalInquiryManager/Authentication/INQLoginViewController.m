//
//  INQLoginViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/11/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQLoginViewController.h"

@interface INQLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *wespotLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameEdit;
@property (weak, nonatomic) IBOutlet UITextField *passwordEdit;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)loginButtonAction:(UIButton *)sender;
- (IBAction)backButtonAction:(UIBarButtonItem *)sender;

@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *receivedData;
@property (retain, nonatomic) NSMutableURLRequest *originalRequest;
@property (retain, nonatomic) NSString *token;

@end

@implementation INQLoginViewController

/*!
 *  See SDK.
 * 
 *  Set background, clear fields and add layout constraints.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonAction:)];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.usernameEdit.delegate = self;
    self.passwordEdit.delegate = self;
    
    [self addConstraints];
}

/*!
 *  See SDK.
 *
 *  @param animated <#animated description#>
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/*!
 *  See SDK.
 *
 *  @param animated <#animated description#>
 */
-(void) viewDidDisappear:(BOOL)animated
{
     [super viewDidDisappear:animated];
}

/*!
 *  See SDK.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  Login using WeSpot.
 *
 *  Just mimic a submit of the login form Stefaan made.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)loginButtonAction:(UIButton *)sender {
    @autoreleasepool {
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
        NSString *postData =  [NSString stringWithFormat:@"username=%@&password=%@&originalPage=MobileLogin.html&Login=Submit", self.usernameEdit.text, self.passwordEdit.text];
        
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
    
    DLog (@"HTTP status: %d", statusCode);
    
    // http statuscodes between 300 & 400 is a redirect ...
    if (httpResponse && statusCode >= 300 && statusCode < 400)
    {
        DLog(@"WillSendRequest: from %@ to %@", redirectResponse.URL, request.URL);
    }
    
    DLog(@"HTTP request: %@", self.connection.originalRequest.URL);
    
    if (redirectResponse)
    {
        NSMutableURLRequest *newRequest = [self.originalRequest mutableCopy]; // original request
        [newRequest setURL: [request URL]];
        
        if ([newRequest.URL.query isEqualToString:@"incorrectPassword"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Incorrect Password", @"Incorrect Password") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
            [alert show];
            
        }else if ([newRequest.URL.query isEqualToString:@"incorrectUsername"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"Incorrect Username", @"Incorrect Username") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            DLog (@"Query to: %@", newRequest.URL.query);
            DLog (@"Redirected to: %@", newRequest.URL);
            
            NSString *query = [request URL].query;
            NSArray *array = [query componentsSeparatedByString:@"&"];
            for (NSString *item in array) {
                if ([item rangeOfString:@"accessToken="].location != NSNotFound) {
                    self.token = [item substringFromIndex:[@"accessToken=" length]];
                }
            }
            
            return newRequest;
        }
        
        return NULL;
    }
    else
    {
        DLog (@"Original url: %@" , request.URL);
        
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
    
    ELog(error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") message:error.description delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
    [alert show];
}

/*!
 *  If data is successfully received, this method will be called by connection.
 *
 *  @param connection <#connection description#>
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if ([self.token length]!=0) {
        //Copied from ARLOauthWebViewController.m
        [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:@"auth"];
        
        // Log("Creating new Account");
        
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSDictionary *accountDetails = [ARLNetwork accountDetails];
        
        [Account accountWithDictionary:accountDetails inManagedObjectContext:appDelegate.managedObjectContext];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"localId"] forKey:@"accountLocalId"];
        [[NSUserDefaults standardUserDefaults] setObject:[accountDetails objectForKey:@"accountType"] forKey:@"accountType"];
        
        // veg 26-06-2014 disabled because notification api is disabled.
        //        NSString *fullId = [NSString stringWithFormat:@"%@:%@",  [accountDetails objectForKey:@"accountType"], [accountDetails objectForKey:@"localId"]];
        //        [[ARLNotificationSubscriber sharedSingleton] registerAccount:fullId];
       
        [self navigateBack];
    }
}

/*!
 *  Handle the Back Button.
 */
- (void)navigateBack {
    [self.navigationController presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SplashNavigation"] animated:NO completion:nil];
}

/*!
 *  Handle the Back Button.
 *
 *  @param sender <#sender description#>
 */
- (IBAction)backButtonAction:(UIBarButtonItem *)sender {
    [self navigateBack];
}

/*!
 *  Add Layout Constraints.
 */
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

/*!
 *  Handle the Return key (move either to next field or submit).
 *
 *  @param textField <#textField description#>
 *
 *  @return <#return value description#>
 */
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
