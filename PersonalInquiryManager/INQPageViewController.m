//
//  APPViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "INQPageViewController.h"

@interface INQPageViewController ()

@end

@implementation INQPageViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    UIViewController *newViewController;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    if ([inquiryViewController respondsToSelector:@selector(CreateInquiryPartViewController:)]) {
        newViewController =  [inquiryViewController performSelector:@selector(CreateInquiryPartViewController:) withObject:[NSNumber numberWithUnsignedInteger:index]];
    }

//    APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:@"APPChildViewController" bundle:nil];
   // childViewController.index = index;
    
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
    
    // NSUInteger index = [(APPChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    
    NSLog(@"[%s] Showing Page: %d",__func__, index);
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = 0;
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    
    UIViewController *inquiryViewController = [stackViewControllers lastObject];
    
    if ([inquiryViewController respondsToSelector:@selector(currentPart)]) {
        index  = [(NSNumber *)[inquiryViewController performSelector:@selector(currentPart)] intValue];
    }
    
    // NSUInteger index = [(APPChildViewController *)viewController index];
    
    index++;
    
    if (index == 6) {
        return nil;
    }
    
    NSLog(@"[%s] Showing Page: %d",__func__, index);
    
    return [self viewControllerAtIndex:index];
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
