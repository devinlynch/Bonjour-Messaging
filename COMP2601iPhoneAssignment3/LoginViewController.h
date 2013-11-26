//
//  LoginViewController.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController{
    IBOutlet UIButton *login;
    IBOutlet UITextField *username;
}
-(IBAction) loginButtonPressed;
@end
