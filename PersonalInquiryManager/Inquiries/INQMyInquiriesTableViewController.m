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
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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

- (void)refreshTable {
    
  
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];

     [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
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
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    //    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:(@"Update...")];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [INQCloudSynchronizer syncInquiries:appDelegate.managedObjectContext];
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
            
            // NSLog(@"[%s] Cell '%@' created at index %@", __func__,inquiry.title, indexPath);
            
            cell.textLabel.text = inquiry.title;
            cell.imageView.image = [UIImage imageNamed:@"inquiry"];            
            cell.detailTextLabel.text = @""; //[NSString stringWithFormat:@"%d", arc4random() % 10];
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
    switch (indexPath.section) {
        case NEW: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case OPEN:{
            Inquiry *inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]);
            
            UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryParts"];
            
            if ([newViewController respondsToSelector:@selector(setInquiry:)]) {
                [newViewController performSelector:@selector(setInquiry:) withObject:inquiry];
            }
            
            [self.navigationController pushViewController:newViewController animated:YES];
        }
            break;
    }
}

-(NSIndexPath *)tableIndexPathToCoreDataIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-(int)self.sectionOffset];
}

-(NSIndexPath *)coreDataIndexPathToTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+(int)self.sectionOffset];
}

@end
