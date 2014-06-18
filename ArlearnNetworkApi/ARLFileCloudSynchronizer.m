//
//  ARLFileCloudSynchronizer.m
//  ARLearn
//
//  Created by Stefaan Ternier on 7/16/13.
//  Copyright (c) 2013 Stefaan Ternier. All rights reserved.
//

#import "ARLFileCloudSynchronizer.h"

@implementation ARLFileCloudSynchronizer

@synthesize context = _context;

@synthesize contentType = _contentType;

@synthesize syncGeneralItems = _syncGeneralItems;
@synthesize syncResponses = _syncResponses;

+ (void) syncGeneralItems: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGeneralItems = YES;
    
    [synchronizer sync];
}

+ (void) syncResponseData: (NSManagedObjectContext*) context
              contentType: (NSString *) contentType {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.contentType = contentType;
    
    synchronizer.syncResponses = YES;
    
    [synchronizer sync];
}

- (void) createContext: (NSManagedObjectContext*) mainContext {
    self.parentContext = mainContext;
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    self.context.parentContext = mainContext;
}

- (void) sync {
    [self.context performBlock:^{
        [self asyncExecution];
    }];
}

- (void) asyncExecution {
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Passed Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x]\r\n*******************************************\r\nStart of File Synchronisation", __func__, machTID);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    while (ARLAppDelegate.SyncAllowed) {
        
        if (self.syncGeneralItems) {
            [self downloadGeneralItems];
        } else if (self.syncResponses) {
            [self downloadResponses];
        } else {
            break;
        }
    }
    
    [self saveContext];
    [NSThread sleepForTimeInterval:0.25];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    NSLog(@"[%s 0x%x]\r\n\r\n%@\r\n%@\r\n\r\n", __func__, machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    NSLog(@"\r\n[%s 0x%x] End of File Synchronisation\r\n*******************************************", __func__, machTID);
}

/*!
 *  Save the Core Data Context.
 *
 *  See http://www.cocoanetics.com/2012/07/multi-context-coredata/
 *
 *  Runs on a separate thread in the background.
 */
- (void)saveContext
{
    NSError *error = nil;
    
    if (self.context) {
        if ([self.context hasChanges]){
            if (![self.context save:&error]) {
                [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
            }
        }
    
        if ([self.parentContext hasChanges]){
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {
                    [ARLNetwork ShowAbortMessage:error func:[NSString stringWithFormat:@"%s",__func__]];
                }
            }];
            
        }
    }
}

- (void) downloadGeneralItems {
    for (GeneralItemData *giData in [GeneralItemData getUnsyncedData:self.context]) {
        //      NSLog(@"[%s] gidata url=%@ replicated=%@ error=%@", __func__, giData.url, giData.replicated, giData.error);
        
        if (ARLAppDelegate.SyncAllowed) {
            NSURL  *url = [NSURL URLWithString:giData.url];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if (urlData){
                giData.data = urlData;
                giData.replicated = [NSNumber numberWithBool:YES];
            } else {
                NSLog(@"[%s] Could not fetch url", __func__);
            }
            
            //[self saveContext];
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    
    self.syncGeneralItems=NO;
}

// See http://natashatherobot.com/ios-how-to-download-images-asynchronously-make-uitableview-scroll-fast/
// Fails when retrieving response.data and converting it to an image in the gui.
//+ (void)downloadImageWithURL:(Response *)resp completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
//{
//    NSURL *url = [[NSURL alloc] initWithString:resp.fileName];
//
//    NSLog(@"[%s] Downloading url=%@", __func__, resp.fileName);
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//                               NSLog(@"[%s] [%d] Downloaded url=%@", __func__, [(NSHTTPURLResponse *)response statusCode], resp.fileName);
//                               if (!error && [(NSHTTPURLResponse *)response statusCode]==200)
//                               {
//                                   UIImage *image = [[UIImage alloc] initWithData:data];
//                                   if (image) {
//                                       resp.data = UIImageJPEGRepresentation(image, 1.0);
//
//                                       completionBlock(YES, image);
//                                   } else {
//                                       completionBlock(NO, nil);}
//                               } else{
//                                   completionBlock(NO, nil);
//                               }
//                           }];
//}

//// See http://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
//- (UIImage *)fixrotation:(UIImage *)image{
//
//
//    if (image.imageOrientation == UIImageOrientationUp) return image;
//    CGAffineTransform transform = CGAffineTransformIdentity;
//
//    switch (image.imageOrientation) {
//        case UIImageOrientationDown:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
//            transform = CGAffineTransformRotate(transform, M_PI);
//            break;
//
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
//            transform = CGAffineTransformRotate(transform, M_PI_2);
//            break;
//
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
//            transform = CGAffineTransformRotate(transform, -M_PI_2);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationUpMirrored:
//            break;
//    }
//
//    switch (image.imageOrientation) {
//        case UIImageOrientationUpMirrored:
//        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
//            transform = CGAffineTransformScale(transform, -1, 1);
//            break;
//        case UIImageOrientationUp:
//        case UIImageOrientationDown:
//        case UIImageOrientationLeft:
//        case UIImageOrientationRight:
//            break;
//    }
//
//    // Now we draw the underlying CGImage into a new context, applying the transform
//    // calculated above.
//    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
//                                             CGImageGetBitsPerComponent(image.CGImage), 0,
//                                             CGImageGetColorSpace(image.CGImage),
//                                             CGImageGetBitmapInfo(image.CGImage));
//    CGContextConcatCTM(ctx, transform);
//    switch (image.imageOrientation) {
//        case UIImageOrientationLeft:
//        case UIImageOrientationLeftMirrored:
//        case UIImageOrientationRight:
//        case UIImageOrientationRightMirrored:
//            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
//            break;
//
//        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
//            break;
//    }
//
//    // And now we just create a new UIImage from the drawing context
//    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
//    UIImage *img = [UIImage imageWithCGImage:cgimg];
//    CGContextRelease(ctx);
//    CGImageRelease(cgimg);
//    return img;
//
//}

- (void) downloadResponses {
    NSLog(@"[%s] ** Checking for contentType=%@", __func__, self.contentType);
    
    int cnt = 0;
    
    for (Response *response in [Response getReponsesWithoutMedia:self.context]) {
        if (ARLAppDelegate.SyncAllowed) {
            @autoreleasepool {
                if ([response.contentType isEqualToString:self.contentType])
                {
                    if (response.data == nil && response.thumb == nil) {
                        if ([response.contentType isEqualToString:@"application/jpg"]) {
                            cnt++;
                            
                            NSURL *url = [NSURL URLWithString:[response.fileName stringByAppendingString:@"?thumbnail=320&crop=true"]];
                            
                            NSLog(@"[%s] ** Downloading url=%@", __func__, url);
                            
                            NSData *urlData = [NSData dataWithContentsOfURL:url];
                            
                            if (urlData) {
                                NSLog(@"[%s] ** Downloaded url=%@", __func__, url);
                                
                                // Create Thumbnails from Images to lower memory load.
                                // UIImage *img = [UIImage imageWithData:urlData];
                                
                                // Obsolete Rotation code:
                                // NSLog(@"[%s] Orientation: %d", __func__, img.imageOrientation);
                                
                                // if (img.imageOrientation != UIImageOrientationUp) {
                                //                        UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
                                //      [img drawInRect:(CGRect){0, 0, img.size}];
                                //      UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
                                //      UIGraphicsEndImageContext();
                                //
                                //      img = normalizedImage;
                                // }
                                
                                // NSString *tmp = NSTemporaryDirectory();
                                // NSString *file = [tmp stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", response.responseId]];
                                //
                                // // Make sure there is no other file with the same name first
                                // if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
                                //                        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
                                // }
                                //
                                // [urlData writeToFile:file atomically:NO];
                                
                                // //if (img.imageOrientation != UIImageOrientationUp) {
                                //      img = [UIImage imageWithCGImage:[UIImage imageWithData:urlData].CGImage
                                //                                              scale:img.scale
                                //                                        orientation:img.imageOrientation];
                                // //}
                                
                                // NSLog(@"[%s] Orientation: %d", __func__, img.imageOrientation);
                                
                                // Obsolete Thumbnail odew:
                                // UIImage *thumbImage = nil;
                                // CGSize targetSize = CGSizeMake(img.size.width/8, img.size.height/8);
                                // UIGraphicsBeginImageContext(targetSize);
                                //
                                // CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
                                // thumbnailRect.origin = CGPointMake(0.0,0.0);
                                // thumbnailRect.size.width  = targetSize.width;
                                // thumbnailRect.size.height = targetSize.height;
                                //
                                // [img drawInRect:thumbnailRect];
                                //
                                // thumbImage = UIGraphicsGetImageFromCurrentImageContext();
                                //
                                // UIGraphicsEndImageContext();
                                //
                                // // Compress Image
                                // response.thumb = UIImageJPEGRepresentation(thumbImage, 0.75);
                                // // response.data = UIImageJPEGRepresentation(img, 0.75);
                                
                                response.thumb = urlData; //[UIImage imageWithData:urlData];
                                //img = nil;
                                //thumbImage = nil;
                                
                                urlData = nil;
                                
                                // NSLog(@"[%s] Image:%d Thumb:%d", __func__, [response.data length], [response.thumb length]);
                            } else {
                                NSLog(@"[%s] Error Could not fetch url=%@", __func__, response.fileName);
                            }
                        } else if ([response.contentType isEqualToString:@"video/quicktime"]) {
                            cnt++;
                            
                            NSURL *url = [NSURL URLWithString:response.fileName];
                            
                            NSLog(@"[%s] ** Downloading url=%@", __func__, url);
                            
                            //See http://stackoverflow.com/questions/8432246/ios-gamecenter-avasset-and-audio-streaming
                            
                            // 1) Save NSData to File in temp Directory.
                            // See http://stackoverflow.com/questions/1489522/stringbyappendingpathcomponent-hows-it-work
                            //                    NSString *tmp = NSTemporaryDirectory();
                            //                    NSString *file = [tmp stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", response.responseId]];
                            //
                            //                    // Make sure there is no other file with the same name first
                            //                    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
                            //                        [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
                            //                    }
                            //
                            //                    [[NSData dataWithContentsOfURL:url] writeToFile:file atomically:NO];
                            
                            NSLog(@"[%s] ** Thumbnailing url=%@", __func__, url);
                            
                            // 2) Create an AVAsset from it.
                            //                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:nil];
                            AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                            
                            // http://stackoverflow.com/questions/4627940/how-to-detect-iphone-sdk-if-a-video-file-was-recorded-in-portrait-orientation
                            // NSLog(@"[%s] Naural Size: %f x %f", __func__, [urlAsset naturalSize].width, [urlAsset naturalSize].height);
                            //                CGAffineTransform txf = [urlAsset preferredTransform];
                            //                NSLog(@"[%s] Preferred transform Size: %f x %f", __func__, txf.tx, txf.ty);
                            
                            // 3) Set max ThumbNail size,
                            //See http://stackoverflow.com/questions/19368513/generating-thumbnail-from-video-ios7
                            AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:urlAsset];
                            
                            generateImg.maximumSize = CGSizeMake(256, 256);
                            
                            // 4) Set the time of the ThumbNail.
                            CMTime time = CMTimeMake(1, 65); // @ 1/65 sec.
                            
                            // 5) Create the ThumbNail.
                            NSError *error = NULL;
                            CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
                            
                            if (error) {
                                NSLog(@"[%s] Error==%@, RefImage==%@",__func__, error, refImg);
                            }
                            //
                            UIImage *thumbImage= [[UIImage alloc] initWithCGImage:refImg];
                            
                            // 6) Save both original and thumbnail.
                            // response.data = urlData;
                            response.thumb = UIImageJPEGRepresentation(thumbImage, 0.75);
                            
                            //Fails because it's web-based.
                            //                NSURL *myURL = [[NSURL alloc] initWithString:url];
                            //                MPMoviePlayerController *movieController = [[MPMoviePlayerController alloc] initWithContentURL:myURL];
                            //                UIImage *thumbImage2 = [movieController thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
                            //                movieController = nil;
                            //                float width = thumbImage2.size.width;
                            //                float height = thumbImage2.size.height;
                            
                            //7) Remove temporary file.
                            //            if ([[NSFileManager defaultManager] fileExistsAtPath:url]) {
                            //                [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
                            //            }
                            
                            urlAsset =nil;
                            thumbImage = nil;
                            generateImg = nil;
                        } else if ([response.contentType isEqualToString:@"audio/aac"]) {
                            // NSURL *url = [NSURL URLWithString:response.fileName];
                            
                            // NSLog(@"[%s] ** Not Downloading url=%@", __func__, url);
                            
                            //response.data = [NSData dataWithContentsOfURL:url];
                        } else {
                            cnt++;
                            
                            NSURL *url = [NSURL URLWithString:response.fileName];
                            
                            NSLog(@"[%s] ** Downloading url=%@", __func__, url);
                            
                            response.data = [NSData dataWithContentsOfURL:url];
                        }
                        
                        NSError *error = nil;
                        [self.context save:&error];
                    }
                }
            }
        }
    }
    NSLog(@"[%s] ** Downloaded %d files for contentType=%@", __func__, cnt, self.contentType);
    
    self.syncResponses=NO;
}

@end
