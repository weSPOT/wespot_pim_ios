//
//  INQAddFriendTableViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/12/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQAddFriendTableViewController.h"

@interface INQAddFriendTableViewController ()

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQAddFriendTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
#warning Todo (or mark grey) Outselves and Friends.
    if (!self.AllUsers) {
        [self getAllUsers];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)getAllUsers {
    NSDictionary *usersJson = [ARLNetwork getUsers];
    
    self.AllUsers = (NSArray *)[usersJson objectForKey:@"result"];
}

-(NSString*) cellIdentifier {
    return  @"userCell";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.AllUsers) {
        [self getAllUsers];
    }
    
    return self.AllUsers.count;
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
    
    cell.textLabel.text = [(NSDictionary *)self.AllUsers[indexPath.item] objectForKey:@"name"];
    
    @autoreleasepool {
        NSURL *imageURL   = [NSURL URLWithString:[self.AllUsers[indexPath.item] objectForKey:@"icon"]];
        
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        if (imageData) {
            cell.imageView.image = [UIImage imageWithData:imageData];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
}

@end
