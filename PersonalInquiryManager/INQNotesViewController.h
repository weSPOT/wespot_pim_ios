//
//  INQNotesViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 9/6/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARLNetwork+INQ.h"

@interface INQNotesViewController : UIViewController
@property (strong, nonatomic) UIWebView *notesView;
@property (strong, nonatomic) NSNumber *inquiryId;
@end
