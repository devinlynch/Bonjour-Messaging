//
//  LoginViewController.m
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) loginButtonPressed{
    if(![username.text isEqualToString:@""])
    [self performSegueWithIdentifier:@"login" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    MasterViewController *next = [segue destinationViewController];
    next.myUsername = username.text;
}

@end
