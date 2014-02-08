//
//  INQOauthViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQOauthViewController.h"

@interface INQOauthViewController ()

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) IBOutlet UITableView *LoginServices;

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, services) {
    /*!
     *  Facebook.
     */
    FACEBOOK = 0,
    /*!
     *  Google.
     */
    GOOGLE = 1,
    /*!
     *  Linked-in
     */
    LINKEDIN = 2,
    /*!
     *  Twitter.
     */
    TWITTER = 3,
};

@end

@implementation INQOauthViewController

-(NSString*) cellIdentifier {
    return  @"Cell";
}

/*!
 *  Load Content.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

/*!
 *  Creates Cells for the UITableView.
 *
 *  @param tableView The UITableView
 *  @param indexPath The index path containing the grouping/section and record index.
 *
 *  @return The INQInquiryPartCell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
   if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    switch ([indexPath item]) {
        case GOOGLE:
            cell.textLabel.text = @"Google";
            break;
        case FACEBOOK:
            cell.textLabel.text = @"Facebook";
            break;
        case LINKEDIN:
            cell.textLabel.text = @"Linked-in";
            break;
        case TWITTER:
            cell.textLabel.text = @"Twitter";
            break;
    }
    return cell;
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * newViewController;
    NSString *loginString;
    
    switch ([indexPath item]){
        case GOOGLE: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesView"];
            
            loginString  = [self getOAuthLoginUrl:[NSNumber numberWithInt:[indexPath item]]];
            
            // Pass the parameters to render.
            // [newViewController performSelector:@selector(setHypothesis:) withObject:self.inquiry.hypothesis];
        }
            break;
    }
    
    if (loginString) {
        ARLOauthWebViewController* svc = [[ARLOauthWebViewController alloc] init];
        [self presentViewController:svc animated:YES completion:nil];
        [svc loadAuthenticateUrl:loginString delegate:svc];
    }
}


-(NSString *) getOAuthLoginUrl:(NSNumber *) serviceId {
    NSString *url;
    NSDictionary* network = [ARLNetwork oauthInfo];
    NSDictionary* dict;
    
    for (NSDictionary* info in [network objectForKey:@"oauthInfoList"]) {
        if ([(NSNumber*)[info objectForKey:@"providerId"] isEqualToNumber:serviceId])
        {
            dict=info;
            break;
        }
    }
    
    switch ([serviceId intValue]) {
        case FACEBOOK:
            url = [NSString stringWithFormat:@"https://graph.facebook.com/oauth/authorize?client_id=%@&display=page&redirect_uri=%@&scope=publish_stream,email", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
             break;
        
        case GOOGLE :
            url = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&scope=profile+email", [dict objectForKey:@"redirectUri"], [dict objectForKey:@"clientId"]];
            break;
            
        case LINKEDIN:
            url = [NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id=%@&scope=r_fullprofile+r_emailaddress+r_network&state=BdhOU9fFb6JcK5BmoDeOZbaY58&redirect_uri=%@", [dict objectForKey:@"clientId"], [dict objectForKey:@"redirectUri"]];
            break;
            
        case TWITTER:
            url = [NSString stringWithFormat:@"%@?twitter=init", [dict objectForKey:@"redirectUri"]];
            break;
    }
    
    return url;
}

@end
