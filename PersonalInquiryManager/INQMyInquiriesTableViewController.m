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
};

- (IBAction)newInquiryTap:(UIButton *)sender;

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQMyInquiriesTableViewController

-(NSString*) cellIdentifier {
    return  @"inquiriesCell1";
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
 *  Return the number of Rows in a Section.
 *
 *  @param tableView The Table to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    Inquiry *generalItem = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
    cell.textLabel.text = generalItem.title;
    NSData* icon = [generalItem icon];
    if (icon) {
        UIImage * image = [UIImage imageWithData:icon];
        cell.imageView.image=image;
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
    Inquiry * inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquireyParts"];
    
    if ([newViewController respondsToSelector:@selector(setInquiry:)]) {
        [newViewController performSelector:@selector(setInquiry:) withObject:inquiry];
    }
    
    [self.navigationController pushViewController:newViewController animated:YES];
}

- (IBAction)newInquiryTap:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
