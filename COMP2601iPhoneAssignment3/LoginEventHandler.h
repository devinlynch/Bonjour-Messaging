//
//  LoginEventHandler.h
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-24.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventHandlerProtocol.h"
#import "Message.h"
#import "GCDAsyncSocket.h"
#import "Event.h"
#import "ServerProtocol.h"

@interface LoginEventHandler : NSObject <EventHandlerProtocol, ServerProtocol>

-(void)handleTheEvent:(Event *)event;

@end
