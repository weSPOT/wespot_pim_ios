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

@end

@implementation INQMyInquiriesTableViewController

-(NSString*) cellIdentifier {
    return  @"inquiriesCell";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setToolbarHidden:YES];
    
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view .backgroundColor = [UIColor clearColor];
    
    [self setupFetchedResultsController];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [INQCloudSynchronizer syncInquiries:appDelegate.managedObjectContext];
    }
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Inquiry"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.sectionOffset = 1;
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                               cacheName:nil];

    
    [self.fetchedResultsController fetchRequest];
    
    if (ARLNetwork.networkAvailable) {
        [ARLCloudSynchronizer syncGamesAndRuns:appDelegate.managedObjectContext];
    }
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
    switch (section){
        case NEW:
            return 1;
        case OPEN:
            return [self.fetchedResultsController.fetchedObjects count];
    }
    
    // Error
    return 0;
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
            cell.detailTextLabel.text = @"5";
            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
        }
            break;
        case OPEN: {
            Inquiry *inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]);
            
            cell.textLabel.text = inquiry.title;
            cell.imageView.image = [UIImage imageNamed:@"inquiry"];            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", arc4random() % 10];
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

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [super controllerDidChangeContent:controller];
//    
//    // [self.fetchedResultsController fetchRequest];
//    
////    [self.tableView reloadData];
//}

-(void) configureCell: (id) cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case OPEN: {
            Inquiry *inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:[self tableIndexPathToCoreDataIndexPath:indexPath]]);
            
            NSLog(@"[%s] Cell '%@' changed to '%@' at index %@", __func__, ((UITableViewCell *)cell).textLabel.text, inquiry.title, indexPath);
        }
            break;
    }
    
//            NSLog(@"[%s] Cell changed '%@' at %@", __func__, ((UITableViewCell *)cell).textLabel.text, indexPath);
    //    NSLog(@"[%s] Cell changed %@ at %@ %@", __func__, cell, indexPath, ((UITableViewCell *)cell).textLabel.text);
    //
    ////    NSError * error = nil;
    ////    [self.fetchedResultsController performFetch:&error];
    ////    NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    ////    cell = [self.tableView cellForRowAtIndexPath:ip];
    ////    [self.tableView reloadData];
}

@end
