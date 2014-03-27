//
//  INQCommunicateViewController.m
//  PersonalInquiryManager
//
//  Created by Wim van der Vegt on 2/13/14.
//  Copyright (c) 2014 Stefaan Ternier. All rights reserved.
//

#import "INQCommunicateViewController.h"

@interface INQCommunicateViewController ()

@end

@implementation INQCommunicateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

// Get Default Thread
// GET /rest/messages/thread/runId/5117857260109824/default

//{
//    "type": "org.celstec.arlearn2.beans.run.Thread",
//    "runId": 5117857260109824,
//    "threadId": 6397033275457536,
//    "name": "Default",
//    "deleted": false,
//    "lastModificationDate": 1395924374319
//}

// Get Messags from Default Thread
// GET /rest/messages/runId/5117857260109824/default

//{
//    "type": "org.celstec.arlearn2.beans.run.MessageList",
//    "serverTime": 1395925562539,
//    "messages": [
//                 {
//                     "type": "org.celstec.arlearn2.beans.run.Message",
//                     "runId": 5117857260109824,
//                     "deleted": false,
//                     "subject": "Heading",
//                     "body": "Here comes some text",
//                     "threadId": 6397033275457536,
//                     "messageId": 5802343513718784,
//                     "date": 1395925443163
//                 }
//                 ]
//}

// Post a Message on the Main Thread.
// POST /rest/messages/message

//{
//    "type": "org.celstec.arlearn2.beans.run.Message",
//    "runId": 5117857260109824,
//    "threadId": 6397033275457536,
//    "subject": "Heading",
//    "body": "Here comes some text"
//}

//{
//    "type": "org.celstec.arlearn2.beans.run.Message",
//    "runId": 5117857260109824,
//    "deleted": false,
//    "subject": "Heading",
//    "body": "Here comes some text",
//    "threadId": 6397033275457536,
//    "messageId": 5802343513718784,
//    "date": 1395925443163
//}

@end
