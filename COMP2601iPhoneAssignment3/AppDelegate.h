//
//  AppDelegate.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-03-29.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol appProtocol
-(void) logoutUser;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
