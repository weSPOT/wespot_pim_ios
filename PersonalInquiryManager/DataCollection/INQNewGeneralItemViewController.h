//
//  INQNewGeneralItemViewController.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 5/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TPKeyboardAvoidingScrollView.h"

#import "UIViewController+UI.h"

#import "Run+ARLearnBeanCreate.h"
#import "ARLNetwork+INQ.h"

@interface INQNewGeneralItemViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Run *run;

@end
