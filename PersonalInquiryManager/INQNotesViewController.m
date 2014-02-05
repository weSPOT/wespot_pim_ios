//
//  INQNotesViewController.m
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "INQNotesViewController.h"

@interface INQNotesViewController ()

@end

@implementation INQNotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadNotesFromWeb];
}

- (void) loadNotesFromWeb {
    NSDictionary *notesDict = [ARLNetwork getNotes:self.inquiryId];
    if (notesDict) {
        id result = [notesDict objectForKey:@"result"];
        if (result && ([result count] != 0)) {
            NSDictionary * noteDict = [result firstObject];
            self.title = [noteDict objectForKey:@"title"];
            
            UIWebView *web = (UIWebView*) self.view;
            
            [web loadHTMLString:[noteDict objectForKey:@"description"]  baseURL:nil];
        }
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
