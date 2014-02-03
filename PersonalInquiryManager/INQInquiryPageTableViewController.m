//
//  INQInquiryPageTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQInquiryPageTableViewController.h"

@interface INQInquiryPageTableViewController ()

@end

@implementation INQInquiryPageTableViewController

@synthesize inquiry;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSData* icon = [inquiry icon];
    if (icon) {
        UIImage * image = [UIImage imageWithData:icon];
        self.icon.image = image;
    }

     [self.inquiryDescription loadHTMLString:self.inquiry.desc baseURL:nil];
    NSLog(@"[%s] desc %@", __func__, self.inquiry.desc);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inquiryPartCell";
    
    INQInquieyPartCell *cell = (INQInquieyPartCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    switch ([indexPath section]){
        case 0:
                cell.inquiryPartLabel.text = @"Hypothesis";
            break;
        case 1:
            cell.inquiryPartLabel.text = @"Notes";
            break;
        case 2:
            cell.inquiryPartLabel.text = @"Data Collection";
            break;
            // ...
        default:
            break;
    }

    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Question/Hypothesis", @"Question/Hypothesis");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Operationalisation", @"Operationalisation");
            break;
        case 2:
            sectionName = NSLocalizedString(@"Data Collection", @"Data Collection");
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * newViewController;
    switch ([indexPath section]){
        case 0:
            NSLog(@"[%s] create and load hypothesis view", __func__);
            newViewController = [[INQHypothesisViewController alloc] init];
            [newViewController performSelector:@selector(setHypothesis:) withObject:self.inquiry.hypothesis];
            break;
        case 1:
            newViewController = [[INQNotesViewController alloc] init];
            [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiry.inquiryId];

            break;
        case 2: {
            
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dataCollectionTasks"];
            NSNumber * runId = [ARLNetwork getARLearnRunId:self.inquiry.inquiryId];
            Run* selectedRun =[Run retrieveRun:runId inManagedObjectContext:self.inquiry.managedObjectContext];
            NSNumber * gameId;
//            if (!selectedRun.runId) {
//                NSLog(@"[%s] not good and load hypothesis view", __func__);
//                gameId = [ARLNetwork getARLearnGameId:self.inquiry.inquiryId];
//
//            }
            if (selectedRun.runId) {
                [newViewController performSelector:@selector(setRun:) withObject:selectedRun];
                gameId = selectedRun.gameId;
            } else {
                gameId = [ARLNetwork getARLearnGameId:self.inquiry.inquiryId];
            }
            ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [synchronizer createContext:appDelegate.managedObjectContext];
            if (!selectedRun) {
                synchronizer.syncRuns = YES;
            }
            synchronizer.gameId = gameId;
            synchronizer.visibilityRunId = runId;
            synchronizer.syncGames = YES;
            [synchronizer sync];
            break;
        }
            
        default:
            break;
    }
    if (newViewController)             [self.navigationController pushViewController:newViewController animated:YES];

    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
