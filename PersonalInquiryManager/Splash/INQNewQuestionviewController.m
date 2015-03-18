//
//  INQNewQuestionviewController.m
//  PersonalInquiryManager
//
//  Created by G.W. van der Vegt on 18/03/15.
//  Copyright (c) 2015 Stefaan Ternier. All rights reserved.
//

#import "INQNewQuestionviewController.h"

@interface INQNewQuestionviewController()

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *view;

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *addQuestionLabel;
@property (weak, nonatomic) IBOutlet UITextField *addQuestionField;
@property (weak, nonatomic) IBOutlet UILabel *additionalDetailsLabel;
@property (weak, nonatomic) IBOutlet UITextField *additionalDetailsField;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UITextField *tagsField;

@property (strong, nonatomic) UIBarButtonItem *createButton;

@end

@implementation INQNewQuestionviewController

/*!
 *  viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.addQuestionField.delegate = self;
    self.additionalDetailsField.delegate = self;
    self.tagsField.delegate = self;
    
    [self addConstraints];
}

- (void) viewWillAppear:(BOOL)animated  {
    // [self.navigationController setToolbarHidden:NO animated:NO];
    
    if (!self.createButton) {
        self.createButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleBordered target:self action:@selector(createTap:)];
    }
    
    self.navigationItem.rightBarButtonItem = self.createButton;
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
 *  Add constraints.
 */
- (void)addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.view,                     @"view",
                                     self.background,               @"background",
                                     self.addQuestionLabel,         @"addQuestionLabel",
                                     self.addQuestionField,         @"addQuestionField",
                                     self.additionalDetailsLabel,   @"additionalDetailsLabel",
                                     self.additionalDetailsField,   @"additionalDetailsField",
                                     self.tagsLabel,                @"tagsLabel",
                                     self.tagsField,                @"tagsField",
                                     nil];
    
    self.addQuestionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.addQuestionField.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.additionalDetailsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.additionalDetailsField.translatesAutoresizingMaskIntoConstraints = NO;

    self.tagsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagsField.translatesAutoresizingMaskIntoConstraints = NO;

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[addQuestionLabel]-[addQuestionField]-[additionalDetailsLabel]-[additionalDetailsField]-[tagsLabel]-[tagsField]",0 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.addQuestionField
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.additionalDetailsField
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];

    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.tagsField
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[addQuestionLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[addQuestionField]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[additionalDetailsLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[additionalDetailsField]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[tagsLabel]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Fix Widths
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[tagsField]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

/*!
 *  Create a new Question
 *
 *  @param sender The sender
 */
- (IBAction)createTap:(UIButton *)sender {
    // TODO
}

//- (void) createQuestion:(NSString *)title description:(NSString *)description
//{
//    //    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    //method=add.question&
//    //    name=Sample_Question_KSa_19.02.2014&
//    //    description=Question Description&
//    //    tags=my Question Tags&
//    //    container_guid=27568&
//    //    provider=Google &user_uid=XXXXXXXXXXXXXXXXXXXXXX&
//    //    api_key=YOUR_API_KEY
//    
//    NSDictionary *result = [ARLNetwork addQuestionWithDictionary:title
//                                                     description:description
//                                                       inquiryId:self.inquiryId];
//    
//    //    [Message messageWithDictionary:result
//    //            inManagedObjectContext:appDelegate.managedObjectContext];
//    //
//    //    [INQLog SaveNLog:appDelegate.managedObjectContext];
//    //    
//    DLog(@"%@", result);
//}

@end
