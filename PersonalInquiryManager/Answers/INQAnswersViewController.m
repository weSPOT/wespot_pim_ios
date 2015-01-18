//
//  INQQuestionViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/21/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQAnswersViewController.h"

@interface INQAnswersViewController ()
/*!
 *  ID's and order of the cells.
 */
typedef NS_ENUM(NSInteger, indices) {
    /*!
     *  Answer.
     */
    ANSWER = 0,

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
     *  Answers
     */
    ANSWERS =0,
 
    /*!
     *  Number of Sections in this NS_ENUM.
     */
    numSections
};

@property (readonly, nonatomic) NSString *cellIdentifier;

@end

@implementation INQAnswersViewController

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
    
    [self.navigationController setToolbarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    if ([self.questions count]==0) {
//        self.textView.text = @"No question has been added yet for this inquiry.";
//    }else {
//        self.textView.text = [[self.questions objectAtIndex:0] valueForKey:@"question"];
//    }
    
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
        case ANSWERS:
            return self.Answers.count;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case ANSWERS:
            return @"Answers";
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
        case ANSWERS: {
            NSDictionary *answer = [self.Answers objectAtIndex:indexPath.row];
            
            cell.textLabel.text = [answer valueForKey:@"answer"];
            //cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            
            NSString *html = [answer valueForKey:@"description"];
            NSString *text = [INQUtils cleanHtml:html];
            cell.detailTextLabel.text = text;
            
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

@end
