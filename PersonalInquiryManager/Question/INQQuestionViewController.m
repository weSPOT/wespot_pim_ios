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

@property (readonly, nonatomic) NSString *cellIdentifier;

//@property(nonatomic, assign) BOOL automaticallyAdjustsScrollViewInsets;

@end

@implementation INQQuestionViewController


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
        
            textView.editable = NO;
            
            //WARNING: Without this, the last line is missing.
            textView.scrollEnabled = YES;
            
            NSString *title = [question valueForKey:@"question"];
            
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            titleLabel.text = title.length==0 ? @"?" : title;
            
            //cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            
            NSString *html = [question valueForKey:@"description"];
            NSString *body = [INQUtils cleanHtml:html];
            
            textView.text = body;
            
            // CGSize size = [textView sizeThatFits:CGSizeMake(tw, FLT_MAX)];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            {
                float tw = tableView.frame.size.width - 5*8.0f;
                
                NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
                CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];
                
                // Correct for top/bottom margins (58.0f is the designed height of the UITextView).
                CGRect frame = textView.frame;
                
                //frame.size = CGSizeMake(frame.size.width, MIN(rect.size.height + 2*8.0f, 64.0f));
                frame.size = CGSizeMake(tw, rect.size.height + 3*8.0f);
                frame.origin = CGPointMake(titleLabel.frame.origin.x, frame.origin.y);
                
                textView.frame = frame;
            }
            
//            {
//                CGFloat topCorrect = ([textView bounds].size.height - [textView contentSize].height * [textView zoomScale])/2.0;
//                topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
//                textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
//            }
            // Size?
            
            //            {
//                CGRect frame = textView.frame;
//                
//                frame.origin = CGPointMake(8.0f,
//                                           titleLabel.frame.origin.y + titleLabel.frame.size.height + 8.0f);
//                
//                frame.size = CGSizeMake(tableView.frame.size.width /*- tableView.rowHeight*/ - 2*8.0f,
//                                     tableView.rowHeight+(frame.size.height-58.0f));
//                
//                textView.frame = frame;
//                textView.textAlignment = NSTextAlignmentLeft;
//            }
   
            // Location?
//            {
//                CGRect frame = textView.frame;
//                
//                frame.origin =  CGPointMake(textView.frame.origin.x,
//                                            textView.frame.origin.y + textView.frame.size.height + 8.0f);
//                frame.size = CGSizeMake(textView.frame.size.width,
//                                        size.height);
//                
//                textView.frame = frame;
//                textView.textAlignment = NSTextAlignmentLeft;
//            }
            
            //textView.editable = YES;
            
            //textView.scrollEnabled = YES;
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case QUESTIONS: {
            // Calculate the correct height here based on the message content!!
            NSDictionary *question = [self.Questions objectAtIndex:indexPath.row];
            
            NSString *html = [question valueForKey:@"description"];
            NSString *body = [INQUtils cleanHtml:html];
    
            if ([body length] == 0) {
                return self.tableView.rowHeight;
            }

            float tw = tableView.frame.size.width - 5*8.0f;
  
            NSDictionary *attr = @{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] };
            CGRect rect = [body boundingRectWithSize:CGSizeMake(tw, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil];

            // Correct for top/bottom margins (58.0f is the designed height of the UITextView).
            return 1.0f * tableView.rowHeight + rect.size.height + 3*8.0f - 58.0f;
            // return 1.0f*tableView.rowHeight + MIN((rect.size.height) + 2*8.0f, 64.0f) - 58.0f;
        }
    }
    
    // Error
    return tableView.rowHeight;
}

@end
