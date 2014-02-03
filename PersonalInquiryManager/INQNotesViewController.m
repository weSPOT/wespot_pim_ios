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

@synthesize notesView;
@synthesize inquiryId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.notesView = [[UIWebView alloc] init];
    self.notesView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.notesView];
    
    [self.view removeConstraints:[self.view constraints]];
    
    NSDictionary * viewsDictionary =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     self.notesView, @"notesView", nil];
    
    NSString* verticalContstraint = @"V:|[notesView]|";
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:verticalContstraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    
    NSString* horizontalContstraint = @"H:|[notesView]|";
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:horizontalContstraint
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:viewsDictionary]];
    [self loadNotesFromWeb];
    
}

- (void) loadNotesFromWeb {
    NSDictionary *notesDict = [ARLNetwork getNotes:self.inquiryId];
    if (notesDict) {
        id result = [notesDict objectForKey:@"result"];
        if (result && ([result count] != 0)) {
            NSDictionary * noteDict = [result firstObject];
            self.title = [noteDict objectForKey:@"title"];
            [self.notesView loadHTMLString:[noteDict objectForKey:@"description"] baseURL:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
