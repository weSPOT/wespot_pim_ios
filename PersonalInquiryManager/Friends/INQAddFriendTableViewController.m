//
//  INQAddFriendTableViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/12/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQAddFriendTableViewController.h"

@interface INQAddFriendTableViewController ()

@property (strong, nonatomic) NSArray *usersFriends;

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQAddFriendTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    if (ARLNetwork.networkAvailable) {
        if (!self.AllUsers) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            [self getAllUsers];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
        // Get our friends.
        Account * account = [ARLNetwork CurrentAccount];
        
        self.usersFriends = [(NSDictionary *)[ARLNetwork getFriends:account.localId withProviderId:account.accountType] objectForKey:@"result"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)getAllUsers {
    NSDictionary *usersJson = [ARLNetwork getUsers];
    
    self.AllUsers = (NSArray *)[usersJson objectForKey:@"result"];
    
    Account * account = [ARLNetwork CurrentAccount];
    
    // Remove ourself from the AllUsers array.
    // We cannot be invited to be friends with ourselfs.
    NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.AllUsers];
    
    NSLog(@"[%s] %d users", __func__, [tmp count]);
    NSLog(@"[%s] removing ourselves", __func__);
    for (NSDictionary *dict in self.AllUsers) {
        NSString *provider = [[NSString alloc] initWithFormat: @"%@", [ARLNetwork elggProviderByName:[dict objectForKey:@"oauthProvider"]]];
        if ([[dict objectForKey:@"oauthId"] isEqualToString:account.localId] &&
            [provider isEqualToString:[[NSString alloc] initWithFormat:@"%@", account.accountType]]) {
            
            [tmp removeObject:dict];
            break;
        }
    }
    NSLog(@"[%s] %d users", __func__, [tmp count]);
    
    self.AllUsers = tmp;
}

-(NSString*) cellIdentifier {
    return  @"addfriendsCell";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (ARLNetwork.networkAvailable) {
        
        if (!self.AllUsers) {
            [self getAllUsers];
        }
        
        return [self.AllUsers count];
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Users";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }

    // Configure the cell...
    NSDictionary *user = (NSDictionary *)self.AllUsers[indexPath.item];
    
    cell.textLabel.text = [user objectForKey:@"name"];
    cell.detailTextLabel.text = @"";
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    for (NSDictionary *dict in self.usersFriends) {
        if ([[dict objectForKey:@"oauthId"] isEqualToString:[user objectForKey:@"oauthId"]] &&
            [[dict objectForKey:@"oauthProvider"] isEqualToString:[user objectForKey:@"oauthProvider"]]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            break;
        }
    }
    
    if (ARLNetwork.networkAvailable) {
        @autoreleasepool {
            NSURL *imageURL   = [NSURL URLWithString:[user objectForKey:@"icon"]];
            
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            if (imageData) {
                cell.imageView.image = [UIImage imageWithData:imageData];
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"Invite %@ to become a Friend?", @"Invite %@ to become a Friend?"), cell.textLabel.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"YES", @"YES") otherButtonTitles:NSLocalizedString(@"NO", @"NO"), nil];
        [alert show];
        
#warning Implement sending a Friend Request.
        
    } else {
        NSString *message = [[NSString alloc] initWithFormat:NSLocalizedString(@"%@ is already a Friend!", @"%@ is already a Friend!"), cell.textLabel.text];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:message delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    }
}

@end
