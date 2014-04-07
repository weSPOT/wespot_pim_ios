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

@synthesize syncGeneralItems = _syncGeneralItems;
@synthesize syncResponses = _syncResponses;

+ (void) syncGeneralItems: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGeneralItems = YES;
    
    [synchronizer sync];
}

+ (void) syncResponseData: (NSManagedObjectContext*) context {
    NSLog(@"[%s]", __func__);
    
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
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

    while (YES) {
        if (self.syncGeneralItems) {
            [self downloadGeneralItems];
        } else if (self.syncResponses) {
            [self downloadResponses];
        } else {
            [self saveContext];
            break;
        }
    }
    
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
                NSLog(@"[%s] Unresolved error %@, %@", __func__, error, [error userInfo]);
                abort();
            }
            
//          NSLog(@"[%s] save context completed", __func__);
            [self.parentContext performBlock:^{
                NSError *error = nil;
                if (![self.parentContext save:&error]) {abort();}
            }];
            
        }
//      NSLog(@"[%s] save parent context completed", __func__);
        
    }
//  NSLog(@"[%s] save completed", __func__);
}

- (void) downloadGeneralItems {
    for (GeneralItemData *giData in [GeneralItemData getUnsyncedData:self.context]) {
//      NSLog(@"[%s] gidata url=%@ replicated=%@ error=%@", __func__, giData.url, giData.replicated, giData.error);
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

- (void) downloadResponses {
    for (Response *response in [Response getReponsesWithoutMedia:self.context]) {
        NSURL  *url = [NSURL URLWithString:response.fileName];
        
#warning swap fetching urlData with respons types (so we do not have to download/store the complete videos). Store only thumbs.
        
        if (! (response.data || response.thumb) ) {
            if ([response.contentType isEqualToString:@"application/jpg"])
            {
                NSLog(@"[%s] Downloading url=%@", __func__, response.fileName);
                
                NSData *urlData = [NSData dataWithContentsOfURL:url];
                
                if (urlData) {
                    NSLog(@"[%s] Downloaded url=%@", __func__, response.fileName);
                    
                    // Create Thumbnails from Images to lower memory load.
                    UIImage *img = [UIImage imageWithData:urlData];
                    
                    UIImage *thumbImage = nil;
                    CGSize targetSize = CGSizeMake(img.size.width/8, img.size.height/8);
                    UIGraphicsBeginImageContext(targetSize);
                    
                    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
                    thumbnailRect.origin = CGPointMake(0.0,0.0);
                    thumbnailRect.size.width  = targetSize.width;
                    thumbnailRect.size.height = targetSize.height;
                    
                    [img drawInRect:thumbnailRect];
                    
                    thumbImage = UIGraphicsGetImageFromCurrentImageContext();
                    
                    UIGraphicsEndImageContext();
                    
                    response.thumb = UIImageJPEGRepresentation(thumbImage, 0.75);
                    // response.data = UIImageJPEGRepresentation(img, 0.75);
                    
                    img = nil;
                    thumbImage = nil;
                    
                    urlData = nil;
                    
                    NSLog(@"[%s] Image:%d Thumb:%d", __func__, [response.data length], [response.thumb length]);
                } else {
                    NSLog(@"[%s] Could not fetch url=%@", __func__, response.fileName);
                }
            } else if ([response.contentType isEqualToString:@"video/quicktime"]) {
                
                //See http://stackoverflow.com/questions/8432246/ios-gamecenter-avasset-and-audio-streaming
                
                
                // 1) Save NSData to File in temp Directory.
                // See http://stackoverflow.com/questions/1489522/stringbyappendingpathcomponent-hows-it-work
                //                NSString *tmp = NSTemporaryDirectory();
                //                NSString *url = [tmp stringByAppendingPathComponent:@"temp.mov"];
                //
                //                // Make sure there is no other file with the same name first
                //                if ([[NSFileManager defaultManager] fileExistsAtPath:url]) {
                //                    [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
                //                }
                //
                //                [urlData writeToFile:url atomically:NO];
                
                NSLog(@"[%s] Thumbnailing url=%@", __func__, response.fileName);
                
                NSString *url = response.fileName;
                
                // 2) Create an AVAsset from it.
                //                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:nil];
                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:url] options:nil];
                
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
                    NSLog(@"[%s] Error==%@, Refimage==%@",__func__, error, refImg);
                }
                //
                UIImage *thumbImage= [[UIImage alloc] initWithCGImage:refImg];
                
                // 6) Save both original and thumbnail.
                // response.data = urlData;
                response.thumb = UIImageJPEGRepresentation(thumbImage, 0.75);
                
                //7) Remove temporary file.
                //            if ([[NSFileManager defaultManager] fileExistsAtPath:url]) {
                //                [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
                //            }
            } else if ([response.contentType isEqualToString:@"audio/aac"]) {
                //response.data = [NSData dataWithContentsOfURL:url];
            } else {
                response.data = [NSData dataWithContentsOfURL:url];
            }
            
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    
    self.syncResponses=NO;
}

@end
