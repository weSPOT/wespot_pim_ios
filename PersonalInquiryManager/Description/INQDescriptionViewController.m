//
//  ARLDescriptionViewController.m
//  PersonalInquiryManager
//
//  Created by G.W. van der Vegt on 18/02/15.
//  Copyright (c) 2015 Stefaan Ternier. All rights reserved.
//

#import "INQDescriptionViewController.h"

@interface INQDescriptionViewController ()

@end

@implementation INQDescriptionViewController

@synthesize Description  = _Description;

- (void) setDescription:(NSString *) description {
    if (_Description != description){
        _Description = description;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIWebView *web = (UIWebView*) self.view;
    
    web.scrollView.contentInset = UIEdgeInsetsMake(self.navbarHeight + self.statusbarHeight, 0.0, 0.0, 0.0);
    
    web.backgroundColor = [UIColor whiteColor];
    web.delegate = self;
    
    if ([self.Description length] ==0) {
        [web loadHTMLString:@"No description has been added yet for this inquiry." baseURL:[[NSBundle mainBundle] bundleURL]];
    }else {
        [web loadHTMLString:self.Description baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}


/*!
 *  Low Memory Warning.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
