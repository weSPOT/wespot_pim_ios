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
     *  Number of items in this NS_ENUM.
     */
    numItems,
};

/*!
 *  TableView Sections.
 */
typedef NS_ENUM(NSInteger, sections) {
    /*!
     *  Inquiry Parts
     */
    HEADER =0,
    /*!
     *  Inquiry Parts
     */
    PARTS,
    /*!
     *  Invite Friends.
     */
    INVITE,
    
    /*!
     *  NUmber of Sections.
     */
    numSections
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (readonly, nonatomic) CGFloat navbarWidth;

@end

@implementation INQInquiryTableViewController

-(CGFloat) navbarWidth {
    return self.navigationController.navigationBar.bounds.size.width;
}

-(NSString *) cellIdentifier {
    return  @"inquiryPartCell";
}

- (void)refreshTable {
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
    
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:DATACOLLECTION inSection:PARTS], nil];
    
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    
    if (ARLNetwork.networkAvailable && self.inquiry.run) {
        ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        [INQCloudSynchronizer syncInquiryUsers:appDelegate.managedObjectContext inquiryId:self.inquiry.inquiryId];
        
        [ARLCloudSynchronizer syncVisibilityForInquiry:appDelegate.managedObjectContext run:self.inquiry.run];
    }
}

- (void)viewDidAppear:(BOOL)animated  {
    [self.tableView reloadData];
}

/*!
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        case HEADER:
            return 1;
        case PARTS :
            return numItems;
        case INVITE :
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier]; // forIndexPath:indexPath
    
    if (!cell || (indexPath.section==HEADER)) {
        switch (indexPath.section) {
            case HEADER:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
                break;
            case PARTS:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:self.cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case INVITE:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
                break;
        }
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case HEADER:
            if (cell.contentView.subviews.count==0)
            {
                // Icon
                UIImage *image = [UIImage imageNamed:@"description"];
                UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                
                imageView.backgroundColor = [UIColor clearColor];
                //[imageView setFrame:CGRectMake(5, 5, imageView.frame.size.width, imageView.frame.size.height)];
                imageView.translatesAutoresizingMaskIntoConstraints = NO;
                
                [cell.contentView addSubview:imageView];
                
                // Tile
                UITextView *textView = [[UITextView alloc] init];
                textView.backgroundColor = [UIColor clearColor];
                textView.editable = NO;
                textView.text = self.inquiry.title;
                //textView.frame = CGRectMake(110, 5, self.navbarWidth-115, 100);
                
                textView.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:textView];
                
                // Description
                UIWebView *webView = [[UIWebView alloc] init];
                webView.backgroundColor = [UIColor clearColor];
                [webView loadHTMLString:self.inquiry.desc baseURL:nil];
                
                webView.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:webView];
                
                cell.detailTextLabel.text = @"";
                //Remove Constraints
                
                //Add Constraints
                NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                 imageView, @"icon",
                                                 textView, @"text",
                                                 webView, @"description",
                                                 nil];
                
                [cell.contentView addConstraints:[NSLayoutConstraint
                                                  constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[icon(==%0.0f)]-[text]-|", image.size.width]
                                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                                  metrics:nil
                                                  views:viewsDictionary]];
                
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[icon(==%0.0f)]", image.size.height]
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                
                [cell.contentView addConstraints:[NSLayoutConstraint
                                                  constraintsWithVisualFormat:@"V:|-[text(==icon)]"
                                                  options:NSLayoutFormatDirectionLeadingToTrailing
                                                  metrics:nil
                                                  views:viewsDictionary]];
                
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-[description]-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[icon]-[description(==%0.0f)]", 210-image.size.height-2*20]
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                
                
                //Cell
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case PARTS : {
            switch (indexPath.item) {
                case HYPOTHESIS:
                    cell.textLabel.text = @"Hypothesis";
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
                    
                    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    NSInteger count = [appDelegate entityCount:@"CurrentItemVisibility"
                                                     predicate:[NSPredicate predicateWithFormat:@"visible = 1 and run.runId = %lld", [self.inquiry.run.runId longLongValue]]];
                    
                    if (count!=0) {
                        NSString *value = [[NSString alloc] initWithFormat:@"%d", count];
                        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:value];
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
                case DISCUSS:
                    cell.textLabel.text = @"Discuss";
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"discuss"];
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
            
        case INVITE:
            cell.textLabel.text = @"Invite friends";
            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
            cell.detailTextLabel.text = @"";
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case HEADER:
            return 210;
        case PARTS:
            return tableView.rowHeight;
        case INVITE:
            return tableView.rowHeight;
    }
    
    // Error
    return tableView.rowHeight;
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
            // newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlanView"];
        }
            break;
            
        case DATACOLLECTION: {
            // Create the new ViewController.
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollectDataView"];
            
            // Pass the parameters to render.
            if (self.inquiry.run) {
                [newViewController performSelector:@selector(setRun:) withObject:self.inquiry.run];
            }
        }
            break;
            
        case ANALYSIS: {
            // newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AnalysisView"];
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
        case HEADER:
            break;
        case PARTS: {
            
            switch (indexPath.item) {
                case HYPOTHESIS:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case PLAN: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
                    
                case DATACOLLECTION:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case ANALYSIS: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
                    
                case DISCUSS:
                    newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
                    break;
                    
                case COMMUNICATE: {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
                    break;
            }
            
            if (newViewController && [newViewController respondsToSelector:@selector(initWithInitialPage:)]) {
                [newViewController performSelector:@selector(initWithInitialPage:) withObject:[NSNumber numberWithInteger:indexPath.item]];
            }
        }
            break;
            
        case INVITE: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteFriendTableViewController"];
            
            if ([newViewController respondsToSelector:@selector(setInquiryId:)]) {
                [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiry.inquiryId];
            }
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //            [alert show];
        }
            break;
    }

    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

@end
