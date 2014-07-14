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

@synthesize responseType = _responseType;

@synthesize syncGeneralItems = _syncGeneralItems;
@synthesize syncResponses = _syncResponses;

+ (void) syncGeneralItems: (NSManagedObjectContext*) context {
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.syncGeneralItems = YES;
    
    [synchronizer sync];
}

+ (void) syncResponseData: (NSManagedObjectContext*) context
              responseType: (NSNumber *) responseType {
    ARLFileCloudSynchronizer* synchronizer = [[ARLFileCloudSynchronizer alloc] init];
    
    [synchronizer createContext:context];
    
    synchronizer.responseType = responseType;
    
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
    //mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    //DLog(@"Thread:0x%x - %@ - %@", machTID, @"Checking Lock", ARLAppDelegate.theLock);
    
    [ARLAppDelegate.theLock lock];
    
    //DLog(@"Thread:0x%x - %@ - %@", machTID, @"Passing Lock", ARLAppDelegate.theLock);
    
     // DLog(@"Thread:0x%x - Start of File Synchronisation", machTID);
    
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
    
    if (ARLAppDelegate.SyncAllowed) {
        [self saveContext];
        [NSThread sleepForTimeInterval:0.1];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [ARLAppDelegate.theLock unlock];
    
    // DLog(@"Thread:0x%x - %@ - %@", machTID, @"Exit Lock", ARLAppDelegate.theLock);
    
    // DLog(@"Thread:0x%x - End of File Synchronisation", machTID);
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
 
    // CLog(@"Saving NSManagedObjectContext");
    // RawLog(@"");

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
    // CLog(@"");
    
    for (GeneralItemData *giData in [GeneralItemData getUnsyncedData:self.context]) {
        // DLog(@"gidata url=%@ replicated=%@ error=%@", giData.url, giData.replicated, giData.error);
        
        if (ARLAppDelegate.SyncAllowed) {
            NSURL  *url = [NSURL URLWithString:giData.url];
          
            // CLog(@"%@", [url lastPathComponent]);
            
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if (urlData){
                giData.data = urlData;
                giData.replicated = [NSNumber numberWithBool:YES];
            } else {
                DLog(@"Could not fetch url");
            }
            
            //[self saveContext];
            NSError *error = nil;
            [self.context save:&error];
        }
    }
    
    self.syncGeneralItems=NO;
}

- (void) downloadResponses {
    // CLog(@"ResponseType=%@", self.responseType);
    
    int cnt = 0;
    
    for (Response *response in [Response getReponsesWithoutMedia:self.context]) {
        if (ARLAppDelegate.SyncAllowed) {
            @autoreleasepool {
                if ([response.responseType isEqualToNumber:self.responseType]) {
                    if (response.data == nil && response.thumb == nil) {
                        switch ((int)response.responseType) {
                            case PHOTO: {
                                cnt++;
                                
                                NSURL *url = [NSURL URLWithString:[response.fileName stringByAppendingString:@"?thumbnail=320&crop=true"]];
                                
                                // CLog(@"Downloading: %@", [url lastPathComponent]);
                                
                                NSData *urlData = [NSData dataWithContentsOfURL:url];
                                
                                if (urlData) {
                                    // CLog(@"Downloaded: %@", [url lastPathComponent]);
                                    
                                    response.thumb = urlData; //[UIImage imageWithData:urlData];
                                    
                                    urlData = nil;
                                    
                                    // DLog(@"Image:%d Thumb:%d", [response.data length], [response.thumb length]);
                                } else {
                                    DLog(@"Error Could not fetch url=%@", response.fileName);
                                }
                            }
                                break;
                            
                            case VIDEO: {
                                cnt++;
                                
                                NSURL *url = [NSURL URLWithString:response.fileName];
                                
                                // CLog(@"Downloading: %@", [url lastPathComponent]);
                                
                                // CLog(@"Thumbnailing: %@", [url lastPathComponent]);
                                
                                // 2) Create an AVAsset from it.
                                //                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:url] options:nil];
                                AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                                
                                // http://stackoverflow.com/questions/4627940/how-to-detect-iphone-sdk-if-a-video-file-was-recorded-in-portrait-orientation
                                // DLog(@"Natural Size: %f x %f", [urlAsset naturalSize].width, [urlAsset naturalSize].height);
                                //                CGAffineTransform txf = [urlAsset preferredTransform];
                                // DLog(@"Preferred transform Size: %f x %f", txf.tx, txf.ty);
                                
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
                                    DLog(@"Error==%@, RefImage==%@", error, refImg);
                                }
                                
                                UIImage *thumbImage= [[UIImage alloc] initWithCGImage:refImg];
                                
                                // 6) Save both original and thumbnail.
                                // response.data = urlData;
                                response.thumb = UIImageJPEGRepresentation(thumbImage, 0.75);
                                
                                //7) Remove temporary file.
                                //            if ([[NSFileManager defaultManager] fileExistsAtPath:url]) {
                                //                [[NSFileManager defaultManager] removeItemAtPath:url error:nil];
                                //            }
                                
                                urlAsset =nil;
                                thumbImage = nil;
                                generateImg = nil;
                            }
                                break;
                                
                            case AUDIO: {
                                // Nothing to download/thumbnail
                            }
                                break;
                                
                            case TEXT: {
                                // Nothing to download
                            }
                                break;
                                
                            case NUMBER: {
                                // Nothing to download
                            }
                                break;
                            
                            default: {
                                if (response.fileName) {
                                    cnt++;
                                    
                                    NSURL *url = [NSURL URLWithString:response.fileName];
                                    
                                    // CLog(@"Downloading: %@", [url lastPathComponent]);
                                    
                                    response.data = [NSData dataWithContentsOfURL:url];
                                }
                            }
                                break;
                        }
                        
                        if ([self.context hasChanges]) {
                            NSError *error = nil;
                            [self.context save:&error];
                        }
                    }
                }
            }
        }
    }
    
    // DLog(@"** Downloaded %d files for contentType=%@", cnt, self.contentType);
    
    self.syncResponses=NO;
}

@end
