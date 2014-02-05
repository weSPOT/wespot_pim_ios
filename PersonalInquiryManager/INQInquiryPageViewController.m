//
//  INQInquiryPageViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQInquiryPageViewController.h"

@interface INQInquiryPageViewController ()

@end

@implementation INQInquiryPageViewController

@synthesize inquiry;
@synthesize showDataCollection;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    NSLog(@"[%s] inquiry is %@", __func__, self.inquiry.inquiryId);
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [ARLCloudSynchronizer syncGamesAndRuns:appDelegate.managedObjectContext];
    
    [self createDataCollection];
    [self createWebView];
    [self createHypothesisView];
    [self setConstraints];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"[%s] preparing for segue %@", __func__, self.inquiry.inquiryId);
    
    NSNumber * runId = [ARLNetwork getARLearnRunId:self.inquiry.inquiryId];
    Run* selectedRun =[Run retrieveRun:runId inManagedObjectContext:self.inquiry.managedObjectContext];
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [synchronizer createContext:appDelegate.managedObjectContext];
    synchronizer.gameId = selectedRun.gameId;
    synchronizer.visibilityRunId = selectedRun.runId;
    [synchronizer sync];
    if ([segue.destinationViewController respondsToSelector:@selector(setRun:)]) {
        [segue.destinationViewController performSelector:@selector(setRun:) withObject:selectedRun];
    }
}

- (void) createWebView {
    UIWebView* webViewLocal = [[UIWebView alloc] init];
    self.webView = webViewLocal;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView loadHTMLString:self.inquiry.desc baseURL:nil];
    [self.view addSubview:self.webView];
}

- (void) createHypothesisView {
    if (!self.inquiry.hypothesis) {
        self.inquiry.hypothesis = @"test";
    }
    UIWebView* hypothesisViewLocal = [[UIWebView alloc] init];
    self.hypothesisView = hypothesisViewLocal;
    self.hypothesisView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView loadHTMLString:self.inquiry.hypothesis baseURL:nil];
    [self.view addSubview:self.hypothesisView];
}

- (void) createDataCollection {
    UIButton * showDataCollectionLocal = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.showDataCollection = showDataCollectionLocal;
    [self.showDataCollection setTitle:@"Data Collection Tasks" forState:UIControlStateNormal];
    
    self.showDataCollection.translatesAutoresizingMaskIntoConstraints = NO;
    [self.showDataCollection addTarget:self action:@selector(dataCollectionClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.showDataCollection];
}

- (void) dataCollectionClicked {
    INQGeneralItemTableViewController *dataCollectionTasks = [self.storyboard instantiateViewControllerWithIdentifier:@"dataCollectionTasks"];

    NSNumber * runId = [ARLNetwork getARLearnRunId:self.inquiry.inquiryId];
    Run* selectedRun =[Run retrieveRun:runId inManagedObjectContext:self.inquiry.managedObjectContext];

    [dataCollectionTasks performSelector:@selector(setRun:) withObject:selectedRun];
    
    ARLCloudSynchronizer* synchronizer = [[ARLCloudSynchronizer alloc] init];
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [synchronizer createContext:appDelegate.managedObjectContext];
    synchronizer.gameId = selectedRun.gameId;
    synchronizer.visibilityRunId = selectedRun.runId;
    [synchronizer sync];

    [self.navigationController pushViewController:dataCollectionTasks animated:YES];
}

- (void) setConstraints {
    NSDictionary *viewsDictionary =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     self.showDataCollection, @"showDataCollection",
     self.webView, @"webView",
     self.hypothesisView, @"hypothesisView",
     nil];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-[webView]-[hypothesisView]-[showDataCollection]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[webView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[hypothesisView]|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[showDataCollection]-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
}

@end
