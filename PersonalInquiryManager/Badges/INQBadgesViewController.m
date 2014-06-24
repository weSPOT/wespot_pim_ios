//
//  INQBadgesViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/7/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQBadgesViewController.h"

@interface INQBadgesViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, groups) {
    /*!
     *  Earned Badges.
     */
    EARNED = 0,
    
    /*!
     *  Unearned Badges.
     */
    UNEARNED,
    
    /*!
     *  Number of Groups
     */
    numGroups
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQBadgesViewController

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString*) cellIdentifier {
    return  @"badgesCell";
}

/*!
 *  Load Content.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationController setToolbarHidden:YES];
    
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
    // Dispose of any resources that can be recreated.
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
    // Return the number of sections.
    return numGroups;
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
    // Return the number of rows in the section.
    switch (section) {
        case EARNED:
            return 2;
        case UNEARNED:
            return 5;
    }
    return 0;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    switch (indexPath.section) {
        case EARNED: {
            cell.textLabel.Text = @"Badge";
            cell.imageView.image = [UIImage imageNamed:@"badges"];
        }
            break;
        case UNEARNED: {
            cell.textLabel.Text = @"Unearned Badge";
            cell.imageView.image = [UIImage imageNamed:@"badges"];
            cell.backgroundColor = [UIColor grayColor];

            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
    }
    
    return cell;
}

/*!
 *  Return the Title for a Section Header.
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case EARNED:
            return NSLocalizedString(@"Earned", @"Earned");
        case UNEARNED:
            return NSLocalizedString(@"Unearned", @"Unearned");
    }
    
    return @"";
}

#pragma mark - Table view delegate

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newViewController;
    
    // Create the new ViewController.
    switch (indexPath.section) {
        case EARNED:
            switch (indexPath.item) {
                default:
                    // newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyInquiriesView"];
                    break;
            }
            break;
            
        case UNEARNED:
            break;
    }

    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
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
