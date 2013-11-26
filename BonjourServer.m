//
//  BonjourServer.m
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-21.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//
#import "GCDAsyncSocket.h"
#import "BonjourServer.h"
#import "Message.h"
#import "Event.h"

@implementation BonjourServer 
- (void) startServer
{
    users = [[NSMutableDictionary alloc] init];
    
    r = [[Reactor alloc] initWithProperties];
    NSString *s = [NSString stringWithFormat:@"Handlers: %@", r.handlers];
    NSLog(@"Handlers : %@", s);
    
	
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		
	connectedSockets = [[NSMutableArray alloc] init];
	
	NSError *err = nil;
	if ([asyncSocket acceptOnPort:0 error:&err])
	{
		
		UInt16 port = [asyncSocket localPort];
        
        NSLog(@"Accepting on port %hu", port);
		
		[self publishService:port];
		
	}
	else
	{
		NSLog(@"Error in acceptOnPort:error: -> %@", err);
	}
}

-(void) publishService: (UInt16) port{
    netService = [[NSNetService alloc] initWithDomain:@""
                                                 type:@"_im._tcp."
                                                 name:@"Tim"
                                                 port:port];
    
    if (!netService)
    {
        NSLog(@"Failed to enable net service");
    }
    
    [netService
     scheduleInRunLoop:[NSRunLoop currentRunLoop]
     forMode:NSRunLoopCommonModes];
    
    [netService setDelegate:self];
    [netService publish];
    
    NSLog(@"Ended publish service function");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"Accepted new socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
	    
    [newSocket readDataToData: [GCDAsyncSocket CRLFData] withTimeout: -1 tag: -1];
    
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    Message* msg = [Message initFromJSON:data];

    NSLog(@"READ DATA in server: %@", msg.head);
    
    NSString *type = [msg.head valueForKey:@"type"];
    
    Event *e = [[Event alloc] initForType:type];
    e.message = msg;
    e.socket = sock;
    e.users = users;
    e.connectedSockets = connectedSockets;
    [r dispatch:e];
    
        
    [sock readDataToData: [GCDAsyncSocket CRLFData] withTimeout: -1 tag: -1];
}


-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"SENT DATA in server");
}



- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	[connectedSockets removeObject:sock];
}

- (void)netServiceDidPublish:(NSNetService *)ns
{
	NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)",
			  [ns domain], [ns type], [ns name], (int)[ns port]);
}

- (void)netService:(NSNetService *)ns didNotPublish:(NSDictionary *)errorDict
{	
	NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@",
               [ns domain], [ns type], [ns name], errorDict);
}

#pragma mark - Protocols

#pragma mark - Protocols

-(void) addUser:(NSString *)usr{
}

-(void) removeUser:(NSString *)usr{
}


@end