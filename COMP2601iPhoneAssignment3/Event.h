//
//  Event.h
//  Reactor
//
//  Created by Tony White on 12-03-22.
//  Copyright (c) 2012 Carleton University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Message.h"

@interface Event : NSObject

@property(strong) NSString *type;
@property(strong) NSMutableDictionary *users;

@property(strong) GCDAsyncSocket *socket;
@property(strong) NSMutableArray *connectedSockets;
@property(strong) Message *message;

-(id) initForType: (NSString*)t;

@end
