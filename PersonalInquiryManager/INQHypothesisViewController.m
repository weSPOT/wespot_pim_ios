//
//  INQHypothesisViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQHypothesisViewController.h"

@interface INQHypothesisViewController ()

@end

@implementation INQHypothesisViewController

- (void) setHypothesis:(NSString*) hypothesis {
    if (_hypothesis != hypothesis){
        _hypothesis = hypothesis;
    }
    
    // NSLog(@"[%s] Loading %@", __func__, self.hypothesis);
    
    UIWebView *web = (UIWebView*) self.view;
    
    [web loadHTMLString:self.hypothesis  baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    // Add swipeGestures
    //    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
    //                                                     initWithTarget:self
    //                                                     action:@selector(oneFingerSwipeLeft:)];
    //    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    //    [self.view addGestureRecognizer:oneFingerSwipeLeft];
    //
    //    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
    //                                                      initWithTarget:self
    //                                                      action:@selector(oneFingerSwipeRight:)];
    //    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    //    [self.view addGestureRecognizer:oneFingerSwipeRight];
}

/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

//- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
//    // Insert your own code to handle swipe left
//    
//    NSLog(@"Swipe Left");
//    
//    UIViewController *newViewController;
//    
//    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    [stackViewControllers removeLastObject];
//    
//    UIViewController *inquiryViewController = [stackViewControllers lastObject];
//    
//    if ([inquiryViewController respondsToSelector:@selector(nextPart)]) {
//        newViewController =  [inquiryViewController performSelector:@selector(nextPart)];
//    }
//    
//    if (newViewController) {
//        [stackViewControllers addObject:newViewController];
//        [self.navigationController setViewControllers:stackViewControllers animated:NO];
//    }
//}
//
//- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
//    // Insert your own code to handle swipe right
//
//    NSLog(@"Swipe Right");
//    
//    UIViewController *newViewController;
//    
//    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    [stackViewControllers removeLastObject];
//    
//    UIViewController *inquiryViewController = [stackViewControllers lastObject];
//    
//    if ([inquiryViewController respondsToSelector:@selector(prevPart)]) {
//        newViewController =  [inquiryViewController performSelector:@selector(prevPart)];
//    }
//    
//    if (newViewController) {
//        [stackViewControllers addObject:newViewController];
//        [self.navigationController setViewControllers:stackViewControllers animated:NO];
//    }
//}

@end
