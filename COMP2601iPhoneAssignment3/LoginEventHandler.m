//
//  LoginEventHandler.m
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-24.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import "LoginEventHandler.h"
#import "ChatImage.h"
#import "NSAdditions.h"

@implementation LoginEventHandler
-(void) handleEvent: (Event *) event {
    NSLog(@"Login handler: %@", event);
}

-(void) handleTheEvent: (Event *) event {
    NSLog(@"Login handler handleTheEvent: %@", event);
    
    // Message received
    Message *recMsg = event.message;
    NSDictionary *body = [recMsg body];
    NSString *sender = [body objectForKey:@"sender"];
    NSLog(@"Sender: %@", body);

    if(sender != nil)
        [event.users setObject:event.socket forKey:sender];
    
    [event.connectedSockets addObject:event.socket];

    // Message to send
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"LOGIN" forKey:@"type"];
    // Gets image for user and ads as base64 data
    NSString *imageString = [UIImagePNGRepresentation([ChatImage imageForUser:@""]) base64Encoding];
    [[msg body] setValue:imageString forKey:@"sender"];
    NSArray *users = [[NSArray alloc] initWithArray:[event.users allKeys]];
    [[msg body] setValue:users forKey:@"users"];
    
    // Sends new message
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    Message* msg2 = [Message initFromJSON:data];
    NSLog(@"Sent DATA in server: %@", msg2.head);
    
    for(GCDAsyncSocket *sock in event.connectedSockets){
        [sock writeData:data withTimeout:-1 tag:-1];
        [sock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
    }
}

@end
