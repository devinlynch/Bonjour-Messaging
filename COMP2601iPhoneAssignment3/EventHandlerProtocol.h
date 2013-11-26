//
//  EventHandlerProtocol.h
//  Reactor
//
//  Created by Tony White on 12-03-22.
//  Copyright (c) 2012 Carleton University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@protocol EventHandlerProtocol <NSObject>

-(void)handleEvent: (Event*) event;

@end
