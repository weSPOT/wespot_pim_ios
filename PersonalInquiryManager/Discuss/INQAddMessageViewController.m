//
//  INQAddMessageViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 4/16/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQAddMessageViewController.h"

@interface INQAddMessageViewController ()

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *view;
@property (weak, nonatomic) IBOutlet UIImageView *background;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionEdit;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation INQAddMessageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.descriptionEdit.delegate = self;

    [self addConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createDefaultThreadMessage:(NSString *)title description:(NSString *)description {
    NSString *html = [NSString stringWithFormat:@"<p>%@</p>", description];
    
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Inquiry *inquiry = [Inquiry retrieveFromDbWithInquiryId:self.inquiryId withManagedContext:appDelegate.managedObjectContext];

    NSNumber *threadId = [[ARLNetwork defaultThread:inquiry.run.runId] objectForKey:@"threadId"];
    
    NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:
                             inquiry.run.runId,     @"runId",
                             threadId,              @"threadId",
                             title,                 @"subject",
                             html,                  @"body",
                             nil];
    
    NSDictionary *result= [ARLNetwork addMessage:[ARLAppDelegate jsonString:message]];

    DLog(@"%@", result);
}

- (void)addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.descriptionLabel,     @"descriptionLabel",
                                     self.descriptionEdit,      @"descriptionEdit",
                                     self.createButton,         @"createButton",
                                     self.view,                 @"view",
                                     self.background,           @"background",
                                     nil];
    
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.createButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.background.translatesAutoresizingMaskIntoConstraints = NO;

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[descriptionLabel]-[descriptionEdit(100)]-[createButton]",0 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.descriptionLabel
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
    
    // Fix Widths
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
    if ([self.descriptionEdit.text length]>0) {
        [self createDefaultThreadMessage:NSLocalizedString(@"Reply", @"Reply") description:self.descriptionEdit.text];
        
        if (ARLNetwork.networkAvailable) {
            ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [INQCloudSynchronizer syncMessages:appDelegate.managedObjectContext inquiryId:self.inquiryId];
        }
        
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
