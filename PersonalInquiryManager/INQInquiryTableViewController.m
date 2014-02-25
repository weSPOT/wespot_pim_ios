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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //See http://stackoverflow.com/questions/5825397/uitableview-background-image
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    //self.inqueryView.backgroundColor = [UIColor clearColor];
    
    // Load Icon.
//    NSData *icon = [self.inquiry icon];
//    if (icon) {
//        UIImage *image = [UIImage imageWithData:icon];
//        self.icon.image = image;
//    }
    
    // Load description
//    [self.inquiryDescription loadHTMLString:self.inquiry.desc baseURL:nil];
    // [self.inquiryDescription loadHTMLString:@"<html><body style='background-color:red;'>test</body></html>" baseURL:nil];
  
    
//    NSLog(@"[%s] desc %@", __func__, self.inquiry.desc);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    // Disable some conflicting XCODE habits.
//    self.icon.translatesAutoresizingMaskIntoConstraints = NO;
//    self.inquiryDescription.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Remove constraints.
//    [self.view removeConstraints:[self.view constraints]];
//
//    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
//        self.view, @"view",
//        self.icon, @"icon",
//        self.inquiryDescription, @"description",
//        nil];
//
//    NSString *constraint;
//    
//    constraint = [NSString stringWithFormat:@"H:|-5-[icon(==%0.0f)]-[description]-5-|", self.icon.image.size.width];
//    //NSLog(@"Constraint: %@", constraint);
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:constraint
//                               options:NSLayoutFormatDirectionLeadingToTrailing
//                               metrics:nil
//                               views:viewsDictionary]];
//
//    constraint = [NSString stringWithFormat:@"V:|-5-[icon(==%0.0f)]-5-|", self.icon.image.size.height];
//    //NSLog(@"Constraint: %@", constraint);
//    [self.view addConstraints:[NSLayoutConstraint
//                               constraintsWithVisualFormat:constraint
//                               options:NSLayoutFormatDirectionLeadingToTrailing
//                               metrics:nil
//                               views:viewsDictionary]];
//
//    constraint = @"V:|-5-[description(==icon)]";
//    //NSLog(@"Constraint: %@", constraint);
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    // cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    switch (indexPath.section) {
        case HEADER:
            //TODO
            if (cell.contentView.subviews.count==0)
            {
                
                // [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                
                // Icon
                NSData* icon = [self.inquiry icon];
                UIImage *image;
                if (icon) {
                    image = [UIImage imageWithData:icon];
                }
                UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                imageView.backgroundColor = [UIColor orangeColor];
                //[imageView setFrame:CGRectMake(5, 5, imageView.frame.size.width, imageView.frame.size.height)];
                imageView.translatesAutoresizingMaskIntoConstraints = NO;
          
                [cell.contentView addSubview:imageView];
                
                //Tile
                UITextView *textView = [[UITextView alloc] init];
                textView.backgroundColor = [UIColor orangeColor];
                textView.editable = NO;
                textView.text = self.inquiry.title;
                //textView.frame = CGRectMake(110, 5, self.navbarWidth-115, 100);
                
                textView.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:textView];

                // Description
                UIWebView *webView = [[UIWebView alloc] init];
                // webView.delegate = self;
                webView.backgroundColor = [UIColor orangeColor];
                //webView.frame = CGRectMake(5, 110, self.navbarWidth-10, 100);
                [webView loadHTMLString:self.inquiry.desc baseURL:nil];
                
                webView.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:webView];
         
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
                    cell.textLabel.text = @"Communicate";
                    break;
                default:
                    break;
                }
            }
            break;
            
        case INVITE:
            cell.textLabel.text = @"Invite friends";
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
                //[newViewController performSelector:@selector(setRun:) withObject:selectedRun];
                gameId = selectedRun.gameId;
            } else {
                gameId = [ARLNetwork getARLearnGameId:self.inquiry.inquiryId];
            }
            
            if (selectedRun.runId) {
                [newViewController performSelector:@selector(setRun:) withObject:selectedRun];
            }
        
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
        case HEADER:
            break;
        case PARTS: {
            newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryPartPageViewController"];
            if ([newViewController respondsToSelector:@selector(initWithInitialPage:)]) {
                [newViewController performSelector:@selector(initWithInitialPage:) withObject:[NSNumber numberWithInteger:indexPath.item]];
            }
            break;
            
        case INVITE: {
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
