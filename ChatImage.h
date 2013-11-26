//
//  ChatImage.h
//  Lecture12
//
//  Created by Devin Lynch on 2013-03-21.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatImage : NSObject

+(UIImage *)defaultImage;
+(UIImage *)imageForUser: (NSString *)user;
@end
