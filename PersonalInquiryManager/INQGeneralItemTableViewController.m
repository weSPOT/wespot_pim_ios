//
//  INQGeneralItemTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQGeneralItemTableViewController.h"

@interface INQGeneralItemTableViewController ()

@end

@implementation INQGeneralItemTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.title = @"Collect Data";
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
    NSLog(@"[%s] %d", __func__, [self.fetchedResultsController.fetchedObjects count]);
    
    return [self.fetchedResultsController.fetchedObjects count];
}

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    // Fetch Data from CoreData
    GeneralItem *generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;

    // Dequeue a TableCell and intialize if nececsary.
    // Id = org.celstec.arlearn2.beans.generalItem.NarratorItem
    ARLGeneralItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:generalItem.type];
    if (cell == nil) {
        cell = [[ARLGeneralItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:generalItem.type];
    }
    // cell.backgroundColor= [UIColor clearColor];
    
    // Set Font to Bold if unread.
    cell.giTitleLabel.text = generalItem.name;
    cell.giTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    [self setDCIcon:cell withGi:generalItem];

    // If Read set Font to normal.
    for (Action * action in generalItem.actions) {
        if (action.run == self.run) {
            if ([action.action isEqualToString:@"read"]) {
                cell.giTitleLabel.font = [UIFont systemFontOfSize:16.0f];
            }
        }
    }
    
    return cell;
}

/*!
 *  Set the Correct Icon for the Action retrieved.
 *
 *  @param cell      The TableCell to customize.
 *  @param generalItem The GeneralItem cell content.
 */
- (void) setDCIcon: (ARLGeneralItemTableViewCell *) cell withGi: (GeneralItem *) generalItem {
        NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
    
    NSLog(@"[%s] log %@", __func__, [jsonDict objectForKey:@"openQuestion"]);
    
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"] intValue] == 1) {
            cell.icon.image = [UIImage imageNamed:@"dc_voice_search_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_camera_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_note_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_calculator_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_video_128.png"];
    }
}

@end
