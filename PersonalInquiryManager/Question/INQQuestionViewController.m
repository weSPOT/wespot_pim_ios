//
//  INQQuestionViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQQuestionViewController.h"

@interface INQQuestionViewController ()
/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, indices) {
    /*!
     *  Question.
     */
    QUESTION = 0,

    /*!
     *  Number of items in this NS_ENUM.
     */
    numItems
};

/*!
 *  TableView Sections.
 */
typedef NS_ENUM(NSInteger, sections) {
    /*!
     *  Inquiry Parts
     */
    QUESTIONS =0,
 
    /*!
     *  Number of Sections in this NS_ENUM.
     */
    numSections
};

@property (weak, nonatomic) IBOutlet UIView *questionView;
@property (weak, nonatomic) IBOutlet UITextField *questionField;

@property (readonly, nonatomic) NSString *cellIdentifier;

//@property(nonatomic, assign) BOOL automaticallyAdjustsScrollViewInsets;

@end

@implementation INQQuestionViewController

@synthesize inquiryId = _inquiryId;

//-(BOOL)automaticallyAdjustsScrollViewInsets {
//    return NO;
//}
//
//-(void)setAutomaticallyAdjustsScrollViewInsets:(BOOL)automaticallyAdjustsScrollViewInsets  {
//    //
//}

/*!
 *  Getter
 *
 *  @return The First Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"questionCell";
}

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.questionField.delegate = self;
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Properties

-(NSNumber*)inquiryId {
    return _inquiryId;
}

- (void)updateQuestionsAndAnswers {
    self.Questions = [[ARLNetwork getQuestions:_inquiryId] valueForKey:@"result"];
    
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
    
    self.Answers = [[ARLNetwork getAnswers:_inquiryId] valueForKey:@"result"];
}

- (void) setInquiryId:(NSNumber *)inquiryId {
    _inquiryId = inquiryId;
    
    [self updateQuestionsAndAnswers];
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
        case QUESTIONS:
            return self.Questions.count;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case QUESTIONS:
            return @"Questions";
    }
    
    // Error
    return @"";
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
    
    // Configure the cell...
    switch (indexPath.section) {
        case QUESTIONS: {
            NSDictionary *question = [self.Questions objectAtIndex:indexPath.row];
            
            UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
            UITextView *textView = (UITextView *)[cell.contentView viewWithTag:2];

            cell.imageView.image = [UIImage imageNamed:@"question"];
            
            textView.editable = NO;
            
            //WARNING: Without this, the last line is missing.
            textView.scrollEnabled = YES;
            
            NSString *title = [question valueForKey:@"question"];
            
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            titleLabel.text = title.length==0 ? @"Question" : title;
            
            NSString *html = [question valueForKey:@"description"];
            NSString *body = [INQUtils cleanHtml:html];
            
            textView.text = body.length==0 ? @"No description." : body;
        
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    CGRect iframe = cell.imageView.frame;
    iframe.size = CGSizeMake(66.0f, 66.0f);
    iframe.origin = CGPointMake(iframe.origin.x, 8.0f);
    cell.imageView.frame = iframe;
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
    
    CGRect tframe = titleLabel.frame;
    tframe.size = CGSizeMake(self.tableView.frame.size.width - 66.0f - 2*8.0f, titleLabel.frame.size.height);
    tframe.origin = CGPointMake(66.0f, titleLabel.frame.origin.y);
    titleLabel.frame= tframe;

    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:2];
    
    NSString *body = textView.text;
    //NSString *tmp = [textView.text substringToIndex:2];
    float tw = tableView.frame.size.width - cell.imageView.frame.size.width - 2*8.0f;
    
    NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
    CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
    
    // Correct for top/bottom margins (58.0f is the designed height of the UITextView).
    CGRect frame = textView.frame;
    
    frame.size = CGSizeMake(tw, rect.size.height + 5*8.0f);
    //66.0f is the width of the image.
    frame.origin = CGPointMake(66.0f, frame.origin.y);
    
    textView.frame = frame;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
    
    switch (indexPath.section) {
        case QUESTIONS: {
            // Calculate the correct height here based on the message content!!
            NSDictionary *question = [self.Questions objectAtIndex:indexPath.row];
            
            NSString *html = [question valueForKey:@"description"];
            NSString *body = [INQUtils cleanHtml:html];
    
            if ([body length] == 0) {
                return rh;
            }

            // 66.0f is the width of the image.
            float tw = tableView.frame.size.width - 66.0f - 2*8.0f;
  
            NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
            CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];

            // Correct for top/bottom margins (58.0f is the designed height of the UITextView).
            return 1.0f * rh + rect.size.height + 5*8.0f - 58.0f;
            // return 1.0f*tableView.rowHeight + MIN((rect.size.height) + 2*8.0f, 64.0f) - 58.0f;
        }
    }
    
    // Error
    return rh;
}

- (void) createQuestion:(NSString *)title description:(NSString *)description
{
//    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
//method=add.question&
//    name=Sample_Question_KSa_19.02.2014&
//    description=Question Description&
//    tags=my Question Tags&
//    container_guid=27568&
//    provider=Google &user_uid=XXXXXXXXXXXXXXXXXXXXXX&
//    api_key=YOUR_API_KEY

    NSDictionary *result = [ARLNetwork addQuestionWithDictionary:title
                                                     description:description
                                                       inquiryId:self.inquiryId];
    
//    [Message messageWithDictionary:result
//            inManagedObjectContext:appDelegate.managedObjectContext];
//    
//    [INQLog SaveNLog:appDelegate.managedObjectContext];
//    
    DLog(@"%@", result);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length]>0) {
        NSString *body = [textField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([body length]>0) {
            [self createQuestion:NSLocalizedString(@"Question:", @"Question:")
                                 description:body];
            
            [self updateQuestionsAndAnswers];
            
            [self.tableView reloadData];
            
            textField.text = @"";

            [textField resignFirstResponder];
            
            return YES;
        }
    }
    
    return NO;
}

@end
