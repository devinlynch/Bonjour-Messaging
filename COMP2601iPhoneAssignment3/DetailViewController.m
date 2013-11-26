//
//  DetailViewController.m
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-03-29.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import "DetailViewController.h"
#import "CustomCell.h"
#import "ChatImage.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize scrollView, activeField, users, send, text, usersTable, user, delegate, userImage, myself;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        [self configureView];
    }
}

- (void)configureView
{
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [usersTable setDelegate:self];
    [usersTable setDataSource:self];
    
    [send setEnabled:false];
    [text setEditable:false];
    
    [usersTable reloadData];
    [self registerForKeyboardNotifications];
    [activeField setDelegate:self];
    [text setText:@""];
    messages = [[NSMutableDictionary alloc] init];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void) updateUsers:(NSMutableArray *)arr{
    // Updates the users array
    users = arr;
    if(![users containsObject:user]){
        [text setText:@""];
    }
    [usersTable reloadData];
    [self updateDict];
}

-(void) updateDict{
    // Updates the dictionary of texts to have a key for all users
    for (NSString* usr in users){
        if([messages objectForKey:usr] == nil){
            NSLog(@"Set key for usr: %@", usr);
            [messages setObject:@"" forKey:usr];
        }
    }
}

-(void) addText:(NSString *)msg fromUser:(NSString *)usr{
    // Adds the text to the corresponding view text box
    NSString *txt = [messages objectForKey:usr];
    txt = [txt stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", usr, msg]];
    [messages setObject:txt forKey:usr];
    [text setText:[messages objectForKey:user]];
}

-(IBAction)sendButtonPressed{
    // On send button pressed, send text to server and update UI
    // to show text sent
    [self.delegate sendText:activeField.text toUser: user];    
    NSString *txt = [messages objectForKey:user];
    txt = [txt stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", myself, activeField.text]];
    [messages setObject:txt forKey:user];
    [text setText:[messages objectForKey:user]];
    [activeField setText:@""];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return users.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDict];
    if(users.count > 0){
        static NSString *CellIdentifier = @"CustomCell";
        
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[CustomCell class]])
                {
                    cell = (CustomCell *)currentObject;
                    break;
                }
            }
        }
        NSString *object = [users objectAtIndex:indexPath.row];;
        [[cell name] setText:object];
        [[cell img] setImage:[ChatImage imageForUser:object]];
        
        cell.userInteractionEnabled = true;
        
        if(cell!=nil)
            return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = @"No names found.";
    cell.userInteractionEnabled = false;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [send setEnabled:true];
    user = [users objectAtIndex:indexPath.row];
    [text setText:[messages objectForKey:user]];
}

#pragma mark - Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(100, 0, 0, 0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


@end
