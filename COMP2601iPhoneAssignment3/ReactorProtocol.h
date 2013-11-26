//
//  ReactorProtocol.h
//  Reactor
//
//  Created by Tony White on 12-03-22.
//  Copyright (c) 2012 Carleton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventHandlerProtocol;
@class Event;

@protocol ReactorProtocol <NSObject>

-(void)register: (id)handler with: (SEL) s forType: (NSString*) type;
-(void)register: (id<EventHandlerProtocol>) eventHandler forType: (NSString *)type;
-(void)deregister: (id) eventHandler forType: (NSString *)type;
-(void)dispatch: (Event*)event;
@end
