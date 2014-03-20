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

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) NSInteger *sectionOffset;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQGeneralItemTableViewController

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

-(NSString*) cellIdentifier {
    return  @"generalitemCell";
}

-(NSInteger*) sectionOffset {
    return  0;
}

- (void)setupFetchedResultsController {
    if (self.run.runId) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CurrentItemVisibility"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                         ascending:YES
                                                                                          selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:
                             @"visible = 1 and run.runId = %lld",
                             [self.run.runId longLongValue]];
        
#warning Which SortDescriptor is used?
        
        NSSortDescriptor* sortkey = [[NSSortDescriptor alloc] initWithKey:@"item.sortKey" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortkey, nil];
        [request setSortDescriptors:sortDescriptors];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.run.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        
        self.fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];

        if (ARLNetwork.networkAvailable) {
 //           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
           dispatch_async(dispatch_get_main_queue(), ^{
                ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
                ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [synchronizer createContext:appDelegate.managedObjectContext];
                
                synchronizer.gameId = self.run.gameId;
                synchronizer.visibilityRunId = self.run.runId;
                
                [synchronizer sync];
            });
        }
    }
}

- (void) setRun: (Run *) run {
    _run = run;
    
    // self.title = run.title;
    
    [self setupFetchedResultsController];
}

- (void)refreshTable {
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl.tintColor = [UIColor orangeColor];
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];

    //    if (ARLNetwork.networkAvailable) {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    //            ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    //            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //            [synchronizer createContext:appDelegate.managedObjectContext];
    //            synchronizer.gameId = self.run.gameId;
    //            synchronizer.visibilityRunId = self.run.runId;
    //            [synchronizer sync];
    //        });
    //    }

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
    NSUInteger *count =[self.fetchedResultsController.fetchedObjects count];

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
    // Create the new ViewController.
    switch (indexPath.section) {
        case DATA: {
            // Fetch Data from CoreData
            GeneralItem *generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]).item;
            
            NSLog(@"[%s] Cell '%@' created at index %@", __func__, generalItem.name, indexPath);
            
            // Dequeue a TableCell and intialize if nececsary.
            // Id = org.celstec.arlearn2.beans.generalItem.NarratorItem
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
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
            
            jsonDict = nil;
            return cell;
        }
            break;
    }
    
    return nil;
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
            GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]).item;
            
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

//-(void) configureCell: (id) cell atIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case DATA: {
//            GeneralItem *generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]).item;
//
//            NSLog(@"[%s] Cell '%@' changed to '%@' at index %@", __func__, ((UITableViewCell *)cell).textLabel.text, generalItem.name, indexPath);
//
//            
////            ((UITableViewCell *)cell).textLabel.text=generalItem.name;
////            
////            NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
////            
////            if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"] intValue] == 1) {
////                ((UITableViewCell *)cell).imageView.image = [UIImage imageNamed:@"task-record"];
////            } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
////                ((UITableViewCell *)cell).imageView.image = [UIImage imageNamed:@"task-photo"];
////            } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
////                ((UITableViewCell *)cell).imageView.image = [UIImage imageNamed:@"task-text"];
////            } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
////                ((UITableViewCell *)cell).imageView.image = [UIImage imageNamed:@"task-explore"];
////            } else if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
////                ((UITableViewCell *)cell).imageView.image = [UIImage imageNamed:@"task-video"];
////            }
////            
////            jsonDict = nil;
//        }
//            break;
//    }
//    
////    if (!cell) {
////        cell = [self.tableView cellForRowAtIndexPath:indexPath];
////    }
////    NSError * error = nil;
////    [self.fetchedResultsController performFetch:&error];
////
////    [self .tableView reloadData];
//}

-(NSIndexPath *)tableIndexPathToCoreDataIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-(int)self.sectionOffset];
}

-(NSIndexPath *)coreDataIndexPathToTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+(int)self.sectionOffset];
}

///*!
// *  Notifies the UITableView a model update has ended.
// *
// *  @param controller <#controller description#>
// */
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    NSLog(@"[%s]", __func__);
//    [self.tableView reloadData];
//}

@end
