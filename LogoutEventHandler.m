//
//  LogoutEventHandler.m
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import "LogoutEventHandler.h"

@implementation LogoutEventHandler
-(void) handleEvent: (Event *) event {
    NSLog(@"Logout handler: %@", event);
}

-(void) handleTheEvent: (Event *) event {
    NSLog(@"Logout handler handleTheEvent: %@", event);
    NSLog(@"Count before: %d", event.connectedSockets.count);
    // Message received
    Message *recMsg = event.message;
    NSDictionary *body = [recMsg body];
    NSString *sender = [body objectForKey:@"sender"];
    NSLog(@"Sender: %@", body);
    
    if(sender != nil)
        [event.users removeObjectForKey:sender];
    
    [event.connectedSockets removeObject:event.socket];
    
    // Message to send
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"LOGOUT" forKey:@"type"];
    [[msg body] setValue:@"SERVER" forKey:@"sender"];
    NSArray *users = [[NSArray alloc] initWithArray:[event.users allKeys]];
    [[msg body] setValue:users forKey:@"users"];
    
    // Sends new message
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    Message* msg2 = [Message initFromJSON:data];
    NSLog(@"Sent DATA in server: %@", msg2.head);
    
    NSLog(@"Count after: %d", event.connectedSockets.count);
    for(GCDAsyncSocket *sock in event.connectedSockets){
        [sock writeData:data withTimeout:-1 tag:-1];
        [sock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
    }
}
@end
