//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "INQPageViewController.h"

@interface INQPageViewController ()

#error TODO Correct Initial Number in PageControl (self.currentPageIndex and PageViewController are not in sync).
#error TODO Cannot scroll backwards property starting from the last page..

@end

@implementation INQPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSLog(@"[%s] %@", __func__, self.currentPageIndex);
    
    self.dataSource = self;
    UIViewController *initialViewController = [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


- (void)initWithInitialPage:(NSNumber *)index {
    NSLog(@"[%s] %@", __func__, index);
    
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
    }
    
    return newViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = 0;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
 
    if ([inquiryViewController respondsToSelector:@selector(currentPart)]) {
         index  = [(NSNumber *)[inquiryViewController performSelector:@selector(currentPart)] intValue];
    }
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] - 1];

    NSLog(@"[%s] Showing Page: %d",__func__, index);
    
    return [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    // Increase the index by 1 to return
    self.currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.currentPageIndex unsignedIntValue] + 1];
    
    if ([self.currentPageIndex isEqualToNumber: [NSNumber numberWithUnsignedInteger:6]]) {
        return nil;
    }
    
    NSLog(@"[%s] Showing Page: %@",__func__, self.currentPageIndex );
    
    return [self viewControllerAtIndex:[self.currentPageIndex unsignedIntValue]];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 6;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

@end
