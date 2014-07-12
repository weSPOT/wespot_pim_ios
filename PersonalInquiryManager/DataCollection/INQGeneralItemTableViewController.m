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
    if (self.run.runId) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentItemVisibility"];
        
        [request setFetchBatchSize:8];
        
        request.predicate = [NSPredicate predicateWithFormat:
                             @"visible = 1 and run.runId = %lld",
                             [self.run.runId longLongValue]];
        // As sortKey seems to be 0, we need to keep the order stable.
        NSSortDescriptor* sectionkey = [[NSSortDescriptor alloc] initWithKey:@"visible" ascending:YES];
        NSSortDescriptor* sortkey = [[NSSortDescriptor alloc] initWithKey:@"item.sortKey" ascending:YES];
        NSSortDescriptor* namekey = [[NSSortDescriptor alloc] initWithKey:@"item.name" ascending:YES];
        NSSortDescriptor* idkey = [[NSSortDescriptor alloc] initWithKey:@"item.generalItemId" ascending:YES];
        
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionkey, sortkey, namekey, idkey, nil];
        [request setSortDescriptors:sortDescriptors];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.run.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        self.fetchedResultsController.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
    }
}

/*!
 *  Getter
 *
 *  @param run The Run.
 */
- (void) setRun: (Run *) run {
    _run = run;
    
    [self setupFetchedResultsController];
}

/*!
 *  Notification, send when something changes in the NSManagedContext.
 *
 *  @param notification <#notification description#>
 */
- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return ;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    NSInteger count = [self.fetchedResultsController.fetchedObjects count];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (count != [self.fetchedResultsController.fetchedObjects count]) {
        [self.tableView reloadData];
        return;
    }
}

/*!
 *  Remove the Notification. Dealloc is the closest to ViewDidLoad.
 *
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*!
 *  See SDK.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
}

/*!
 *  See SDK.
 *
 *  Setup view, and load data.
 *
 *  @param animated <#animated description#>
 */
-(void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    self.navigationController.toolbar.backgroundColor = [UIColor whiteColor];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.title = @"Collect Data";
    self.navigationController.navigationBar.translucent= NO;

    [self.navigationController setToolbarHidden:NO];
    
    [self.tableView reloadData];
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
            
            CurrentItemVisibility *civ = ((CurrentItemVisibility *)[self.fetchedResultsController objectAtIndexPath:tmp]);
            
            GeneralItem *generalItem = civ.item;
            
            // Set Font to Bold if unread.
            cell.textLabel.text = generalItem.name;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            cell.detailTextLabel.text = [[generalItem.richText
                                          stringByReplacingOccurrencesOfString:@"<p>" withString:@""]
                                         stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
            
            // If Read set Font to normal.
            for (Action * action in generalItem.actions) {
                if (action.run == self.run) {
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
                [newViewController performSelector:@selector(setRun:) withObject:self.run];
            }
        }
            break;
            
        case DATA: {
            GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]).item;
            
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectedDataView"];
            
            if ([newViewController respondsToSelector:@selector(setGeneralItem:)]) {
                [newViewController performSelector:@selector(setGeneralItem:) withObject:generalItem];
            }
            if ([newViewController respondsToSelector:@selector(setRun:)]) {
                [newViewController performSelector:@selector(setRun:) withObject:self.run];
            }
            
            // Mark TableItem as Read.
            UITableViewCell *cell = (UITableViewCell*) [tableView cellForRowAtIndexPath:indexPath];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
            
            if (![Action checkAction:@"read"
                              forRun:self.run
                      forGeneralItem:generalItem
              inManagedObjectContext:generalItem.managedObjectContext]) {
                if (ARLNetwork.networkAvailable) {
                    [Action initAction:@"read" forRun:self.run forGeneralItem:generalItem inManagedObjectContext:generalItem.managedObjectContext];
                    
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
