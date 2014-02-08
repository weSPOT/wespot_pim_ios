//
//  INQOauthViewController.h
//  PersonalInquiryManager
//
//  Created by Stefaan Ternier on 8/8/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLOauthViewController.h"

@interface INQOauthViewController :UITableViewController //: ARLOauthViewController

@property (strong, nonatomic) ARLOauthView * oauthView;

@property (strong, nonatomic) NSString * facebookLoginString;
@property (strong, nonatomic) NSString * googleLoginString;
@property (strong, nonatomic) NSString * linkedInLoginString;
@property (strong, nonatomic) NSString * twitterLoginString;

@end
