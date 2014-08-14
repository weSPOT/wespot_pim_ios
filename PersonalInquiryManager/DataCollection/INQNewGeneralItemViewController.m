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
@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *typeSegments;

@property (strong, nonatomic) UIBarButtonItem *spacerButton;
@property (strong, nonatomic) UIBarButtonItem *createButton;

- (IBAction)createTap:(UIButton *)sender;

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

- (void) viewWillAppear:(BOOL)animated  {
    [self.navigationController setToolbarHidden:NO animated:NO];
    
    if (!self.spacerButton) {
        self.spacerButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.createButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleBordered target:self action:@selector(createTap:)];
    }
    
    self.toolbarItems = [NSArray arrayWithObjects:self.spacerButton, self.createButton,nil];
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
- (void) createGeneralItem:(NSString *)title
               description:(NSString *)description
               withPicture:(BOOL)withPicture
                 withVideo:(BOOL)withVideo
                 withAudio:(BOOL)withAudio
                  withText:(BOOL)withText
                 withValue:(BOOL)withValue {
    
    ARLAppDelegate *appDelegate = (ARLAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSDictionary *result = [ARLNetwork createGeneralItem:title
                                             description:description
                                             withPicture:withPicture
                                               withVideo:withVideo
                                               withAudio:withAudio
                                                withText:withText
                                               withValue:withValue
                                                  gameId:self.run.gameId];
    
    Game *game = [Game retrieveGame:[result objectForKey:@"gameId"] inManagedObjectContext:appDelegate.managedObjectContext];
    
    [GeneralItem generalItemWithDictionary:result withGame:game inManagedObjectContext:appDelegate.managedObjectContext];
    
    if (appDelegate.managedObjectContext.hasChanges) {
        NSError *error = nil;
        [appDelegate.managedObjectContext save:&error];
    }
    
    // Log(@"%@", result);
}

/*!
 *  Create a new GeneralItem
 *
 *  @param sender The sender
 */
- (IBAction)createTap:(UIButton *)sender {
    if ([self.titleEdit.text length]>0) {
        
        //see https://github.com/yonat/MultiSelectSegmentedControl/blob/master/MultiSelectSegmentedControl.m
        
        [self createGeneralItem:self.titleEdit.text
                    description:self.descriptionEdit.text
                    withPicture:[self.typeSegments.selectedSegmentIndexes containsIndex:0]
                      withVideo:[self.typeSegments.selectedSegmentIndexes containsIndex:1]
                      withAudio:[self.typeSegments.selectedSegmentIndexes containsIndex:2]
                       withText:[self.typeSegments.selectedSegmentIndexes containsIndex:3]
                      withValue:[self.typeSegments.selectedSegmentIndexes containsIndex:4]
         ];
        
        //[self createGeneralItem:self.titleEdit.text
        //            description:self.descriptionEdit.text
        //            withPicture:self.typeSegments.selectedSegmentIndex==0
        //              withVideo:self.typeSegments.selectedSegmentIndex==1
        //              withAudio:self.typeSegments.selectedSegmentIndex==2
        //               withText:self.typeSegments.selectedSegmentIndex==3
        //              withValue: self.typeSegments.selectedSegmentIndex==4];
        
        if (ARLNetwork.networkAvailable) {
            [ARLCloudSynchronizer syncVisibilityForInquiry:self.run.managedObjectContext run:self.run];
        }
        
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
                                     nil];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionEdit.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeSegments.translatesAutoresizingMaskIntoConstraints = NO;

    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[titleLabel]-[titleEdit]-[descriptionLabel]-[descriptionEdit]-[typeLabel]-[typeSegments]",0 + self.navbarHeight]
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

    
}

@end
