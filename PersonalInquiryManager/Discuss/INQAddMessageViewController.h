//
//  INQAddMessageViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 4/16/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPKeyboardAvoidingScrollView.h"

#import "ARLNetwork+INQ.h"

@interface INQAddMessageViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSNumber *inquiryId;

@end
