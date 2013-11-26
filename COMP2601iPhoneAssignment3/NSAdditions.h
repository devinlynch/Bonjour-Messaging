//
//  NSAdditions.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (NSDataAdditions)
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger) lineLength;

- (BOOL) hasPrefixBytes:(const void *) prefix length:(NSUInteger) length;
- (BOOL) hasSuffixBytes:(const void *) suffix length:(NSUInteger) length;
@end
