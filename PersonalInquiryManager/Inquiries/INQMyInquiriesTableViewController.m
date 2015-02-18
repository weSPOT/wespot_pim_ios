//
//  INQMyInquiriesViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQMyInquiriesTableViewController.h"

@interface INQMyInquiriesTableViewController ()

/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, inquiries) {
    /*!
     *  New Inquiry.
     */
    NEW = 0,
    /*!
     *  Open inquiries.
     */
    OPEN = 1,
    /*!
     *  Number of Inquires
     */
    numInquiries
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) NSInteger *sectionOffset;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQMyInquiriesTableViewController

-(NSString*) cellIdentifier {
    return  @"inquiriesCell";
}

-(NSInteger*) sectionOffset {
    return  1;
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inquiry"];
    
    [request setFetchBatchSize:8];

    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (ARLNetwork.networkAvailable) {
        [ARLCloudSynchronizer syncGamesAndRuns:appDelegate.managedObjectContext];
    }
}

- (void)refreshTable
{
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];

    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

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
    
//    NSInteger count = [self.fetchedResultsController.fetchedObjects count];
//    
//    NSError *error = nil;
//    [self.fetchedResultsController performFetch:&error];
//    
//    if (count != [self.fetchedResultsController.fetchedObjects count]) {
//        [self.tableView reloadData];
//    }
    
    NSSet *deletedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (NSManagedObject *obj in deletedObjects) {
        if ([[obj entity].name isEqualToString:@"Inquiry"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            // [self.tableView reloadData];
            return;
        }
    }
    
    // See if there are any Inquiry objects added and if so, reload the tableView.
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
    for (NSManagedObject *obj in insertedObjects) {
        if ([[obj entity].name isEqualToString:@"Inquiry"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [self.tableView reloadData];
            return;
        }
    }

    // If no Inquiry objecst are added, look for updates and refresh them.
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
                             
    BOOL fetched = NO;
    NSArray *indexPaths = [[NSArray alloc] init];
                             
    for (NSManagedObject *obj in updatedObjects) {
        if ([[obj entity].name isEqualToString:@"Inquiry"]) {
            if (!fetched) {
                NSError *error = nil;
                [self.fetchedResultsController performFetch:&error];
                fetched=YES;
            }
            
            Inquiry *updated = (Inquiry *)obj;
            
            //workaround for indexPathForObject:obj not working.
            for (Inquiry *inquiry in self.fetchedResultsController.fetchedObjects) {
                if ([inquiry.objectID isEqual:updated.objectID]) {
                    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:inquiry];
                    if (indexPath) {
                        indexPaths = [indexPaths arrayByAddingObject:[self coreDataIndexPathToTableIndexPath:indexPath]];
                    }
                    break;
                }
                
            }
        }
    }
    
    // This fails when a record is deleted....
    if (indexPaths.count != 0)
    {
        // [self.tableView reloadData];
        // [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*!
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES];
    
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view .backgroundColor = [UIColor clearColor];
    
    [self setupFetchedResultsController];
    
    // [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        [INQCloudSynchronizer syncInquiries:appDelegate.managedObjectContext];
        [ARLCloudSynchronizer syncResponses:appDelegate.managedObjectContext];
    }
    
    [self.navigationController setToolbarHidden:YES];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return numInquiries;
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
    NSInteger *count = 0;
    switch (section){
        case NEW:
            count = 1;
            break;
        case OPEN:
            count = [self.fetchedResultsController.fetchedObjects count];
            break;
    }
    
    // Error
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section){
        case NEW:
            return @"";
        case OPEN:
            return @"My Inquiries";
    }
    
    // Error
    return @"";
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
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:self.cellIdentifier];
    }
    // cell.backgroundColor = [UIColor clearColor];
    
    switch (indexPath.section) {
        case NEW: {
            cell.textLabel.text = @"New inquiry";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
        }
            break;
        case OPEN: {
            Inquiry *inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]);
            
            cell.textLabel.text = inquiry.title;
            if ([inquiry.icon length] == 0) {
                cell.imageView.image = [UIImage imageNamed:@"inquiry"];
            }else {
                cell.imageView.image = [UIImage imageWithData:inquiry.icon];
            }
            cell.detailTextLabel.text = @"";
        }
    }
    return cell;
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newViewController = nil;
    
    switch (indexPath.section) {
        case NEW: {
            if (ARLNetwork.networkAvailable) {
                newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NewInquiryController"];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Only available when on-line", @"Only available when on-line") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                [alert show];
            }
        }
            break;
        case OPEN:{
            Inquiry *inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]);
            
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryParts"];
            
            if ([newViewController respondsToSelector:@selector(setInquiry:)]) {
                [newViewController performSelector:@selector(setInquiry:) withObject:inquiry];
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

-(NSIndexPath *)tableIndexPathToCoreDataIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-(int)self.sectionOffset];
}

-(NSIndexPath *)coreDataIndexPathToTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+(int)self.sectionOffset];
}

@end
