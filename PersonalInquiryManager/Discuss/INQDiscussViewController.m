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
     *  Messages.
     */
    MESSAGES = 0,
    /*!
     *  Send a Message.
     */
    SEND,
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
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                     ascending:YES
                                                                                      selector:@selector(compare:)]];
    
    request.predicate = [NSPredicate predicateWithFormat:
                         @"run.runId == %lld",
                         [inquiry.run.runId longLongValue]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
    
    DLog(@"RunId: %@", inquiry.run.runId);
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
//    if (ARLNetwork.networkAvailable) {
//        [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext
//                                 inquiryId:inquiry.inquiryId];
//    }
    
    DLog(@"Messages: %d", [[self.fetchedResultsController fetchedObjects] count]);
}

- (void)contextChanged:(NSNotification*)notification
{
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([notification object] == appDelegate.managedObjectContext) {
        return;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    //NSInteger count = [self.fetchedResultsController.fetchedObjects count];
    //
    //    NSError *error = nil;
    //    [self.fetchedResultsController performFetch:&error];
    //
    //    if (count != [self.fetchedResultsController.fetchedObjects count]) {
    //        [self.tableView reloadData];
    //    }
    
    
    // See if there are any Inquiry objects added and if so, reload the tableView.
    NSSet *insertedObjects = [[notification userInfo] objectForKey:NSInsertedObjectsKey];
    
#warning This does not see newly added messages.
    
    for (NSManagedObject *obj in insertedObjects) {
        if ([[obj entity].name isEqualToString:@"Message"]) {
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            [self.tableView reloadData];
            
            [self.tableView setContentOffset:CGPointMake(0, MAXFLOAT)];
        }
    }
    
//    NSError *error = nil;
//    
//    [self.fetchedResultsController performFetch:&error];
//    
//    [self.tableView reloadData];
}

///*!
// *  See http://stackoverflow.com/questions/6469209/objective-c-where-to-remove-observer-for-nsnotification
// */
//-(void) dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
	// Do any additional setup after loading the view.
    
    //[self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    //
    //    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    //    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupFetchedResultsController];
    
    [self.tableView reloadData];
    
    [self.tableView setContentOffset:CGPointMake(0, MAXFLOAT)];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.navigationController setToolbarHidden:YES];
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

/*!
 *  <#Description#>
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case MESSAGES:
            return @"Chat";
        case SEND:
            return @"";
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
        case MESSAGES:
            return [[self.fetchedResultsController fetchedObjects] count];
        case SEND:
            return 1;
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

    switch (indexPath.section) {
        case MESSAGES:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier2 forIndexPath:indexPath];

            cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
            
        case SEND:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier1 forIndexPath:indexPath];

            cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
            
    }
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case MESSAGES:{
            @autoreleasepool {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                
                Message *message = ((Message *)[self.fetchedResultsController objectAtIndexPath:ip]);
                
                // Fetch views by tag.
                // UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1];
                UITextView *textView = (UITextView *)[cell.contentView viewWithTag:2];
                UILabel *detailTextLabel = (UILabel *)[cell.contentView viewWithTag:3];
                
                // textView.contentInset = UIEdgeInsetsMake(0,-4,0,+20);
                
                BOOL MyMessage =
                [message.account.localId isEqualToString:[ARLNetwork CurrentAccount].localId] &&
                [message.account.accountType isEqualToNumber:[ARLNetwork CurrentAccount].accountType];
                
                // 2) Icon (User Avatar)
                // imageView.image = [UIImage imageNamed:@"profile"];
                // imageView.highlightedImage = [UIImage imageNamed:@"profile"];
                // if (message.account) {
                // NSData* icon = [message.account picture];
                //
                // if (icon) {
                // imageView.image = [UIImage imageWithData:icon];
                // imageView.highlightedImage = [UIImage imageWithData:icon];
                // }
                // }
                // imageView.translatesAutoresizingMaskIntoConstraints = NO;
                
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
                
                textView.editable = NO;
                
                //WARNING: Without this, the last line is missing.
                textView.scrollEnabled = NO;
                
                // Old Code...Fi
                // NSAttributedString *html = [[NSAttributedString alloc] initWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                // options:@{
                // NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                // NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                // }
                // documentAttributes:nil
                // error:nil];
                // textView.attributedText = html;
                
                // New Code...
                textView.text = [INQUtils cleanHtml:message.body];
                
                float tw = tableView.frame.size.width - tableView.rowHeight - 3*8.0f;
                
                CGSize size = [textView sizeThatFits:CGSizeMake(tw, FLT_MAX)];
                
                switch(MyMessage) {
                    case TRUE: {
                        [INQUtils addRoundedCorner:cell
                                 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft
                                      deltaOriginX:tableView.rowHeight + 1*8.0f
                                      deltaOriginY:4
                                        deltaWidth:tableView.rowHeight + 1*8.0f
                                       deltaHeight:4
                                            radius:10.0f];

                        {
                            CGRect frame = detailTextLabel.frame;
                            
                            frame.origin = CGPointMake(tableView.rowHeight + 8.0f, 8.0f);
                            frame.size = CGSizeMake(tableView.frame.size.width - tableView.rowHeight - 2*8.0f, frame.size.height);
                            
                            detailTextLabel.frame = frame;
                            detailTextLabel.textAlignment = NSTextAlignmentRight;
                        }
                        
                        {
                            CGRect frame = detailTextLabel.frame;
                            frame.origin =  CGPointMake(detailTextLabel.frame.origin.x,
                                                        detailTextLabel.frame.origin.y + detailTextLabel.frame.size.height + 8.0f);
                            frame.size = CGSizeMake(detailTextLabel.frame.size.width,
                                                    size.height);
                            textView.frame = frame;
                            textView.textAlignment = NSTextAlignmentRight;
                        }
                    }
                        break;
                        
                    case FALSE: {
                        [INQUtils addRoundedCorner:cell
                                 byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight
                                      deltaOriginX:0
                                      deltaOriginY:4
                                        deltaWidth:tableView.rowHeight + 2*8.0f
                                       deltaHeight:4
                                            radius:10.0f];
                        
                        {
                            CGRect frame = detailTextLabel.frame;
                            
                            frame.origin = CGPointMake(8.0f,
                                                       8.0f);
                            frame.size = CGSizeMake(tableView.frame.size.width - tableView.rowHeight - 3*8.0f,
                                                    frame.size.height);
                            
                            detailTextLabel.frame = frame;
                            detailTextLabel.textAlignment = NSTextAlignmentLeft;
                        }
                        
                        {
                            CGRect frame = detailTextLabel.frame;
                            
                            frame.origin =  CGPointMake(detailTextLabel.frame.origin.x,
                                                        detailTextLabel.frame.origin.y + detailTextLabel.frame.size.height + 8.0f);
                            frame.size = CGSizeMake(detailTextLabel.frame.size.width,
                                                    size.height);
                            
                            textView.frame = frame;
                            textView.textAlignment = NSTextAlignmentLeft;
                        }
                    }
                        break;
                        
                }
            }
            break;
            
        case SEND: {
            UITextField *text = (UITextField *)[cell.contentView viewWithTag:1];
            
            [text setDelegate:self];
        }
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MESSAGES: {
            // Calculate the correct height here based on the message content!!
            
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            Message *message = (Message *)[self.fetchedResultsController objectAtIndexPath:ip];
            
            NSString *body = [INQUtils cleanHtml:message.body];
            
            if ([body length] == 0) {
                return tableView.rowHeight;
            }
            
            float tw = tableView.frame.size.width - tableView.rowHeight - 3*8.0f;
            
            NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
            CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
            
            // Correct for top/bottom margins.
            return 1.0f * tableView.rowHeight + rect.size.height + 3*8.0f;
        }
        case SEND:
            return tableView.rowHeight;
    }
    
    // Error
    return tableView.rowHeight;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

- (void)syncData {
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext
                                 inquiryId:self.inquiryId];
    }
}

- (void) createDefaultThreadMessage:(NSString *)title description:(NSString *)description {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];
    
    NSNumber *threadId = [[ARLNetwork defaultThread:inquiry.run.runId] objectForKey:@"threadId"];
    
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:
                             inquiry.run.runId,     @"runId",
                             threadId,              @"threadId",
                             title,                 @"subject",
                             description,           @"body",
                             nil];
    
    NSDictionary *result = [ARLNetwork addMessage:[ARLAppDelegate jsonString:message]];
    
    [Message messageWithDictionary:result
            inManagedObjectContext:appDelegate.managedObjectContext];
    
    [INQLog SaveNLog:appDelegate.managedObjectContext];
    
    DLog(@"%@", result);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length]>0) {
        NSString *body = [textField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([body length]>0) {
            [self createDefaultThreadMessage:NSLocalizedString(@"Reply", @"Reply")
                                 description:body];
            
            if (ARLNetwork.networkAvailable) {
                ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext inquiryId:self.inquiryId];
            }
            
            NSError *error = nil;
            
            [self.fetchedResultsController performFetch:&error];
            
            textField.text = @"";
            
            return YES;
        }
    }
    
    return NO;
}

@end
