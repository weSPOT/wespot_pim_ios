//
//  INQInquiryPageTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQInquiryTableViewController.h"

@interface INQInquiryTableViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, indices) {
    /*!
     *  Hypothesis & question.
     */
    HYPOTHESIS = 0,
    /*!
     *  Plan
     */
     PLAN,
    /*!
     *  Data collection tasks.
     */
    DATACOLLECTION,
    /*!
     *  Analysis.
     */
    ANALYSIS,
    /*!
     *  Discussion.
     */
    DISCUSS,
    /*!
     *  Communication.
     */
    COMMUNICATE,
    /*!
     *  Number of items in this NS_ENUM
     */
    numItems,
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQInquiryTableViewController

-(NSString*) cellIdentifier {
    return  @"inquiryPartCell";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load Icon.
    NSData* icon = [self.inquiry icon];
    if (icon) {
        UIImage * image = [UIImage imageWithData:icon];
        self.icon.image = image;
    }
    
    // Load description
    [self.inquiryDescription loadHTMLString:self.inquiry.desc baseURL:nil];
    // [self.inquiryDescription loadHTMLString:@"<html><body style='background-color:red;'>test</body></html>" baseURL:nil];
  
    
    NSLog(@"[%s] desc %@", __func__, self.inquiry.desc);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    // Disable some conflicting XCODE habits.
    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
    self.inquiryDescription.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Remove constraints.
    [self.view removeConstraints:[self.view constraints]];

    NSDictionary * viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
        self.view, @"view",
        self.icon, @"icon",
        self.inquiryDescription, @"description",
        nil];

    NSString *constraint;
    
    constraint = [NSString stringWithFormat:@"H:|-5-[icon(==%0.0f)]-[description]-5-|", self.icon.image.size.width];
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    constraint = [NSString stringWithFormat:@"V:|-5-[icon(==%0.0f)]-5-|", self.icon.image.size.height];
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    constraint = @"V:|-5-[description(==icon)]";
    NSLog(@"Constraint: %@", constraint);
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:constraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    // This one breaks above...
    //    constraint = [NSString stringWithFormat:@"V:[view(==%0.0f)]", self.icon.image.size.height+10];
    //    NSLog(@"Constraint: %@", constraint);
    //    [self.view addConstraints:[NSLayoutConstraint
    //                               constraintsWithVisualFormat:constraint
    //                               options:NSLayoutFormatDirectionLeadingToTrailing
    //                               metrics:nil
    //                               views:viewsDictionary]];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
    switch (section) {
        case 0 :
            return numItems;
        case 1 :
            return 1;
    }
    
    return 0;
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0 : {
            switch (indexPath.item) {
                case HYPOTHESIS:
                    cell.textLabel.text = @"Hypothesis";
                    break;
                case PLAN:
                    cell.textLabel.text = @"Plan";
                    break;
                case DATACOLLECTION:
                    cell.textLabel.text = @"Collect Data";
                    break;
                case ANALYSIS:
                    cell.textLabel.text = @"Analysis";
                    break;
                case DISCUSS:
                    cell.textLabel.text = @"Discuss";
                    break;
                case COMMUNICATE:
                    cell.textLabel.text = @"Commnicate";
                    break;
                default:
                    break;
            }
            }
            break;
            
        case 1:
            cell.textLabel.text = @"Invite friends";
            break;
    }

    return cell;
}

#pragma mark - Table view delegate

- (UIViewController *)CreateInquiryPartViewController:(NSNumber *)index
{
    UIViewController *newViewController;
    
    switch ([index intValue]){
        case HYPOTHESIS: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HypothesisView"];
            
            // Pass the parameters to render.
            [newViewController performSelector:@selector(setHypothesis:) withObject:self.inquiry.hypothesis];
        }
            break;
            
        case PLAN: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanView"];
        }
            break;
            
        case DATACOLLECTION: {
            
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectDataView"];
            
            // Pass the parameters to render.
            NSNumber * runId = [ARLNetwork getARLearnRunId:self.inquiry.inquiryId];
            Run* selectedRun =[Run retrieveRun:runId inManagedObjectContext:self.inquiry.managedObjectContext];
            NSNumber * gameId;
            
            // if (!selectedRun.runId) {
            //   NSLog(@"[%s] not good and load hypothesis view", __func__);
            //}
            
            if (selectedRun.runId) {
                [newViewController performSelector:@selector(setRun:) withObject:selectedRun];
                gameId = selectedRun.gameId;
            } else {
                gameId = [ARLNetwork getARLearnGameId:self.inquiry.inquiryId];
            }
            
            // Syncronize CoreData (RUNS & GAMES).
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
        }
            break;
            
        case ANALYSIS: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
        }
            break;
            
        case DISCUSS: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscussView"];
        }
            break;
            
        case COMMUNICATE: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommunicateView"];
        }
            break;
            
        default: {
            NSLog(@"[%s] Unknown InquiryPart: %@",__func__, index);
        }
            
            break;
    }
    
    return newViewController;
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * newViewController;
    
    switch (indexPath.section) {
        case 0: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
            if ([newViewController respondsToSelector:@selector(initWithInitialPage:)]) {
                [newViewController performSelector:@selector(initWithInitialPage:) withObject:[NSNumber numberWithInteger:indexPath.item]];
            }
            break;
            
        case 1: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        }
    }
    
    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

@end
