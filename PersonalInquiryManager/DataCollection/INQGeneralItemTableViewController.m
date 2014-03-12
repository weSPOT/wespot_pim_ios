//
//  INQGeneralItemTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQGeneralItemTableViewController.h"

@interface INQGeneralItemTableViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, groups) {
    /*!
     *  Collected Data.
     */
    DATA = 0,

    /*!
     *  Number of Groups
     */
    numGroups
};

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;

@end

@implementation INQGeneralItemTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
//    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
//    
//    self.tableView.opaque = NO;
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
//    self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
//    
//    //self.navigationController.view.backgroundColor = [UIColor clearColor];
//    self.navigationController.title = @"Collect Data";
//    self.navigationController.navigationBar.translucent= NO;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
}

-(void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.title = @"Collect Data";
    self.navigationController.navigationBar.translucent= NO;

    [self.navigationController setToolbarHidden:NO];
}

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
    NSLog(@"[%s] %d", __func__, [self.fetchedResultsController.fetchedObjects count]);
    
    return [self.fetchedResultsController.fetchedObjects count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:generalItem.type];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:generalItem.type];
    }
    
    // Set Font to Bold if unread.
    cell.textLabel.text = generalItem.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];

    // If Read set Font to normal.
    for (Action * action in generalItem.actions) {
        if (action.run == self.run) {
            if ([action.action isEqualToString:@"read"]) {
                cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            }
        }
    }
    
    NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
    
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"] intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"task-record.png"];
    } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"task-photo.png"];
    } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"task-text.png"];
    } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"task-explore.png"];
    } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"task-video.png"];
    }
    
    jsonDict = nil;
    
    return cell;
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Mark TableItem as Read.
    UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    
    // Jump to Destination (skip prepareforSeque in base class).
    UIViewController *newViewController;
    
    // Create the new ViewController.
    switch (indexPath.section) {
        case DATA: {
            GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;
            
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
            
            if ([newViewController respondsToSelector:@selector(setGeneralItem:)]) {
                [newViewController performSelector:@selector(setGeneralItem:) withObject:generalItem];
            }
            if ([newViewController respondsToSelector:@selector(setRun:)]) {
                [newViewController performSelector:@selector(setRun:) withObject:self.run];
            }
            [Action initAction:@"read" forRun:self.run forGeneralItem:generalItem inManagedObjectContext:generalItem.managedObjectContext];
            [ARLCloudSynchronizer syncActions:generalItem.managedObjectContext];
            
        }
            break;
    }

    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

@end
