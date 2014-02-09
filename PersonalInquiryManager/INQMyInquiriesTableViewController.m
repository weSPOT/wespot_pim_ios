//
//  INQMyInquiriesViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQMyInquiriesTableViewController.h"

@interface INQMyInquiriesTableViewController ()

@end

@implementation INQMyInquiriesTableViewController

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    return self;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Inquiry * generalItem = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
    INQMyInquiriesTableViewItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inquiriesCell"];
    if (cell == nil) {
        cell = [[INQMyInquiriesTableViewItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"inquiriesCell"];
    }
    cell.title.text = generalItem.title;
    NSData* icon = [generalItem icon];
    if (icon) {
        UIImage * image = [UIImage imageWithData:icon];
        cell.icon.image = image;
    }

    
    return cell;
}

-(void) configureCell: (INQMyInquiriesTableViewItemCell *) cell atIndexPath:(NSIndexPath *)indexPath {
    Inquiry * generalItem = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:indexPath]);
    
    cell.title.text = generalItem.title;
    NSData* icon = [generalItem icon];
    if (icon) {
        UIImage * image = [UIImage imageWithData:icon];
        cell.icon.image = image;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Inquiry * inquiry = ((Inquiry*)[self.fetchedResultsController objectAtIndexPath:indexPath]);

    if ([segue.destinationViewController respondsToSelector:@selector(setInquiry:)]) {
        [segue.destinationViewController performSelector:@selector(setInquiry:) withObject:inquiry];
    }
}

@end
