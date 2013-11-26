//
//  DetailViewController.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-03-29.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MasterProtocol

- (void)sendText:(NSString *)txt toUser: (NSString*) usr;


@end


@interface DetailViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>{
    NSMutableDictionary *messages;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) UIImage *userImage;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *activeField;
@property (strong, nonatomic) IBOutlet UIButton *send;
@property (strong, nonatomic) IBOutlet UITextView *text;
@property (strong, nonatomic) IBOutlet UITableView *usersTable;
@property (nonatomic, assign) id<MasterProtocol> delegate;

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *myself;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

-(IBAction) sendButtonPressed;
-(void) updateUsers: (NSMutableArray*) arr;
-(void) addText: (NSString*) msg fromUser: (NSString*) usr;
-(void) updateDict;
@end
