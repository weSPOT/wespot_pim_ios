//
//  INQProfileTableViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/25/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQProfileTableViewController.h"

@interface INQProfileTableViewController ()
/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, profile) {
    /*!
     *  Name.
     */
    NAME = 0,
    /*!
     *  E-Mail.
     */
    EMAIL,
    /*!
     *  Picture
     */
//    PICTURE,
//    /*!
//     *  Number of Profle Fields
//     */
    numProfile
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQProfileTableViewController

-(NSString*) cellIdentifier {
    return  @"profileCell";
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

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    [self.navigationController setToolbarHidden:YES];
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
    return numProfile;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    Account *account = [self fetchCurrentAccount];
    
    // Configure the cell...
    switch (indexPath.section) {
        case NAME:
            cell.textLabel.text = account.name;
            if (account.picture) {
                cell.imageView.image = [UIImage imageWithData:account.picture];
            }
            break;
            
        case EMAIL:
            cell.textLabel.text = account.email;
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case NAME:
            return @"Name";
        case EMAIL:
            return @"Email";
    }
    
    // Error
    return @"";
}


- (Account *) fetchCurrentAccount {
    UIResponder *appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate performSelector:@selector(fetchCurrentAccount) withObject:nil];
}


@end
