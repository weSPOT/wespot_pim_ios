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

/*!
 *  See SDK.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES];
}

/*!
 *  See SDK.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

@end
