//
//  INQNewGeneralItemViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQNewGeneralItemViewController.h"

@interface INQNewGeneralItemViewController ()

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *view;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleEdit;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextField *descriptionEdit;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegments;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

- (IBAction)createTap:(UIButton *)sender;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;

@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation INQNewGeneralItemViewController

@synthesize run = _run;

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleEdit.delegate = self;
    self.descriptionEdit.delegate = self;
    
    self.typeSegments.apportionsSegmentWidthsByContent = YES;
    
    self.typeSegments.selectedSegmentIndex = 0;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    {
        [self.typeSegments setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.typeSegments setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
        [self.typeSegments setTitleTextAttributes:attributes forState:UIControlStateSelected];
    }
    
    [self addConstraints];
}

/*!
 *  See SDK.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  Create an new GeneralItem.
 *
 *  @param title       The title
 *  @param description The description
 */
- (void) createGeneralItem:(NSString *)title description:(NSString *)description type:(NSNumber *)itemType {
    NSDictionary *result = [ARLNetwork createGeneralItem:title description:description type:itemType gameId:self.run.gameId];
    
    NSLog(@"[%s] %@", __func__, result);
}

/*!
 *  Create a new GeneralItem
 *
 *  @param sender The sender
 */
- (IBAction)createTap:(UIButton *)sender {
    if ([self.titleEdit.text length]>0) {
        [self createGeneralItem:self.titleEdit.text description:self.descriptionEdit.text type:[NSNumber numberWithInt:self.typeSegments.selectedSegmentIndex]];
        
        [ARLCloudSynchronizer syncVisibilityForInquiry:self.run.managedObjectContext run:self.run];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*!
 *  Add constraints.
 */
- (void)addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,                 @"view",
                                     self.titleLabel,           @"titleLabel",
                                     self.titleEdit,            @"titleEdit",
                                     self.descriptionLabel,     @"descriptionLabel",
                                     self.descriptionEdit,      @"descriptionEdit",
                                     self.typeLabel,            @"typeLabel",
                                     self.typeSegments,         @"typeSegments",
                                     self.createButton,         @"createButton",
                                     nil];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeSegments.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.createButton.translatesAutoresizingMaskIntoConstraints = NO;

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[titleLabel]-[titleEdit]-[descriptionLabel]-[descriptionEdit]-[typeLabel]-[typeSegments]-[createButton]",0 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.typeSegments
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.createButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[titleEdit]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
 
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[descriptionLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[descriptionEdit]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[typeLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[typeSegments]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[createButton(==200)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*!
 *  Getter
 *
 *  @return the Status Bar Height.
 */
-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

/*!
 *  Getter
 *
 *  @return the Nav Bar Height.
 */
-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

/*!
 *  Getter
 *
 *  @return the Tab Bar Height.
 */
-(CGFloat) tabbarHeight {
    return self.tabBarController.tabBar.bounds.size.height;
}

/*!
 *  getter
 *
 *  @return The Current Orientation.
 */
-(UIInterfaceOrientation) interfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
