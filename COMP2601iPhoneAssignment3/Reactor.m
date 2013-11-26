//
//  Reactor.m
//  Reactor
//
//  Created by Tony White on 12-03-22.
//  Copyright (c) 2012 Carleton University. All rights reserved.
//

#import "Reactor.h"
#import "Event.h"

@implementation Reactor
@synthesize handlers;

// Used to set up various constants to be used in the
// configuration of a reactor. It is possible to have
// arbitrary methods invoked as an event handler; however,
// when dynamic handlers are to be added, they are to
// implement the EventHandlerProtocol. This is for convenience
// only. It would be easy to generalize this.

static NSString *TYPE_KEY = @"EVENT.%d.TYPE";
static NSString *CLASS_KEY = @"EVENT.%d.CLASS";
static NSString *METHOD_KEY = @"EVENT.%d.METHOD";
static NSString *DEFAULT_HANDLER = @"DEFAULT";
static NSString *DEFAULT_METHOD = @"handleEvent:";
static int START_VALUE = 1;

// By default, there is an empty reactor

-(id) init {
    self = [super init];
    if (self) {
        handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// By default, I load the reactor.plist property list file

-(id)initWithProperties {
    self = [self init];
    if (self) {
        [self loadFromPropertiesFile];
    }
    return self;
}

// A dictionary of key-value pairs can be used
// to configure the reactor

-(id)initWithDictionary: (NSDictionary*) dictionary {
    self = [self init];
    if (self) {
        [self createHandlers:dictionary];
    }
    return self;
}

// The loadFromPropertiesFile method reads the reactor.plist file which contains a dictionary of key-value pairs.
// The keys are EVENT.* where the key formats are stored as static variables at the head of this file.

-(void) loadFromPropertiesFile {
    [self createHandlers: [self loadPropertiesFile]];
}

-(NSDictionary*) loadPropertiesFile {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"reactor.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"reactor" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp =[NSPropertyListSerialization
                         propertyListFromData:plistXML
                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                         format:&format
                         errorDescription:&errorDesc];
    if (!temp)
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    return temp;
}

// Load the handlers from a dictionry. Do nothing if there's no dictionary
-(void)createHandlers: (NSDictionary*)dict {
    if (dict != nil) {
        int i = START_VALUE;
        Boolean continue_to_create = true;
        
        while (continue_to_create) {
            continue_to_create = [self createHandler: i fromDictionary: (NSDictionary*)dict];
            i++;
        }
    }
}

// Create the handlers for a specific set of keys. Start at EVENT.1.* and continue with
// EVENT.2.* etc. Return false if we provide no dictionary
-(Boolean)createHandler: (int) i fromDictionary: (NSDictionary*) dict{
    
    if (dict == nil)
        return false;
    
    NSString *type = [NSString stringWithFormat:TYPE_KEY, i];
    NSString *type_val = [dict objectForKey:type];
    if (type_val != nil) {
        NSString *class_key = [NSString stringWithFormat:CLASS_KEY, i];
        NSString *class_val = [dict objectForKey:class_key];
        if (class_val != nil) {
            NSString *method_key = [NSString stringWithFormat:METHOD_KEY, i];
            NSString *method_val = [dict objectForKey:method_key];
            if (method_val == nil)
                method_val = DEFAULT_METHOD;
            if (method_val != nil) {
                Class c = NSClassFromString(class_val);
                id instance = [[c alloc] init];
                SEL s = NSSelectorFromString(method_val);
                if (instance != nil) {
                    if ([instance respondsToSelector:s])
                        [self register:instance with:s forType:type_val];
                } else {
                    NSLog(@"Invalid handler specification: %@ not found, or invalid selector %@", class_val, method_val);
                    return false;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
    } else {
        return false;
    }
    // Everything was okay
    return true;
}

#pragma ReactorProtocol

// Synchronization is provided here in order that we do not access the handler
// dictionary from multiple threads. Adding or removing key-value pairs would
// be problematic.

-(void) dispatch:(Event *)event {
    // Invoke the handler or a default if the type
    @synchronized(handlers) {
        NSInvocation *i = [handlers objectForKey: event.type];
        if (i == nil)
            i = [handlers objectForKey: DEFAULT_HANDLER];
        if (i != nil) {
            [i setArgument:&event atIndex:2];
            [i invoke];
        }
    }
}

// Can register objects conforming to the EvenHandlerProtocol or general
// selectors that are associated with an instance

-(void) register:(id)eventHandler with: (SEL) s forType:(NSString *)type {
    @synchronized(handlers) {
        if ([eventHandler respondsToSelector:s]) {
            NSMethodSignature *sig =   [eventHandler methodSignatureForSelector:s];
            NSInvocation *instance = [NSInvocation invocationWithMethodSignature:sig];
            [instance setSelector: s];
            [instance setTarget: eventHandler];
            // Retain is used here as the target and other args may go out of scope
            // and be automatially de-allocated by ARC. This way we ensure that the
            // various objects exist whenever we need to invoke a handler
            [instance retainArguments];
            [handlers setObject: instance forKey: type];
        }
    }
}

// Default is handleEvent: as the selector

-(void) register:(id<EventHandlerProtocol>)eventHandler forType:(NSString *)type {
    [self register: (id)eventHandler with: @selector(handleEvent:) forType: type];
}

-(void) deregister:(id)eventHandler forType:(NSString *)type{
    @synchronized(handlers) {
        if (eventHandler == [handlers objectForKey:type])
            [handlers removeObjectForKey:type];
    }
}
@end
