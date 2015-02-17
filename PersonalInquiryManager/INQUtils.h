//
//  INQUtils.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 9/29/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface INQUtils : NSObject

+ (NSString *)base64forData:(NSData*)theData;

+ (NSAttributedString *)htmlToAttributedString:(NSString *)theHtml;

+ (NSString *)cleanHtml:(NSString *)theHtml;

+ (void)addRoundedCorner:(UIView *)imageView
                  radius:(float)radius;
@end
