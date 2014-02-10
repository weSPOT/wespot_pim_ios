//
//  INQInquiryPageViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQInquiryPageViewController.h"

#import "INQGeneralItemTableViewController.h"

@interface INQInquiryPageViewController ()

@end

@implementation INQInquiryPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    NSLog(@"[%s] inquiry is %@", __func__, self.inquiry.inquiryId);
    
    ARLAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [ARLCloudSynchronizer syncGamesAndRuns:appDelegate.managedObjectContext];
    
    [self createDataCollection];
    //[self createWebView];
    //[self createHypothesisView];
    //[self setConstraints];
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
    Run* selectedRun = [Run retrieveRun:runId inManagedObjectContext:self.inquiry.managedObjectContext];
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

@end
