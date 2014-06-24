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
     *  Account Type.
     */
    // TYPE,
    /*!
     *  Longitude.
     */
    // LONGITUDE,
    /*!
     *  Latitude.
     */
    // LATITUDE,
    /*!
     *  Picture.
     */
    //  PICTURE,
    /*!
     *  Number of Profle Fields
     */
    numProfile
};

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

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
    
    //code below adds some custom stuff above the table
    
    // self.profileImage.clipsToBounds = YES;
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
    
    Account *account = ARLNetwork.CurrentAccount;
    
    if (account.picture) {
        self.profileImage.image = [UIImage imageWithData:account.picture];        
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case NAME:
            cell.textLabel.text = account.name;
            break;
            
        case EMAIL:
            cell.textLabel.text = account.email;
            break;
            
            //        case TYPE:
            //            cell.textLabel.text = [ARLNetwork elggProviderId:account.accountType];
            //            break;
            //
            //        case LONGITUDE:
            //            cell.textLabel.text = [NSString stringWithFormat:@"%+.6f", ARLAppDelegate.CurrentLocation.longitude];
            //            break;
            //
            //        case LATITUDE:
            //            cell.textLabel.text = [NSString stringWithFormat:@"%+.6f", ARLAppDelegate.CurrentLocation.latitude];
            //            break;

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
            //        case TYPE:
            //            return @"Type of account";
            //        case LONGITUDE:
            //            return @"Longitude";
            //        case LATITUDE:
            //            return @"Latitude";
    }
    
    // Error
    return @"";
}

/*!
 *  Set Color of Table Sections to White.
 *
 *  @param tableView <#tableView description#>
 *  @param view      <#view description#>
 *  @param section   <#section description#>
 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    // view.tintColor = [UIColor blackColor];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

@end
