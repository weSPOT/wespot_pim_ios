//
//  IMViewController.m
//  InqueryManager
//
//  Created by Wim van der Vegt on 1/30/14.
//  Copyright (c) 2014 Open University of the Netherlands. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INQSplashImageViewController.h"

@interface INQSplashImageViewController ()

@end

@implementation INQSplashImageViewController

#pragma - mark system

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // see http://stackoverflow.com/questions/4980610/implementing-a-splash-screen-in-ios
    //     	http://stackoverflow.com/questions/8303155/adding-splashscreen-to-iphone-app-in-appdelegate
    UIImage *splash = [UIImage imageNamed:@"arlearn_logo.png"];

    UIImageView *imageViewFade=[[UIImageView alloc]initWithImage:splash];
    UIImageView *imageViewBack=[[UIImageView alloc]initWithImage:splash];

    [self.view insertSubview:imageViewBack atIndex: 0];

    [self.view addSubview:imageViewFade];
    [self.view bringSubviewToFront:imageViewFade];

    // Now fade out splash image
    [UIView transitionWithView:self.view duration:5.0f options:UIViewAnimationOptionTransitionNone
        animations:^(void) {
            imageViewFade.alpha=0.0f;
        }
        completion:^(BOOL finished) {
            [imageViewFade removeFromSuperview];
          
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabs"];
                
                if (newViewController) {
                    // Move to another UINavigationController or UITabBarController etc.
                    // See http://stackoverflow.com/questions/14746407/presentmodalviewcontroller-in-ios6
                    [self.navigationController presentViewController:newViewController animated:YES  completion:nil];
                }
            });
       }];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.navigationController.navigationBar.hidden = YES;
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
