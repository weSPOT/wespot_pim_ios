//
//  INQUtils.h
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 9/29/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define INQ_SYNCREADY    @"INQ_syncReady"
#define INQ_SYNCPROGRESS @"INQ_syncProgress"
#define INQ_GOTAPN       @"INQ_GotAPN"

@interface INQUtils : NSObject

+ (NSString *)base64forData:(NSData*)theData;

+ (NSAttributedString *)htmlToAttributedString:(NSString *)theHtml;

+ (NSString *)cleanHtml:(NSString *)theHtml;

+ (void)addRoundedCorner:(UIView *)imageView
       byRoundingCorners:(UIRectCorner)corners
                  radius:(float)radius;

+ (void)addRoundedCorner:(UIView *)view
       byRoundingCorners:(UIRectCorner)corners
            deltaOriginX:(NSInteger)deltaOriginX
            deltaOriginY:(NSInteger)deltaOriginY
              deltaWidth:(NSInteger)deltaWidth
             deltaHeight:(NSInteger)deltaHeight
                  radius:(float)radius;

+(NSString *)ClipNWords:(NSString *)msg
                 offset:(NSInteger)offset
                  words:(NSInteger)words;

@end
