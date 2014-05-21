//
//  INQDiscussViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQDiscussViewController.h"

@interface INQDiscussViewController ()

/*!
 *  ID's and order of the cells sections.
 */
typedef NS_ENUM(NSInteger, friends) {
    /*!
     *  Send a Message.
     */
    SEND = 0,
    /*!
     *  Messages.
     */
    MESSAGES,
    /*!
     *  Number of Inquires
     */
    numMessages
};

@property (readonly, nonatomic) NSString *cellIdentifier1;
@property (readonly, nonatomic) NSString *cellIdentifier2;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (readonly, nonatomic) NSInteger *messageCellHeight;

@end

@implementation INQDiscussViewController

-(NSString *) cellIdentifier1 {
    return  @"messageCell1";
}

-(NSString *) cellIdentifier2 {
    return  @"messageCell2";
}

-(NSInteger *) messageCellHeight {
    return 120;
}

- (void)setupFetchedResultsController {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    [request setFetchBatchSize:8];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(compare:)]];
    
    request.predicate = [NSPredicate predicateWithFormat:
                         @"run.runId == %lld",
                         [inquiry.run.runId longLongValue]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    NSLog(@"[%s] runId: %@", __func__, inquiry.run.runId);
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    if (ARLNetwork.networkAvailable) {
        [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext inquiryId:inquiry.inquiryId];
    }
    
    NSLog(@"[%s] Messages: %d", __func__, [[self.fetchedResultsController fetchedObjects] count]);
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return ;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    //    NSInteger count = [self.fetchedResultsController.fetchedObjects count];
    //
    //    NSError *error = nil;
    //    [self.fetchedResultsController performFetch:&error];
    //
    //    if (count != [self.fetchedResultsController.fetchedObjects count]) {
    //        [self.tableView reloadData];
    //    }

    
    // See if there are any Inquiry objects added and if so, reload the tableView.
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
    for (NSManagedObject *obj in insertedObjects) {
        if ([[obj entity].name isEqualToString:@"Message"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [self.tableView reloadData];
            return;
        }
    }
}

/*!
 *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
 */
-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self setupFetchedResultsController];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return numMessages;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case SEND:
            return @"";
        case MESSAGES:
            return @"Messages";
    }
    
    // Error
    return @"";
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
    // Return the number of rows in the section.
    switch (section) {
        case SEND:
            return 1;
        case MESSAGES:
            return [[self.fetchedResultsController fetchedObjects] count];
    }
    
    // Error
    return 0;
}

/*!
 *  Return the Tab/Users/veg/Developer/PersonalInquiryManager/PersonalInquiryManager/INQFriendsTableViewController.mle Data one Cell at a Time.
 *
 *  @param tableView The Table to be served.
 *  @param indexPath The IndexPath of the TableCell.
 *
 *  @return The Cell Content.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // if (!cell || (indexPath.section==SEND)) {
    switch (indexPath.section) {
        case SEND:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier1 forIndexPath:indexPath];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier1];
            }
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
            
        case MESSAGES:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier2 forIndexPath:indexPath]; // 
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier2];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
    }
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case SEND:
            cell.textLabel.text = @"Add message";
            cell.detailTextLabel.text = @"";
            cell.imageView.image = [UIImage imageNamed:@"add-friend"];
            break;
            
        case MESSAGES:{
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Message *message = ((Message *)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            // Fetch views by tag.
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
            UITextView *textView = (UITextView *)[cell.contentView viewWithTag:2];
            UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:3];
            UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:4];
            
            // 1) Caption
            textLabel.text = message.subject;
            textLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            // 2) Icon (User Avatar)
            imageView.image = [UIImage imageNamed:@"profile"];
            imageView.highlightedImage = [UIImage imageNamed:@"profile"];
            if (message.account) {
                NSData* icon = [message.account picture];
                
                if (icon) {
                    imageView.image = [UIImage imageWithData:icon];
                    imageView.highlightedImage = [UIImage imageWithData:icon];
                }
            }
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            // 3) Details (Date + User Name)
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:kCFDateFormatterShortStyle];

            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[message.date longLongValue]/1000.0];
            
            if (message.account) {
                detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [dateFormatter stringFromDate:date], message.account.name];
            } else {
                detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@", [dateFormatter stringFromDate:date], @"unknown sender"];
            }
            detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
            
            // 4) Message Body (can contain html).
            textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            textView.layer.borderWidth = 1.0f;
            textView.editable = NO;
            NSAttributedString *html = [[NSAttributedString alloc] initWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                                        options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                             documentAttributes:nil
                                                                          error:nil];
            
            textView.attributedText = html;
            textView.translatesAutoresizingMaskIntoConstraints = NO;
           
//            cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            // 5) Add constraints.
            NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             imageView,            @"icon",
                                             detailTextLabel,      @"details",
                                             textLabel,            @"text",
                                             textView,             @"body",
                                             // cell.contentView,     @"content",
                                             nil];
   
            [cell removeConstraints:cell.constraints];
            if (cell.imageView) {
                // 1) Size ContentView (needed to get rid of selected cell trouble)
//                //if (cell.contentView && !cell.isHidden) {
//                [cell addConstraints:[NSLayoutConstraint
//                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[content(==%d)]", (int)self.messageCellHeight]
//                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                      metrics:nil
//                                      views:viewsDictionary]];
//                [cell addConstraints:[NSLayoutConstraint
//                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[content(==%0.0f)]", tableView.bounds.size.width]
//                                      options:NSLayoutFormatDirectionLeadingToTrailing
//                                      metrics:nil
//                                      views:viewsDictionary]];
                //}
                
                // 2) Size Icon and align it with text.
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[icon(==%0.0f)]", tableView.rowHeight]
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-[icon(==%0.0f)]-[text]-|", tableView.rowHeight]
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                
                // 3) Align details with text and icon.
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"V:|-[text]-[details]"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:[icon]-[details]-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                
                // 4) Align body with icon.
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:@"H:|-[body]-|"
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
                [cell addConstraints:[NSLayoutConstraint
                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[icon]-[body(==%0.0f)]", (int)self.messageCellHeight-tableView.rowHeight-2*20]
                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                      metrics:nil
                                      views:viewsDictionary]];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SEND:
            return tableView.rowHeight;
        case MESSAGES:
            return 1.0f * (int)self.messageCellHeight;
    }
    
    // Error
    return tableView.rowHeight;
}

/*!
 *  For each row in the table jump to the associated view.
 *
 *  @param tableView The UITableView
 *  @param indexPath The NSIndexPath containing grouping/section and record index.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *newViewController;
    
    switch (indexPath.section) {
        case SEND: {
            if (ARLNetwork.networkAvailable) {
                newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddMessageController"];
                
                if ([newViewController respondsToSelector:@selector(setInquiryId:)]) {
                    [newViewController performSelector:@selector(setInquiryId:) withObject:self.inquiryId];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Only available when on-line" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
            break;
        case MESSAGES: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Not implemented yet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
    }
    
    if (newViewController) {
        [self.navigationController pushViewController:newViewController animated:YES];
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
//    
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, headerView.frame.size.width-120.0, headerView.frame.size.height)];
//    
//    headerLabel.textAlignment = NSTextAlignmentRight;
//    headerLabel.text = @"HEADER";
//    headerLabel.backgroundColor = [UIColor clearColor];
//    
//    [headerView addSubview:headerLabel];
//    
//    return headerView;
//    
//}
//
//-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return  30.0;
//}

//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//                               duration:(NSTimeInterval)duration{
//
//   // [self.tableView invalidateLayout];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
