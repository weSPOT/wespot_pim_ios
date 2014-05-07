//
//  PageContentViewController.m
//  PageViewDemo
//
//  Created by Simon on 24/11/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "INQSplashContentViewController.h"

@interface INQSplashContentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *carouselImage;
@property (weak, nonatomic) IBOutlet UILabel *carouselTitle;

@end

@implementation INQSplashContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.titleLabel.text = self.titleText;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addConstraints];
}

-(void)viewDidDisappear:(BOOL)animated {
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void) addConstraints {
    @autoreleasepool {
        NSDictionary *viewsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         self.backgroundImage,      @"background",
                                         self.carouselImage,        @"carousel",
                                         self.carouselTitle,        @"title",
                                         nil];
        
        self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.carouselImage.translatesAutoresizingMaskIntoConstraints = NO;
        self.carouselTitle.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        // Carousel
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat: @"V:|-60-[title]-[carousel(==320)]"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat: @"H:[carousel(==200)]"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.carouselImage
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                  constant:0]];
        
        [self.view addConstraints:[NSLayoutConstraint
                                   constraintsWithVisualFormat: @"H:[title(==400)]"
                                   options:NSLayoutFormatDirectionLeadingToTrailing
                                   metrics:nil
                                   views:viewsDictionary]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.carouselTitle
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1
                                  constant:0]];
    }
}

@end
