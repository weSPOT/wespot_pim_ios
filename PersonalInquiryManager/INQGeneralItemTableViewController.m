//
//  INQGeneralItemTableViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQGeneralItemTableViewController.h"

@interface INQGeneralItemTableViewController ()

@end

@implementation INQGeneralItemTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add swipeGestures
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:oneFingerSwipeRight];
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

/*!
 *  Return the number of Rows in a Section.
 *
 *  @param tableView The Table to be served.
 *  @param section   The section of the data.
 *
 *  @return The number of Rows in the requested section.
 */
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [super numberOfRowsInSection:section];
//}

/*!
 *  The number of sections in a Table.
 *
 *  @param tableView The Table to be served.
 *
 *  @return The number of sections.
 */
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 1;
//}

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
    // Fetch Data from CoreData
    GeneralItem *generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;

    // Dequeue a TableCell and intialize if nececsary.
    // Id = org.celstec.arlearn2.beans.generalItem.NarratorItem
    ARLGeneralItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:generalItem.type];
    if (cell == nil) {
        cell = [[ARLGeneralItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:generalItem.type];
    }
    
    // Add correct content to the Table Cell.
    cell.giTitleLabel.text = generalItem.name;
    
    // Set Font to Bold if unread.
    cell.giTitleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    
    [self setDCIcon:cell withGi:generalItem];

    // If Read set Font to normal.
    for (Action * action in generalItem.actions) {
        if (action.run == self.run) {
            if ([action.action isEqualToString:@"read"]) {
                cell.giTitleLabel.font = [UIFont systemFontOfSize:16.0f];
            }
        }
    }
    
    // cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
    
    return cell;
}

/*!
 *  Customize Cells to match the Action retrieved.
 *
 *  @param cell      The TableCell to customize.
 *  @param indexPath The IndexPath of the TableCell.
 */
-(void) configureCell: (ARLGeneralItemTableViewCell *) cell atIndexPath:(NSIndexPath *)indexPath {
    GeneralItem * generalItem = ((CurrentItemVisibility*)[self.fetchedResultsController objectAtIndexPath:indexPath]).item;
    
    cell.giTitleLabel.text = generalItem.name;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"vis statements %d", [generalItem.visibility count] ];
    cell.icon.image = [UIImage imageNamed:@"dc_calculator_128.png"];
}

/*!
 *  Set the Correct Icon for the Action retrieved.
 *
 *  @param cell      The TableCell to customize.
 *  @param generalItem The GeneralItem cell content.
 */
- (void) setDCIcon: (ARLGeneralItemTableViewCell *) cell withGi: (GeneralItem *) generalItem {
        NSDictionary * jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:generalItem.json];
    
    NSLog(@"[%s] log %@", __func__, [jsonDict objectForKey:@"openQuestion"]);
    
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withAudio"] intValue] == 1) {
            cell.icon.image = [UIImage imageNamed:@"dc_voice_search_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withPicture"] intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_camera_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withText"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_note_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withValue"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_calculator_128.png"];
    }
    if ([[[jsonDict objectForKey:@"openQuestion"] objectForKey:@"withVideo"]intValue] == 1) {
        cell.icon.image = [UIImage imageNamed:@"dc_video_128.png"];
    }
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle swipe left
    
    NSLog(@"Swipe Left");
    
    UIViewController *newViewController;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    if ([inquiryViewController respondsToSelector:@selector(nextPart)]) {
        newViewController =  [inquiryViewController performSelector:@selector(nextPart)];
    }
    
    if (newViewController) {
        [stackViewControllers addObject:newViewController];
        [self.navigationController setViewControllers:stackViewControllers animated:YES];
    }
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle swipe right
    
    NSLog(@"Swipe Right");
    
    UIViewController *newViewController;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    if ([inquiryViewController respondsToSelector:@selector(prevPart)]) {
        newViewController =  [inquiryViewController performSelector:@selector(prevPart)];
    }
    
    if (newViewController) {
        [stackViewControllers addObject:newViewController];
        [self.navigationController setViewControllers:stackViewControllers animated:NO];
        
//        [UIView animateWithDuration:2.75
//                         animations:^{
//                             NSLog(@"BINGO1");
//                             //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//                             [self.navigationController setViewControllers:stackViewControllers animated:NO];
//                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:newViewController.view cache:NO];
//                             NSLog(@"BINGO2");
//                         }];
    }
}

@end
