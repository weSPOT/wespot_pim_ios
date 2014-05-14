//
//  INQNewInquiryViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 4/2/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQNewInquiryViewController.h"

@interface INQNewInquiryViewController ()

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *view;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleEdit;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionEdit;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *visibilitySegments;
@property (weak, nonatomic) IBOutlet UISegmentedControl *membershipSegments;
@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *membershipLabel;

- (IBAction)createInquiryTap:(id)sender;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation INQNewInquiryViewController

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleEdit.delegate = self;
    self.descriptionEdit.delegate = self;
    
    self.visibilitySegments.apportionsSegmentWidthsByContent = YES;
    self.membershipSegments.apportionsSegmentWidthsByContent = NO;
    
    self.visibilitySegments.selectedSegmentIndex = [ARLNetwork defaultInquiryVisibility];
    self.membershipSegments.selectedSegmentIndex = [ARLNetwork defaultInquiryMembership];
    
    [self addConstraints];
}

/*!
 *  didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/*!
 *  Create an new Inquiry.
 *
 *  @param title       <#title description#>
 *  @param description <#description description#>
 */
- (void) createInquiry:(NSString *)title description:(NSString *)description {
    NSString *html = [[NSString alloc] initWithFormat:@"<p>%@</p>", description];
   
    NSNumber *visibility =  [NSNumber numberWithInt:self.visibilitySegments.selectedSegmentIndex];
    NSNumber *membership = [NSNumber numberWithInt:2 *self.membershipSegments.selectedSegmentIndex];
    
    NSDictionary *dict = [ARLNetwork createInquiry:title description:html visibility:visibility membership:membership];
    
    if (dict) {
        NSLog(@"[%s]\r\nresult=%@,\r\nstatus=%@", __func__, [dict objectForKey:@"html"], [dict objectForKey:@"status"]);
        
        if ([[dict objectForKey:@"status"] intValue] == 0) {
            ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            // Sync will return our new Inquiry and it's Run.
            if (ARLNetwork.networkAvailable) {
                [INQCloudSynchronizer syncInquiries:appDelegate.managedObjectContext];
            }
        } else {
            //{
            //    message = "No user with corresponding credentials found: Google_101754523769925754305";
            //    status = "-1";
            //}
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[[NSString alloc]
                                                                     initWithFormat:@"%@",
                                                                     [dict objectForKey:@"result"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

/*!
 *  Add constraints.
 */
- (void)addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,                 @"view",
                                     self.background,           @"background",
                                     self.titleLabel,           @"titleLabel",
                                     self.titleEdit,            @"titleEdit",
                                     self.descriptionLabel,     @"descriptionLabel",
                                     self.descriptionEdit,      @"descriptionEdit",
                                     self.visibilityLabel,      @"visibilityLabel",
                                     self.visibilitySegments,   @"visibilitySegments",
                                     self.membershipLabel,      @"membershipLabel",
                                     self.membershipSegments,   @"memberhipSegments",
                                     self.createButton,         @"createButton",
                                     nil];
    
    // Fails
    // for (UIView *view in [viewsDictionary keyEnumerator]) {
    //   view.translatesAutoresizingMaskIntoConstraints = NO;
    // }
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.createButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.background.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.visibilitySegments.translatesAutoresizingMaskIntoConstraints = NO;
    self.membershipSegments.translatesAutoresizingMaskIntoConstraints = NO;

    self.visibilityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.membershipLabel.translatesAutoresizingMaskIntoConstraints = NO;

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[titleLabel]-[titleEdit]-[descriptionLabel]-[descriptionEdit(==80)]-[visibilityLabel]-[visibilitySegments]-[membershipLabel]-[memberhipSegments]-[createButton]",0 + self.navbarHeight]
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
                              constraintWithItem:self.createButton
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.visibilitySegments
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.membershipSegments
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[titleEdit]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[descriptionEdit]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[createButton(==200)]"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[visibilitySegments]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[memberhipSegments]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[descriptionLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[visibilityLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[membershipLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Background
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"V:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: @"H:|[background]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

- (IBAction)createInquiryTap:(id)sender {
    if ([self.titleEdit.text length]>0 && [self.descriptionEdit.text length]>0) {
        [self createInquiry:self.titleEdit.text description:self.descriptionEdit.text];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(CGFloat) statusbarHeight
{
    // NOTE: Not always turned yet when we try to retrieve the height.
    return MIN([UIApplication sharedApplication].statusBarFrame.size.height, [UIApplication sharedApplication].statusBarFrame.size.width);
}

-(CGFloat) navbarHeight {
    return self.navigationController.navigationBar.bounds.size.height;
}

-(CGFloat) tabbarHeight {
    return self.tabBarController.tabBar.bounds.size.height;
}

-(UIInterfaceOrientation) interfaceOrientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
