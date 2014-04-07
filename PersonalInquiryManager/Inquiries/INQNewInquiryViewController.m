//
//  INQNewInquiryViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 4/2/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQNewInquiryViewController.h"

@interface INQNewInquiryViewController ()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleEdit;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionEdit;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

- (IBAction)createInquiryTap:(id)sender;

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@end

@implementation INQNewInquiryViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.titleEdit.delegate = self;
    self.descriptionEdit.delegate = self;
//    self.descriptionEdit
    [self addConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createInquiry:(NSString *)title description:(NSString *)description {
    NSString *html = [[NSString alloc] initWithFormat:@"<p>%@</p>", description];
    
    //    NSString *encodedString = [html
    //                                stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    //
    //    NSLog(@"[%s] %@", __func__, encodedString);
    
    // Create game, POST /rest/myGames
    //    {
    //        "type": "org.celstec.arlearn2.beans.game.Game",
    //        "title": "test",
    //        "config": {
    //            "type": "org.celstec.arlearn2.beans.game.Config",
    //            "mapAvailable": false,
    //            "manualItems": [],
    //            "locationUpdates": []
    //        }
    //    }
    
//    NSDictionary *gdict = [ARLNetwork createGame:title];
    
    // returns:
    //    {
    //        config =     {
    //            locationUpdates =         (
    //            );
    //            manualItems =         (
    //            );
    //            mapAvailable = 0;
    //            type = "org.celstec.arlearn2.beans.game.Config";
    //        };
    //        gameId = 4979573540257792;
    //        title = "game creation test";
    //        type = "org.celstec.arlearn2.beans.game.Game";
    //    }
    //
    //NSLog(@"[%s] %@", __func__, gdict);
    
//    NSDictionary *rdict = [ARLNetwork createRun:[gdict objectForKey:@"gameId"] withTitle:title];
//    
//    NSLog(@"[%s] %@", __func__, rdict);
    
    // returns:
//    {
//        deleted = 0;
//        gameId = 1342177280;
//        runId = 4999734116745216;
//        serverCreationTime = 1396860191783;
//        startTime = 1396860191783;
//        title = test;
//        type = "org.celstec.arlearn2.beans.run.Run";
//    }
//
//    NSNumber *gameId = [gdict objectForKey:@"gameId"];
//    NSNumber *runId = [rdict objectForKey:@"runId"];
    
    // Create run /reset/myRuns
    //    {
    //        "type": "org.celstec.arlearn2.beans.run.Run",
    //        "gameId": 1,
    //        "title": "my run"
    //    }
  
    NSDictionary *dict = [ARLNetwork createInquiry:title description:html];
    
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

- (void)addConstraints {
    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     self.titleLabel,           @"titleLabel",
                                     self.titleEdit,            @"titleEdit",
                                     self.descriptionLabel,     @"descriptionLabel",
                                     self.descriptionEdit,      @"descriptionEdit",
                                     self.createButton,         @"createButton",
                                     self.view,                 @"view",
                                     self.scrollView,           @"scroll",
                                     self.background,           @"background",
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
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.background.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Size UIScrollView to View.
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeWidth
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeHeight
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0
                               constant:0]];
    [self.view addConstraint: [NSLayoutConstraint
                               constraintWithItem:self.scrollView
                               attribute:NSLayoutAttributeLeft
                               relatedBy:NSLayoutRelationEqual
                               toItem:self.view
                               attribute:NSLayoutAttributeLeft
                               multiplier:1.0
                               constant:0]];
    
    // TODO
    // Order vertically
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat: [NSString stringWithFormat:@"V:|-%f-[titleLabel]-[titleEdit]-[descriptionLabel]-[descriptionEdit(100)]-[createButton]",40 + self.navbarHeight]
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    // Align around vertical center.
    // see http://stackoverflow.com/questions/20020592/centering-view-with-visual-format-nslayoutconstraints?rq=1
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.titleEdit
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1
                              constant:0]];
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