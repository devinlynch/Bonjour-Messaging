//
//  ChatImage.m
//  Lecture12
//
//  Created by Devin Lynch on 2013-03-21.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import "ChatImage.h"

@implementation ChatImage

static NSMutableDictionary *images = nil;
static NSString *URL = @"http://sikaman.dyndns.org:8888/courses/2601/data/imgs/%@.jpg";
static NSString *DEFAULT = @"default";

+(UIImage*)defaultImage{
   return [self imageForUser: DEFAULT];
}

+(UIImage*)imageForUser: (NSString *)user {
   if (images == nil)
      images = [[NSMutableDictionary alloc] init ];

   UIImage *image = [images objectForKey: user];
   if (image == nil) {
      NSString *url = [NSString stringWithFormat: URL, user];
      NSURL *imageURL = [NSURL URLWithString: url];
      image = [UIImage imageWithData: [NSData dataWithContentsOfURL: imageURL]];
      if (image != nil) {
         [images setObject: image forKey: user];
      } else if ([user compare: DEFAULT] != 0)
         return [self imageForUser: DEFAULT];
   }
   return image;
}

@end
