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
    ADDTASK = 0,
    
    /*!
     *  Collected Data.
     */
    DATA = 1,

    /*!
     *  Number of Groups
     */
    numGroups
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) NSInteger *sectionOffset;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQGeneralItemTableViewController

/*!
 *  Getter.
 *
 *  @return The Cell Identifier.
 */
-(NSString*) cellIdentifier {
    return  @"generalitemCell";
}

/*!
 *  Getter.
 *
 *  @return The Section Offset.
 */
-(NSInteger*) sectionOffset {
    return  1;
}

/*!
 *  Setup the NSFetchedResultsController.
 */
- (void)setupFetchedResultsController {
    if (self.inquiry.run.runId) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentItemVisibility"];
//        
//        [request setFetchBatchSize:8];
//        
//        request.predicate = [NSPredicate predicateWithFormat:
//                             @"visible = 1 and run.runId = %lld",
//                             [self.inquiry.run.runId longLongValue]];
//        // As sortKey seems to be 0, we need to keep the order stable.
//        NSSortDescriptor* sectionkey = [[NSSortDescriptor alloc] initWithKey:@"visible" ascending:YES];
//        NSSortDescriptor* sortkey = [[NSSortDescriptor alloc] initWithKey:@"item.sortKey" ascending:YES];
//        NSSortDescriptor* namekey = [[NSSortDescriptor alloc] initWithKey:@"item.name" ascending:YES];
//        NSSortDescriptor* idkey = [[NSSortDescriptor alloc] initWithKey:@"item.generalItemId" ascending:YES];
//        
//        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionkey, sortkey, namekey, idkey, nil];
//        [request setSortDescriptors:sortDescriptors];
//        
//        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                            managedObjectContext:self.inquiry.run.managedObjectContext
//                                                                              sectionNameKeyPath:nil
//                                                                                       cacheName:nil];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"GeneralItem"];
        
        [request setFetchBatchSize:8];
        
        request.predicate = [NSPredicate predicateWithFormat:
                             @"gameId = %lld",
                             [self.inquiry.run.gameId longLongValue]];
        // As sortKey seems to be 0, we need to keep the order stable.
        //NSSortDescriptor* sectionkey = [[NSSortDescriptor alloc] initWithKey:@"visible" ascending:YES];
        NSSortDescriptor* sortkey = [[NSSortDescriptor alloc] initWithKey:@"sortKey" ascending:YES];
        NSSortDescriptor* namekey = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSSortDescriptor* idkey = [[NSSortDescriptor alloc] initWithKey:@"generalItemId" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortkey, namekey, idkey, nil];
        [request setSortDescriptors:sortDescriptors];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.inquiry.run.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }
}

/*!
 *  Getter
 *
 *  @param inquiry The Inquiry.
 */
- (void) setInquiry:(Inquiry *)inquiry  {
    _inquiry = inquiry;
}

- (void)syncProgress:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncProgress:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    DLog(@"syncProgress: %@", recordType);
    
    if ([NSStringFromClass([GeneralItem class]) isEqualToString:recordType]) {
        [self.tableView reloadData];
    }
}

- (void)syncReady:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncReady:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    DLog(@"syncReady: %@", recordType);
    
    if ([NSStringFromClass([GeneralItem class]) isEqualToString:recordType]) {
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        [self.tableView reloadData];
    }
}

/*!
 *  See SDK.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
}

/*!
 *  See SDK.
 *
 *  Setup view, and load data.
 *
 *  @param animated <#animated description#>
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    // self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.title = @"Collect Data";
    self.navigationController.navigationBar.translucent= NO;
    
    // viewDidLoad does not seem to get called at all
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncProgress:)
                                                 name:INQ_SYNCPROGRESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncReady:)
                                                 name:INQ_SYNCREADY
                                               object:nil];
    
    [self setupFetchedResultsController];
    
    [self.tableView reloadData];
    
    [self.navigationController setToolbarHidden:YES];
    
    if (ARLNetwork.networkAvailable && self.inquiry.run) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
  
        [ARLCloudSynchronizer syncVisibilityForInquiry:appDelegate.managedObjectContext
                                                   run:self.inquiry.run];
    }}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCPROGRESS object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCREADY object:nil];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    NSUInteger *count = 0;
    switch (section) {
        case ADDTASK: {
            count=1;
        }
            break;
        case DATA: {
            count = [self.fetchedResultsController.fetchedObjects count];
        }
            break;
    }
    
    return count;
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
    //Id was org.celstec.arlearn2.beans.generalItem.NarratorItem
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:self.cellIdentifier];
    }
    
    // Create the new ViewController.
    switch (indexPath.section) {
        case ADDTASK: {
            cell.textLabel.text = @"Add collection task";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
        }
            break;
            
        case DATA: {
            // Fetch Data from CoreData
            NSIndexPath *tmp = [self tableIndexPathToCoreDataIndexPath:indexPath];

#pragma warn GENERALITEM

            // CurrentItemVisibility *civ = ((CurrentItemVisibility *)[self.fetchedResultsController objectAtIndexPath:tmp]);
            
            GeneralItem *generalItem = ((GeneralItem *)[self.fetchedResultsController objectAtIndexPath:tmp]);;
            
            // Set Font to Bold if unread.
            cell.textLabel.text = generalItem.name;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.detailTextLabel.text = [INQUtils cleanHtml:generalItem.richText];
            
            // If Read set Font to normal.
            for (Action * action in generalItem.actions) {
                if (action.run == self.inquiry.run) {
                    if ([action.action isEqualToString:@"read"]) {
                        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
                    }
                }
            }
            
            NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
            
            if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"]    intValue] +
                [[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"]  intValue] +
                [[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]     intValue] +
                [[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]    intValue] +
                [[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]    intValue] == 1) {
                
                if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"]    intValue] == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"task-record"];
                } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"task-photo"];
                } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"task-text"];
                } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"task-explore"];
                } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
                    cell.imageView.image = [UIImage imageNamed:@"task-video"];
                }
                
            } else {
                cell.imageView.image = [UIImage imageNamed:@"task-explore"];
            }
            
            jsonDict = nil;
        }
            break;
    }
    
    return cell;
}
/*!
 *  Return the Title of a Section Header.
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section){
        case ADDTASK:
            return @"";
        case DATA:
            return @"Collection tasks";
    }
    
    // Error
    return @"";
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *newViewController;
    
    // Create the new ViewController.
    switch (indexPath.section) {
        case ADDTASK: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewGeneralItemView"];
            if ([newViewController respondsToSelector:@selector(setRun:)]) {
                [newViewController performSelector:@selector(setRun:) withObject:self.inquiry.run];
            }
        }
            break;
            
        case DATA: {
            GeneralItem *generalItem = (GeneralItem *)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]];

            //NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
            //Log(@"%@", jsonDict);
            
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
            
            if ([newViewController respondsToSelector:@selector(setGeneralItem:)]) {
                [newViewController performSelector:@selector(setGeneralItem:) withObject:generalItem];
            }
            
            if ([newViewController respondsToSelector:@selector(setInquiry:)]) {
                [newViewController performSelector:@selector(setInquiry:) withObject:self.inquiry];
            }
            
            // Mark TableItem as Read.
            UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            
            if (![Action checkAction:@"read"
                              forRun:self.inquiry.run
                      forGeneralItem:generalItem
              inManagedObjectContext:generalItem.managedObjectContext]) {
                if (ARLNetwork.networkAvailable) {
                    [Action initAction:@"read"
                                forRun:self.inquiry.run
                        forGeneralItem:generalItem
                inManagedObjectContext:generalItem.managedObjectContext];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                        [ARLCloudSynchronizer syncActions:generalItem.managedObjectContext];
                    });
                }
            }
        }
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

/*!
 *  Adjust the IndexPath passed into the table methods with the SectionOffset.
 *
 *  @param indexPath <#indexPath description#>
 *
 *  @return <#return value description#>
 */
-(NSIndexPath *)tableIndexPathToCoreDataIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-(int)self.sectionOffset];
}

/*!
 *  Adjust the CoreData IndexPath to the table methods with the SectionOffset.
 *
 *  @param indexPath <#indexPath description#>
 *
 *  @return <#return value description#>
 */
-(NSIndexPath *)coreDataIndexPathToTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+(int)self.sectionOffset];
}

@end
