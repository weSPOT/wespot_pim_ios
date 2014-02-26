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

//@property (weak, nonatomic) IBOutlet UIView *inqueriesView;

@end

@implementation INQMyInquiriesTableViewController

-(NSString*) cellIdentifier {
    return  @"inquiriesCell";
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden:YES];
    
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view .backgroundColor = [UIColor clearColor];
    // self.inqueriesView.backgroundColor = [UIColor clearColor];
    
    [self setupFetchedResultsController];
}

- (void) viewDidAppear:(BOOL)animated {
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [INQCloudSynchronizer syncInquiries:appDelegate.managedObjectContext];
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
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [ARLCloudSynchronizer syncGamesAndRuns:appDelegate.managedObjectContext];
    
#warning Experimental code (does not seem to do what it should).
    //    ARLCloudSynchronizer *sync = [[ARLCloudSynchronizer alloc] init];
    //    sync.context=appDelegate.managedObjectContext;
    //    
    //    // Try Syncing Games.
    //    NSEntityDescription *entityDescription = [NSEntityDescription
    //                                              entityForName:@"Game" inManagedObjectContext:appDelegate.managedObjectContext];
    //    NSFetchRequest *request2 = [[NSFetchRequest alloc]init];
    //    [request2 setEntity:entityDescription];
    //    
    //    NSError *error;
    //    NSArray *games =[appDelegate.managedObjectContext executeFetchRequest: request2 error:&error];
    //    for (Game *game in games) {
    //        NSLog(@"%@", game.description);
    //        
    //        sync.gameId=game.gameId;
    //        [sync sync];
    //
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
            return @"";
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
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Inquiry *generalItem = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            cell.textLabel.text = generalItem.title;
            NSData* icon = [generalItem icon];
            if (icon) {
                UIImage * image = [UIImage imageWithData:icon];
                cell.imageView.image=image;
            }
            
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
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Inquiry * inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquireyParts"];
            
            if ([newViewController respondsToSelector:@selector(setInquiry:)]) {
                [newViewController performSelector:@selector(setInquiry:) withObject:inquiry];
            }
            
            [self.navigationController pushViewController:newViewController animated:YES];
        }
            break;
    }
}

@end
