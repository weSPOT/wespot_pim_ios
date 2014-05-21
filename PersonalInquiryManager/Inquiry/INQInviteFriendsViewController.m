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
    /*!
     *  Number of Profle Fields
     */
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
    
    if (ARLNetwork.networkAvailable) {
        Account * account = [ARLNetwork CurrentAccount];
        
        // Get our friends.
        self.usersFriends = [(NSDictionary *)[ARLNetwork getFriends:account.localId withProviderId:account.accountType] objectForKey:@"result"];
        
        // Get users of this inquiry.
        self.inquiryUsers = [(NSDictionary *)[ARLNetwork getInquiryUsers:account.localId withProviderId:account.accountType inquiryId:self.inquiryId] objectForKey:@"result"];
        
        // Remove ourself from the inquiryUsers array.
        // We cannot be friends with ourselfs.
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.inquiryUsers];
        for (NSDictionary *dict in self.inquiryUsers) {
            NSString *provider = [[NSString alloc] initWithFormat: @"%@", [ARLNetwork elggProviderByName:[dict objectForKey:@"oauthProvider"]]];
            if ([[dict objectForKey:@"oauthId"] isEqualToString:account.localId] &&
                [provider isEqualToString:[[NSString alloc] initWithFormat:@"%@", account.accountType]]) {
                
                [tmp removeObject:dict];
                break;
            }
        }
        self.inquiryUsers = tmp;
    }
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
            if (self.usersFriends) {
                return [self.usersFriends count];
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
            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSString *userId = [(NSDictionary *)self.usersFriends[indexPath.item] objectForKey:@"oauthId"];
            NSString *type = [(NSDictionary *)self.usersFriends[indexPath.item] objectForKey:@"oauthProvider"];
            
            NSString *provider = [[NSString alloc] initWithFormat: @"%@", [ARLNetwork elggProviderByName:type]];
            
            Account *account = [Account retrieveFromDbWithLocalId:userId accountType:provider withManagedContext:appDelegate.managedObjectContext];
            
            cell.textLabel.text = [(NSDictionary *)self.usersFriends[indexPath.item] objectForKey:@"name"];
            cell.detailTextLabel.text = @"";
            
            if (account && account.picture) {
                cell.imageView.image = [UIImage imageWithData:account.picture];
            } else {
                if (ARLNetwork.networkAvailable) {
                    @autoreleasepool {
                        NSURL  *url = [NSURL URLWithString:[(NSDictionary *)self.usersFriends[indexPath.item] objectForKey:@"icon"]];
                        NSData *urlData = [NSData dataWithContentsOfURL:url];
                        if (urlData ){
                            cell.imageView.image = [UIImage imageWithData:urlData];
                        }
                    }
                }
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            for (NSDictionary *dict in self.inquiryUsers) {
                if ([[dict objectForKey:@"oauthId"] isEqualToString:userId] &&
                    [[dict objectForKey:@"oauthProvider"] isEqualToString:type]) {
                    
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    
                    break;
                }
            }

        }
            break;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        NSString *message = [[NSString alloc] initWithFormat:@"Invite %@ to join this Inquiry?", cell.textLabel.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:message delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        [alert show];
        
#warning Implement Invite to Join Inquiry.
    }
}

@end
