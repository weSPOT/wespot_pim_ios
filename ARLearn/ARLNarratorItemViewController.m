//
//  ARLNarratorItemViewController.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/18/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLNarratorItemViewController.h"

@interface ARLNarratorItemViewController ()

@property (readonly, nonatomic) CGFloat statusbarHeight;
@property (readonly, nonatomic) CGFloat navbarHeight;
@property (readonly, nonatomic) CGFloat tabbarHeight;
@property (readonly, nonatomic) UIInterfaceOrientation interfaceOrientation;

@property (strong, nonatomic)  UIWebView *webView;
@property (strong, nonatomic)  ARLDataCollectionWidget* dataCollectionWidget;

@end

@implementation ARLNarratorItemViewController

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

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *jsonDict = [NSKeyedUnarchiver unarchiveObjectWithData:self.generalItem.json];
    
    //self.headerText.title = self.generalItem.name;
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor orangeColor];
    
    self.dataCollectionWidget = [[ARLDataCollectionWidget alloc] init:[jsonDict objectForKey:@"openQuestion"] viewController:self];
    if (self.dataCollectionWidget.isVisible) {
        self.dataCollectionWidget.run = self.run;
        self.dataCollectionWidget.generalItem = self.generalItem;
    }
    self.dataCollectionWidget.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.dataCollectionWidget];
    
    [self.webView loadHTMLString:self.generalItem.richText baseURL:nil];

    [self setConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.generalItem.managedObjectContext];
}

- (void)handleDataModelChange:(NSNotification *)note
{
    NSSet *updatedObjects = [[note userInfo] objectForKey:NSUpdatedObjectsKey];
    NSSet *deletedObjects = [[note userInfo] objectForKey:NSDeletedObjectsKey];
    
    for(NSManagedObject *obj in updatedObjects){
        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
            GeneralItem* changedObject = (GeneralItem*) obj;
            if (self.generalItem == changedObject) {
                self.navigationItem.title = self.generalItem.name;
                
                NSLog(@"[%s] TEXT='%@'",__func__, self.generalItem.richText);
                
                [self.webView loadHTMLString:self.generalItem.richText baseURL:nil];
            }
        }
    }

    for(NSManagedObject *obj in deletedObjects){
        if ([[obj entity].name isEqualToString:@"GeneralItem"]) {
            GeneralItem* changedObject = (GeneralItem*) obj;
            if (self.generalItem == changedObject) {
                NSLog(@"little less easy... I was deleted");

                [self.navigationController popViewControllerAnimated:NO];
                [self dismissViewControllerAnimated:TRUE completion:nil];
            }
        }
    }
}

- (void) setConstraints {
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dataCollectionWidget.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
        self.webView, @"webView",
        self.dataCollectionWidget, @"widget",
        nil];
 
    NSString* verticalContstraint;
    if (self.dataCollectionWidget.isVisible) {
        verticalContstraint = @"V:|-%@-[webView(>=100)]-[widget(==80)]-%@-|";
        
    } else {
        verticalContstraint = @"V:|-%@-[webView(>=100)]-%@-|";
    }

    verticalContstraint = [NSString stringWithFormat:verticalContstraint,
                                [NSNumber numberWithInteger:self.navbarHeight+self.statusbarHeight+8],
                                [NSNumber numberWithInteger:self.tabbarHeight+8]];
    
    [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:verticalContstraint
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
  
    [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[webView]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat:@"H:|-[widget]-|"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
}

@end
