//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "INQPageViewController.h"

@interface INQPageViewController ()

//#warning TODO Correct Initial Number in PageControl (self.currentPageIndex and PageViewController are not in sync).
//#warning TODO Cannot scroll backwards property starting from the last page..

@end

@implementation INQPageViewController

#warning UIPageViewControl pages erratic when in scroll mode. Curl seems to be ok (but lacks the Page Control at the bottom).
- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = self;
}

-(void)viewDidAppear:(BOOL)animated {
    UIViewController *initialViewController = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self didMoveToParentViewController:self];
}

- (void)initWithInitialPage:(NSNumber *)index {
    self.currentPageIndex = index;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    UIViewController *newViewController;
    
    // Find the InqueryViewController as it hosts the code that creates the SubViews.
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    // Ask the InqueryViewController to create and initialize the requested ViewController.
    if ([inquiryViewController respondsToSelector:@selector(CreateInquiryPartViewController:)]) {
        
        newViewController =  [inquiryViewController performSelector:@selector(CreateInquiryPartViewController:) withObject:[NSNumber numberWithUnsignedInteger:index]];
//        NSLog(@"Fetching new viewcontroller %@", [newViewController class]);
//        NSLog(@"ViewControllers %d", self.viewControllers.count);
    }
    
    self.currentPageIndex = [NSNumber numberWithInteger:index];
    
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    if ([self.currentPageIndex isEqualToNumber: [NSNumber numberWithUnsignedInteger:0]]) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] - 1];

    NSLog(@"[%s] Showing Page: %@",__func__, self.currentPageIndex);
    
    UIViewController *view = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    
    return view;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // Increase the index by 1 to return
    
    if ([self.currentPageIndex isEqualToNumber: [NSNumber numberWithUnsignedInteger:5]]) {
        return nil;
    }
    
    self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] + 1];

    NSLog(@"[%s] Showing Page: %@",__func__, self.currentPageIndex);
    
    UIViewController *view = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    
    return view;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
   
    // The number of items reflected in the page indicator.
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
   
    // The selected item reflected in the page indicator.
    return [self.currentPageIndex unsignedIntValue];
}

-(void)setCurrentPageIndex:(NSNumber *)currentPageIndex
{
    _currentPageIndex= currentPageIndex;
}

@end
