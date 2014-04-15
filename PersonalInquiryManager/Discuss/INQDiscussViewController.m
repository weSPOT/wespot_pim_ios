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

@property (readonly, nonatomic) NSString *cellIdentifier;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation INQDiscussViewController

-(NSString *) cellIdentifier {
    return  @"messageCell";
}

- (void)setupFetchedResultsController {
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    
    [request setFetchBatchSize:8];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    request.predicate = [NSPredicate predicateWithFormat:
                         @"run.runId == %lld",
                         [inquiry.run.runId longLongValue]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedResultsController.delegate = self;
    
    NSLog(@"[%s] runId: %@", __func__, inquiry.run.runId);
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];

    NSLog(@"[%s] Messages: %d", __func__, [[self.fetchedResultsController fetchedObjects] count]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
    [self setupFetchedResultsController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

// Get Default Thread
// GET /rest/messages/thread/runId/5117857260109824/default

//{
//    "type": "org.celstec.arlearn2.beans.run.Thread",
//    "runId": 5117857260109824,
//    "threadId": 6397033275457536,
//    "name": "Default",
//    "deleted": false,
//    "lastModificationDate": 1395924374319
//}

// Get Messags from Default Thread
// GET /rest/messages/runId/5117857260109824/default

//{
//    "type": "org.celstec.arlearn2.beans.run.MessageList",
//    "serverTime": 1395925562539,
//    "messages": [
//                 {
//                     "type": "org.celstec.arlearn2.beans.run.Message",
//                     "runId": 5117857260109824,
//                     "deleted": false,
//                     "subject": "Heading",
//                     "body": "Here comes some text",
//                     "threadId": 6397033275457536,
//                     "messageId": 5802343513718784,
//                     "date": 1395925443163
//                 }
//                 ]
//}

// Post a Message on the Main Thread.
// POST /rest/messages/message

//{
//    "type": "org.celstec.arlearn2.beans.run.Message",
//    "runId": 5117857260109824,
//    "threadId": 6397033275457536,
//    "subject": "Heading",
//    "body": "Here comes some text"
//}

//{
//    "type": "org.celstec.arlearn2.beans.run.Message",
//    "runId": 5117857260109824,
//    "deleted": false,
//    "subject": "Heading",
//    "body": "Here comes some text",
//    "threadId": 6397033275457536,
//    "messageId": 5802343513718784,
//    "date": 1395925443163
//}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellIdentifier];
    }
    
    // cell.backgroundColor = [UIColor clearColor];
    
    // Configure the cell...
    
    switch (indexPath.section) {
        case SEND:
            cell.textLabel.text = @"Add message";
            // cell.imageView.image = [UIImage imageNamed:@"add-friend"];
            break;
        case MESSAGES:{
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
            
            Message *message = ((Message *)[self.fetchedResultsController objectAtIndexPath:ip]);
            
            cell.textLabel.text = message.subject;
            cell.detailTextLabel.text = message.body;
        }
    }
    
    return cell;
}

@end
