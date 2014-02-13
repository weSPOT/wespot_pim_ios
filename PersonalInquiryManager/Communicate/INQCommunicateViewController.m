//
//  INQCommunicateViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQCommunicateViewController.h"

@interface INQCommunicateViewController ()

@end

@implementation INQCommunicateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    
//    // Add swipeGestures
//    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
//                                                    initWithTarget:self
//                                                    action:@selector(oneFingerSwipeLeft:)];
//    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [self.view addGestureRecognizer:oneFingerSwipeLeft];
//    
//    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
//                                                     initWithTarget:self
//                                                     action:@selector(oneFingerSwipeRight:)];
//    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
//    [self.view addGestureRecognizer:oneFingerSwipeRight];
}

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
