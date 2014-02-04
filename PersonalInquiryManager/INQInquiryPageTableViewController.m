//
//  INQInquiryPageTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQInquiryPageTableViewController.h"

@interface INQInquiryPageTableViewController ()

/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, indices) {
    /*!
     *  Messages.
     */
    MESSAGE = 0,
    /*!
     *  Hypothesis & question.
     */
    HYPOTHESIS = 1,
    /*!
     *  Planning
     */
    PLANNING = 2,
    /*!
     *  Data collection tasks.
     */
    DATACOLLECION = 3,
    /*!
     *  Analysis.
     */
    ANALYSIS = 4,
    /*!
     *  Operationalisation / notes.
     */
    NOTES = 5
};

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
    
    // Load Icon.
    NSData* icon = [inquiry icon];
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

    NSDictionary * viewsDictionary =
    [[NSDictionary alloc] initWithObjectsAndKeys:
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

/*!
 *  Creates Cells for the UITableView.
 *
 *  @param tableView The UITableView
 *  @param indexPath The index path containing the grouping/section and record index.
 *
 *  @return The INQInquiryPartCell.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inquiryPartCell";

    INQInquiryPartCell *cell = (INQInquiryPartCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    switch ([indexPath section]) {
        case MESSAGE:
            cell.inquiryPartLabel.text = @"Messages";
            break;
        case HYPOTHESIS:
            cell.inquiryPartLabel.text = @"Hypothesis & question";
            break;
        case PLANNING:
            cell.inquiryPartLabel.text = @"Planning";
            break;
        case DATACOLLECION:
            cell.inquiryPartLabel.text = @"Data collection tasks";
            break;
        case ANALYSIS:
            cell.inquiryPartLabel.text = @"Analysis";
            break;
            // ...
        case NOTES:
            cell.inquiryPartLabel.text = @"Notes";
            break;
        default:
            break;
    }

    // Configure the cell...

    return cell;
}

#pragma mark - Table view delegate

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController * newViewController;
    
    switch ([indexPath section]){
        case MESSAGE: {
             // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MessagesView"];
            
            // Pass the parameters to render.
            // [newViewController performSelector:@selector(setHypothesis:) withObject:self.inquiry.hypothesis];
            }
        break;
        
        case HYPOTHESIS: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HypothesisView"];
            
            // Pass the parameters to render.
            [newViewController performSelector:@selector(setHypothesis:) withObject:self.inquiry.hypothesis];
            }
        break;
            
        case NOTES: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NotesView"];

            // Pass the parameters to render.
            [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiry.inquiryId];
            }
            break;
            
        case DATACOLLECION: {
            
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dataCollectionTasks"];
            
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
          
        case PLANNING: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        break;
            
        default: {
            NSLog(@"[%s] Unknown InquiryPart: %@",__func__, [NSNumber numberWithInteger:indexPath.section]);
        }
            
        break;
    }
    
    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

@end
