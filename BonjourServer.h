//
//  BonjourServer.h
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-21.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;
#import "BonjourServer.h"
#import "Reactor.h"


@interface BonjourServer : NSObject<NSNetServiceDelegate>
{
	NSNetService *netService;
	GCDAsyncSocket *asyncSocket;
    NSMutableArray *connectedSockets;
    NSMutableDictionary *users;
            
    // Reactor
    Reactor *r;
}


-(void) startServer;
-(void) publishService: (UInt16) port;

@end
