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

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*!
 *  Return the number of Rows in a Section.
 *
 *  @param tableView The Table to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

/*!
 *  Return the Table Data one Cell at a Time.
 *
 *  @param tableView The Table to be served.
 *  @param indexPath The IndexPath of the TableCell.
 *
 *  @return The Cell Content.
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
    //UIViewController * newViewController;

    // Create the new ViewController.
    NSString *loginString  = [self getOAuthLoginUrl:[NSNumber numberWithInt:[indexPath item]]];
    
    if (loginString) {
        ARLOauthWebViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"oauthWebView"];
        
        //ARLOauthWebViewController* svc = [[ARLOauthWebViewController alloc] init];
        //[self presentViewController:svc animated:YES completion:nil];
        [self.navigationController pushViewController:svc animated:YES];
        
        [svc loadAuthenticateUrl:  @"https://accounts.google.com/o/oauth2/auth?redirect_uri=http://streetlearn.appspot.com/oauth/google&response_type=code&client_id=594104153413-8ddgvbqp0g21pid8fm8u2dau37521b16.apps.googleusercontent.com&approval_prompt=force&scope=profile+email" delegate:svc];
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
