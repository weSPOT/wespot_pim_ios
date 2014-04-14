//
//  ARLInviteFriendsViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 4/14/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQInviteFriendsViewController.h"

@interface INQInviteFriendsViewController ()

/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, profile) {
    /*!
     *  Friends.
     */
    FRIENDS = 0,
//    /*!
//     *  E-Mail.
//     */
//    EMAIL,
//    /*!
//     *  Account Type.
//     */
//    TYPE,
//    /*!
//     *  Picture
//     */
//    //    PICTURE,
//    //    /*!
//    //     *  Number of Profle Fields
//    //     */
    numFriends
};

@property (strong, nonatomic) NSArray *usersFriends;
@property (strong, nonatomic) NSArray *inquiryUsers;

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQInviteFriendsViewController

-(NSString*) cellIdentifier {
    return  @"InviteFriend";
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    Account * account = [ARLNetwork CurrentAccount];
    
    //    {
    //        result =     (
    //                      {
    //                          icon = "http://dev.inquiry.wespot.net/mod/profile/icondirect.php?lastcache=1391160890&joindate=1391160886&guid=26146&size=medium";
    //                          name = "Wim van der Vegt";
    //                          oauthId = 103021572104496509774;
    //                          oauthProvider = Google;
    //                      },
    //                      {
    //                          icon = "http://dev.inquiry.wespot.net/mod/profile/icondirect.php?lastcache=1364379192&joindate=1364379191&guid=62&size=medium";
    //                          name = "Stefaan Ternier";
    //                          oauthId = 116743449349920850150;
    //                          oauthProvider = Google;
    //                      }
    //                      );
    //        status = 0;
    //    }
    
    // Get our friends.
    self.usersFriends = [(NSDictionary *)[ARLNetwork getFriends:account.localId withProviderId:account.accountType] objectForKey:@"result"];
    
    // Get users of this inquiry.
    self.inquiryUsers = [(NSDictionary *)[ARLNetwork getInqueryUsers:account.localId withProviderId:account.accountType inquiryId:self.inquiryId] objectForKey:@"result"];
    
    // Remove outself from the inquiryUsers array.
    // We cannot beb friends with outselfs.
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.inquiryUsers];
    for (NSDictionary *d in self.inquiryUsers) {
        NSString *provider = [[NSString alloc] initWithFormat: @"%@", [ARLNetwork elggProviderByName:[d objectForKey:@"oauthProvider"]]];
        if ([[d objectForKey:@"oauthId"] isEqualToString:account.localId] &&
            [provider isEqualToString:[[NSString alloc] initWithFormat:@"%@", account.accountType]]) {
            
            [tmp removeObject:d];
            break;
        }
    }
    self.inquiryUsers = tmp;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numFriends;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case FRIENDS:
        {
            if (self.inquiryUsers) {
                return [self.inquiryUsers count];
            }
        }
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.section) {
        case FRIENDS:
        {
            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            NSString *userId = [(NSDictionary *)self.inquiryUsers[indexPath.item] objectForKey:@"oauthId"];
            NSString *type = [(NSDictionary *)self.inquiryUsers[indexPath.item] objectForKey:@"oauthProvider"];
            
            NSString *provider = [[NSString alloc] initWithFormat: @"%@", [ARLNetwork elggProviderByName:type]];
            
            Account *account = [Account retrieveFromDbWithLocalId:userId accountType:provider withManagedContext:appDelegate.managedObjectContext];
            
            cell.textLabel.text = [(NSDictionary *)self.inquiryUsers[indexPath.item] objectForKey:@"name"];
            if (account && account.picture) {
                cell.imageView.image = [UIImage imageWithData:account.picture];
            }
#warning get user image from url.
        }
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
