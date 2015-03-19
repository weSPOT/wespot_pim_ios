//
//  INQQuestionViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQAnswersViewController.h"

@interface INQAnswersViewController ()

///*!
// *  ID's and order of the cells.
// */
//typedef NS_ENUM(NSInteger, indices) {
//    /*!
//     *  Answer.
//     */
//    ANSWER = 0,
//
//    /*!
//     *  Number of items in this NS_ENUM.
//     */
//    numItems
//};

/*!
 *  TableView Sections.
 */
typedef NS_ENUM(NSInteger, sections) {
    /*!
     *  Answers
     */
    QUESTION =0,
    
    /*!
     *  Answers
     */
    ANSWERS =1,
 
    /*!
     *  Number of Sections in this NS_ENUM.
     */
    numSections
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQAnswersViewController

@synthesize Answers = _Answers;

@synthesize Description = _Description;

/*!
 *  Getter
 *
 *  @return The First Cell Identifier.
 */
-(NSString *) cellIdentifier {
    return  @"answerCell";
}

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.opaque = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main"]];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];

    [self.navigationController setToolbarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
        case QUESTION:
            return 1;
        
        case ANSWERS:
            return self.Answers.count;
    }
    
    return 0;
}

/*!
 *  Return header text for Sections.
 *
 *  @param tableView <#tableView description#>
 *  @param section   <#section description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case QUESTION:
            return @"Question";
        
        case ANSWERS:
            return @"Answer(s)";
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

    NSDictionary *answer = [self.Answers objectAtIndex:indexPath.row];

    // Configure the cell...
    switch (indexPath.section) {
        case QUESTION: {
            @autoreleasepool {
                NSString *body = [[[answer valueForKey:@"question"] stringByAppendingString:@"\r\n\r\n"] stringByAppendingString:[INQUtils cleanHtml:self.Description]];
                
                // cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
                
                float tw = tableView.frame.size.width - cell.imageView.frame.size.width - 2*8.0f;
                
                NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                
                cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, rect.size.width,rect.size.height);
                
                cell.textLabel.text = body;
                
                cell.detailTextLabel.text = @"";
            }
        }
            break;
            
        case ANSWERS: {
            @autoreleasepool {
                //            {
                //                answer = "<p>adasasdasd</p>";
                //                answerId = 89043;
                //                description = "<p>asasdasad &nbsp;asd a</p>";
                //                question = TESTTTTT;
                //                questionId = 89021;
                //                url = "http://inquiry.wespot.net/answers/view/89021/testtttt#elgg-object-89043";
                //            }
                 NSString *body = [INQUtils cleanHtml:[answer valueForKey:@"answer"]];
                
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
                
                float tw = tableView.frame.size.width - cell.imageView.frame.size.width - 2*8.0f;
                
                NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                
                cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, rect.size.width,rect.size.height);

                cell.textLabel.text = body;
                
                cell.detailTextLabel.text = @"";
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @autoreleasepool {
        CGFloat rh = tableView.rowHeight==-1 ? 44.0f : tableView.rowHeight;
        
        NSDictionary *answer = [self.Answers objectAtIndex:indexPath.row];
        
        float tw = tableView.frame.size.width - rh - 3*8.0f;
        
        switch (indexPath.section) {
            case QUESTION: {
                // Calculate the correct height here based on the message content!!
                @autoreleasepool {
                    NSString *body = [[[answer valueForKey:@"question"] stringByAppendingString:@"\r\n\r\n"] stringByAppendingString:[INQUtils cleanHtml:self.Description]];
                    
                    if ([body length] == 0) {
                        return rh;
                    }
                    
                    NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                    CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                    
                    // Correct for top/bottom margins.
                    return 1.0f * rh + rect.size.height + 3*8.0f;
                }
            }
                
            case ANSWERS: {
                @autoreleasepool {
                    NSString *body = [INQUtils cleanHtml:[answer valueForKey:@"answer"]];
                    
                    if ([body length] == 0) {
                        return rh;
                    }
                    
                    NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                    CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                    
                    // Correct for top/bottom margins.
                    return 1.0f * rh + rect.size.height + 3*8.0f;
                }
            }
                break;
                
        }
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

@end
