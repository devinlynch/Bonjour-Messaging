//
//  TextEventHandler.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "EventHandlerProtocol.h"
#import "Message.h"
#import "GCDAsyncSocket.h"
#import "Event.h"
#import "ServerProtocol.h"
@interface TextEventHandler : NSObject<EventHandlerProtocol>
-(void)handleTheEvent:(Event *)event;

@end
