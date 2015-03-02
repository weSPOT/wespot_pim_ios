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
     *  Description.
     */
    DESCRIPTION = 0,
    /*!
     *  Hypothesis.
     */
    HYPOTHESIS = 1,
    /*!
     *  Question.
     */
    QUESTION = 2,
    /*!
     *  Plan
     */
    PLAN = 101,
    /*!
     *  Data collection tasks.
     */
    DATACOLLECTION = 3,
    /*!
     *  Analysis.
     */
    ANALYSIS = 102,
    /*!
     *  Discussion.
     */
    DISCUSS = 4,
    /*!
     *  Communication.
     */
    COMMUNICATE = 103,
    /*!
     *  Number of items in this NS_ENUM.
     */
    numItems = 5,
};

/*!
 *  TableView Sections.
 */
typedef NS_ENUM(NSInteger, sections) {
    /*!
     *  Icon
     */
    ICON =0,
    /*!
     *  Inquiry Parts
     */
    PARTS =1,
    /*!
     *  Invite Friends.
     */
//    INVITE,
    
    /*!
     *  NUmber of Sections.
     */
    numSections
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) NSString *iconIdentifier;

// @property (readonly, nonatomic) NSInteger *headerCellHeight;

@end

@implementation INQInquiryTableViewController


+(NSInteger) numParts {
    return numItems;
}

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"inquiryPartCell";
}

/*!
 *  Getter
 *
 *  @return The Cell Identifier.
 */
-(NSString *) iconIdentifier {
    return  @"inquiryIconCell";
}


/*!
 *  Getter
 *
 *  @return The Header Cell Height.
 */
-(NSInteger *) headerCellHeight {
    return 210;
}

//- (void)refreshTable {
//    [self.tableView reloadData];
//    
//    [self.refreshControl endRefreshing];
//}

- (void)syncProgress:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncProgress:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    Log(@"syncProgress: %@", recordType);
    
    if ([NSStringFromClass([GeneralItemVisibility class]) isEqualToString:recordType]) {
        // Force Counter on DataCollection TableRow to update.
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:DATACOLLECTION inSection:PARTS], nil];
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)syncReady:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncReady:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    Log(@"syncReady: %@", recordType);
    
    if ([NSStringFromClass([GeneralItemVisibility class]) isEqualToString:recordType]) {
        // Force Counter on DataCollection TableRow to update.
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:
                               [NSIndexPath indexPathForRow:DATACOLLECTION
                                                  inSection:PARTS], nil];
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if ([NSStringFromClass([Message class]) isEqualToString:recordType]) {
        // Force Counter on DataCollection TableRow to update.
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:
                               [NSIndexPath indexPathForRow:DISCUSS
                                                  inSection:PARTS], nil];
        
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)syncAPN:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncAPN:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext
                                 inquiryId:self.inquiry.inquiryId];
    }
}

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

/*!
 *  viewWillAppear
 *
 *  @param animated <#animated description#>
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncProgress:)
                                                 name:INQ_SYNCPROGRESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncReady:)
                                                 name:INQ_SYNCREADY
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncAPN:)
                                                 name:INQ_GOTAPN
                                               object:nil];
    
    if (ARLNetwork.networkAvailable && self.inquiry.run) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [INQCloudSynchronizer syncInquiry:appDelegate.managedObjectContext
                                inquiryId:self.inquiry.inquiryId];
        
        [ARLCloudSynchronizer syncVisibilityForInquiry:appDelegate.managedObjectContext
                                                   run:self.inquiry.run];

        [INQCloudSynchronizer syncInquiryUsers:appDelegate.managedObjectContext
                                     inquiryId:self.inquiry.inquiryId];
    }
}

/*!
 *  viewDidAppear
 *
 *  @param animated <#animated description#>
 */
- (void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCPROGRESS object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCREADY object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_GOTAPN object:nil];
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
    return numSections;
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
        case ICON :
            return 1;
        case PARTS :
            return numItems;
//      case INVITE :
//          return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section){
        case ICON:
            return @"";
        case PARTS:
            return @"Inquiry parts";
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
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case ICON:
            cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:self.iconIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        case PARTS:
            cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
//      case INVITE:
//          cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier2];
//          break;
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case ICON:
            cell.textLabel.text = @"";
            if ([self.inquiry.icon length] == 0) {
                cell.imageView.image = [UIImage imageNamed:@"inquiry"];
            } else {
                cell.imageView.image = [UIImage imageWithData:self.inquiry.icon];
            }
            break;

        case PARTS : {
            switch (indexPath.item) {
                case DESCRIPTION:
                    cell.textLabel.text = @"Description";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"description"];
                    break;
                    
                case HYPOTHESIS:
                    cell.textLabel.text = @"Hypothesis";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"hypothesis"];
                    break;
                    
                case QUESTION:
                    cell.textLabel.text = @"Questions";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"hypothesis"];
                    break;
                    
                case PLAN:
                    cell.textLabel.text = @"Plan";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"plan"];
                    break;
                    
                case DATACOLLECTION: {
                    cell.textLabel.text = @"Collect Data";
                    
                    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                    NSInteger count = [appDelegate entityCount:@"CurrentItemVisibility"
                                                     predicate:[NSPredicate predicateWithFormat:@"visible = 1 and run.runId = %lld", [self.inquiry.run.runId longLongValue]]];
                    
                    if (count!=0) {
                        NSString *value = [NSString stringWithFormat:@"%d", count];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
                        NSRange range=[value rangeOfString:value];
                        
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                        
                        [cell.detailTextLabel setAttributedText:string];
                    } else {
                        cell.detailTextLabel.text = @"";
                    }
                    
                    cell.imageView.image = [UIImage imageNamed:@"collect-data"];
                }
                    break;
                    
                case ANALYSIS:
                    cell.textLabel.text = @"Analyze";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"analyze"];
                    break;
                    
                case DISCUSS: {
                    cell.textLabel.text = @"Chat";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"communicate"];
                    
                    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                    NSInteger count = [appDelegate entityCount:@"Message"
                                                     predicate:[NSPredicate predicateWithFormat:@"run.runId = %lld", [self.inquiry.run.runId longLongValue]]];
                    if (count!=0) {
                        NSString *value = [NSString stringWithFormat:@"%d", count];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:value];
                        NSRange range=[value rangeOfString:value];
                        
                        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
                        
                        [cell.detailTextLabel setAttributedText:string];
                    } else {
                        cell.detailTextLabel.text = @"";
                    }
                }
                    break;
                    
                case COMMUNICATE:
                    cell.textLabel.text = @"Communicate";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"communicate"];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
//        case INVITE:
//            cell.textLabel.text = @"Invite friends";
//            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
//            cell.detailTextLabel.text = @"";
//            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
    
    switch (indexPath.section) {
        case ICON:
            return 2 * rh;
        case PARTS:
            return rh;
            //        case INVITE:
            //            return rh;
    }
    
    // Error
    return rh;
}

#pragma mark - Table view delegate

- (UIViewController *)CreateInquiryPartViewController:(NSNumber *)index
{
    UIViewController *newViewController;
    
    switch ([index intValue]){
         case DESCRIPTION: {
             // Create the new ViewController.
             newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DescriptionView"];
             
             // Pass the parameters to render.
             [newViewController performSelector:@selector(setDescription:)
                                     withObject:self.inquiry.desc];
         }
            break;
            
        case HYPOTHESIS: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HypothesisView"];
            
            // Pass the parameters to render.
            [newViewController performSelector:@selector(setHypothesis:)
                                    withObject:self.inquiry.hypothesis];
        }
            break;
            
        case QUESTION: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionView"];
            
            NSDictionary *json1 = [ARLNetwork getQuestions:self.inquiry.inquiryId];
            NSArray *questions = [json1 valueForKey:@"result"];
            //            {
            //                result =     (
            //                              {
            //                                  description = "Do the spanish people know?";
            //                                  question = "Are there different kinds of Siesta?";
            //                                  questionId = 80911;
            //                                  tags =             (
            //                                                      types,
            //                                                      siesta,
            //                                                      spanish,
            //                                                      lazy
            //                                                      );
//                                  url = "http://inquiry.wespot.net/answers/view/80911/are-there-different-kinds-of-siesta";
//                              },
//                              );
//                status = 0;
//            }
            
            // Pass the parameters to render.
            [newViewController performSelector:@selector(setQuestions:) withObject:questions];
        
            NSDictionary *json2 = [ARLNetwork getAnswers:self.inquiry.inquiryId];
            NSArray *answers = [json2 valueForKey:@"result"];
        
            [newViewController performSelector:@selector(setAnswers:) withObject:answers];
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
            if (self.inquiry.run) {
                [newViewController performSelector:@selector(setInquiry:) withObject:self.inquiry];
            }
        }
            break;
            
        case ANALYSIS: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
        }
            break;
            
        case DISCUSS: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DiscussView"];
            
             // Pass the parameters to render.
            if ([newViewController respondsToSelector:@selector(setInquiryId:)]) {
                [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiry.inquiryId];
            }
        }
            break;
            
        case COMMUNICATE: {
            // newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommunicateView"];
        }
            break;
            
        default: {
            DLog(@"Unknown InquiryPart: %@", index);
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
        case PARTS: {
            
            switch (indexPath.item) {
                case DESCRIPTION:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;

                case HYPOTHESIS:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case PLAN: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Not implemented yet", @"Not implemented yet") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
                    
                case DATACOLLECTION:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case QUESTION:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case ANALYSIS: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Not implemented yet", @"Not implemented yet") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
                    
                case DISCUSS: {
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    self.navigationController.toolbarHidden = NO;
                }
                    break;
                    
                case COMMUNICATE: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Not implemented yet", @"Not implemented yet") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
            }
            
            if (newViewController && [newViewController respondsToSelector:@selector(initWithInitialPage:)]) {
                [newViewController performSelector:@selector(initWithInitialPage:) withObject:[NSNumber numberWithInteger:indexPath.item]];
            }
        }
            
            break;
            
//        case INVITE: {
//            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriendTableViewController"];
//            
//            if ([newViewController respondsToSelector:@selector(setInquiryId:)]) {
//                [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiry.inquiryId];
//            }
//            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", @"Notice") message:NSLocalizedString(@"Not implemented yet", @"Not implemented yet") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
//            //            [alert show];
//        }
//            break;
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

@end
