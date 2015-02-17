//
//  INQUtils.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 9/29/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQUtils.h"

@implementation INQUtils

+ (NSString *)base64forData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+ (NSAttributedString *)htmlToAttributedString:(NSString *)theHtml {
    return[[NSAttributedString alloc] initWithData:[theHtml dataUsingEncoding:NSUTF8StringEncoding]
                                           options:@{
                                                     NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                     NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                                     }
                                documentAttributes:nil
                                             error:nil];
}

+ (NSString *)cleanHtml:(NSString *)theHtml {
    if ([theHtml rangeOfString:@"<p>"].location == 0) {
        theHtml = [theHtml substringFromIndex:3];
    }
    
    // NSBigMutableString* x;
    
    //Remove Trailing </p>
    if ([theHtml rangeOfString:@"</p>"].location == theHtml.length-1-3) {
        theHtml = [theHtml substringToIndex:theHtml.length-1-3];
    }
    
    theHtml = [[INQUtils htmlToAttributedString:theHtml] string];
    
    //Remove WhiteSpace (note U0000fffc is 'OBJECT REPLACEMENT CHARACTER' acording to unicode).
    return [theHtml stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \r\n\t\U0000fffc"]];
    
    //return [theHtml stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/*!
 *  Add a rounded corner.
 *
 *  See http://stackoverflow.com/questions/2264083/rounded-uiview-using-calayers-only-some-corners-how
 *
 *  @param view   <#view description#>
 *  @param radius <#radius description#>
 */
+ (void)addRoundedCorner:(UIView *)view
                  radius:(float)radius {
    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    view.layer.mask = maskLayer;
}
@end
