//
//  Message.h
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-23.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Message : NSObject<NSCoding>{
    NSMutableDictionary *head;
    NSMutableDictionary *body;
}
@property(strong, nonatomic) NSMutableDictionary *head;
@property(strong, nonatomic) NSMutableDictionary *body;

- (void)getMessage:(NSData *)responseData;
+(Message*)initFromJSON: (NSData*)data;
-(NSData *)toJSON;
-(id) initHeadAndBody;
-(NSString*) toSring;


@end
