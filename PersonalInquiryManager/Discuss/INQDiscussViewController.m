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
typedef NS_ENUM(NSInteger, messages) {
    /*!
     *  Messages.
     */
    MESSAGES = 0,
    
    /*!
     *  Number of Section
     */
    numMessages
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (weak, nonatomic) IBOutlet UITextField *chatMessageField;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQDiscussViewController

int messageLimit = 25;

int messageIncrement = 25;

NSDictionary *attr;

// see http://stackoverflow.com/questions/920675/how-can-i-delay-a-method-call-for-1-second

typedef void (^WaitCompletionBlock)();

void waitFor(NSTimeInterval duration, WaitCompletionBlock completion)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^
                   { completion(); });
}

-(NSString *) cellIdentifier {
    return  @"messageCell";
}

- (void)setupFetchedResultsController {
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    [request setFetchBatchSize:8];
    [request setFetchLimit:messageLimit];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                     ascending:NO
                                                                                      selector:@selector(compare:)]];
    
    // Get Messages of last two days with a max of 25.
    //
    //    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    //    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-2*24*60*60];
    //    NSNumber *interval = [NSNumber numberWithDouble:[date timeIntervalSince1970] * 1000];
    //    NSNumber *ticks = [NSNumber numberWithDouble:[now timeIntervalSince1970] * 1000];
    //
    //    DLog(@"%lld",[interval longLongValue]);
    //    DLog(@"%lld",[ticks longLongValue]);
    
    request.predicate = [NSPredicate predicateWithFormat:
                         //@"(run == %@)
                         @"(run == %@)", //AND (date > %lld)",
                         inquiry.run /*,[interval longLongValue]*/];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:@"chat"];
    
    self.fetchedResultsController.delegate = self;
    
    DLog(@"RunId: %@", inquiry.run.runId);
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    DLog(@"Messages: %d", [[self.fetchedResultsController fetchedObjects] count]);
}

/*!
 *  Called when an SYNC Progress notification is received.
 *
 *  @param notification <#notification description#>
 */
- (void)syncProgress:(NSNotification*)notification
{
    // Nothing yet
}

/*!
 *  Called when an Sync Ready notification is received.
 *
 *  @param notification <#notification description#>
 */
- (void)syncReady:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncReady:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
    
    NSString *recordType = notification.object;
    
    // Log(@"syncReady:%@", recordType);
    
    if ([NSStringFromClass([Message class]) isEqualToString:recordType]) {
        NSError *error = nil;
      
        NSUInteger cntBefore = [[self.fetchedResultsController fetchedObjects] count];
        
        [self.fetchedResultsController performFetch:&error];
        
        ELog(error);
        
        NSUInteger cntAfter = [[self.fetchedResultsController fetchedObjects] count];
        
        if (cntBefore!=cntAfter) {
            DLog(@"Messages: %d -> %d", cntBefore, cntAfter);
            
            [self.tableView reloadData];
        }
    }
    
    [self adjustChatWidth];
    
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame
                               animated:NO];
}

/*!
 *  Called when an APN notification is received.
 *
 *  @param notification <#notification description#>
 */
- (void)syncAPN:(NSNotification*)notification
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(syncAPN:)
                               withObject:notification
                            waitUntilDone:YES];
        return;
    }
  
    // Log(@"syncAPN");
    
    [self syncData];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

/*!
 *  See iOS documentation.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
   
	// Do any additional setup after loading the view.
    attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
    
    messageLimit = messageIncrement;
    
    self.chatMessageField.delegate = self;
    
    [self adjustChatWidth];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to add more messages"];
}

/*!
 *  See iOS documentation.
 *
 *  @param animated <#animated description#>
 */
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setupFetchedResultsController];
    
    // [self.tableView reloadData];

    [self.navigationController setToolbarHidden:NO];
}

/*!
 *  See iOS documentation.
 *
 *  @param animated <#animated description#>
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    [self.tableView scrollRectToVisible:self.tableView.tableFooterView.frame
                               animated:NO];
    
    if (ARLNetwork.networkAvailable) {
        ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];

        if (self.fetchedResultsController.fetchedObjects.count == 0) {
            @autoreleasepool {
                
                Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId
                                                     withManagedContext:appDelegate.managedObjectContext];
                
                NSDictionary * tmDict = [ARLNetwork defaultThreadRecentMessages:inquiry.run.runId
                                                                            cnt:messageLimit];
                
                NSArray *messages = (NSArray *)[tmDict objectForKey:@"messages"];
                
                tmDict = nil;
                
                DLog(@"Retrieved %d Messages", [messages count]);
                
                for (NSDictionary *mDict in messages)
                {
                    [Message messageWithDictionary:mDict inManagedObjectContext:appDelegate.managedObjectContext];
                }
                
                [INQLog SaveNLog:appDelegate.managedObjectContext];
            }
            
            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];
            
            Log(@"Latest Records: %d", self.fetchedResultsController.fetchedObjects.count);
        }
        
        waitFor(1.0, ^
                {
                    [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext
                                             inquiryId:self.inquiryId];
                });
    }
}

/*!
 *  See iOS documentation.
 *
 *  @param animated <#animated description#>
 */
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCPROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_SYNCREADY object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INQ_GOTAPN object:nil];

    [self.navigationController setToolbarHidden:YES];
}

/*!
 *  See iOS documentation.
 */
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
            return [NSString stringWithFormat:@"Chat (Latest %d)", self.fetchedResultsController.fetchedObjects.count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case MESSAGES:{
            @autoreleasepool {
                NSInteger ndx = self.fetchedResultsController.fetchedObjects.count - indexPath.row -1 ;

                Message *message = (Message *)[self.fetchedResultsController.fetchedObjects objectAtIndex:ndx];
                
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
                        
                        @autoreleasepool {
                            CGRect frame = detailTextLabel.frame;
                            
                            frame.origin = CGPointMake(tableView.rowHeight + 8.0f, 8.0f);
                            frame.size = CGSizeMake(tableView.frame.size.width - tableView.rowHeight - 2*8.0f, frame.size.height);
                            
                            detailTextLabel.frame = frame;
                            detailTextLabel.textAlignment = NSTextAlignmentRight;
                        }
                        
                        @autoreleasepool {
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
                        
                        @autoreleasepool {
                            CGRect frame = detailTextLabel.frame;
                            
                            frame.origin = CGPointMake(8.0f,
                                                       8.0f);
                            frame.size = CGSizeMake(tableView.frame.size.width - tableView.rowHeight - 3*8.0f,
                                                    frame.size.height);
                            
                            detailTextLabel.frame = frame;
                            detailTextLabel.textAlignment = NSTextAlignmentLeft;
                        }
                        
                        @autoreleasepool {
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
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Log(@"heightForRowAtIndexPath %@",indexPath);

    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;

    switch (indexPath.section) {
        case MESSAGES: {
            // Calculate the correct height here based on the message content!!
            @autoreleasepool {
                NSInteger ndx =self.fetchedResultsController.fetchedObjects.count-indexPath.row-1;
                
                Message *message = (Message *)[self.fetchedResultsController.fetchedObjects objectAtIndex:ndx];
                
                NSString *body = message.body; //[INQUtils cleanHtml:message.body];
                
                if ([body length] == 0) {
                    return rh;
                }
                
                float tw = tableView.frame.size.width - rh - 3*8.0f;
                
                CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                
                // Correct for top/bottom margins.
                return 1.0f * rh + rect.size.height + 3*8.0f;
            }
        }
    }
    
    // Error
    return rh;
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
    [((UITableViewHeaderFooterView *)view).textLabel setTextColor:[UIColor whiteColor]];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
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
            
//            if (ARLNetwork.networkAvailable) {
//                ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//                
//                [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext inquiryId:self.inquiryId];
//            }

            NSError *error = nil;
            [self.fetchedResultsController performFetch:&error];

            textField.text = @"";
            
            [textField resignFirstResponder];

            [self.tableView reloadData];
            
            return YES;
        }
    }
    
    return NO;
}

/*!
 *  Pre iOS7 Code
 *
 *  @return <#return value description#>
 */
- (BOOL)shouldAutorotate {
    return NO;
}

/*!
 *  Pre iOS7 Code
 *
 *  @return <#return value description#>
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

/*!
 *  iOS 7+ Code ?
 *
 *  @param application <#application description#>
 *  @param window      <#window description#>
 *
 *  @return <#return value description#>
 */
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)refreshTable {
    // Reload table data
    
    messageLimit = messageLimit + messageIncrement;

    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];
    
    [NSFetchedResultsController deleteCacheWithName:@"chat"];
    
    self.fetchedResultsController.fetchRequest.fetchLimit = messageLimit;
    self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:
                                                            @"(run == %@)",
                                                            inquiry.run];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    // End the refreshing
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
}

- (void)adjustChatWidth
{
    @autoreleasepool {
        CGRect fr1 = self.chatMessageField.frame;
        CGRect fr2 = self.chatView.frame;
        
        [self.chatMessageField setFrame:CGRectMake(fr1.origin.x, fr1.origin.y, fr2.size.width-2*fr1.origin.x, fr1.size.height)];
    }
}

@end
