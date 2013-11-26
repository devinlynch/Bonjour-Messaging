//
//  MasterViewController.h
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-03-29.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

@class GCDAsyncSocket;
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BonjourServer.h"
#import "Message.h"
#import "DetailViewController.h"

@interface MasterViewController : UITableViewController<NSNetServiceBrowserDelegate, NSNetServiceDelegate, MasterProtocol, UIApplicationDelegate>
{
    // LOG
    NSString *text;
    
    //Server
    BonjourServer *server;
    // Client stuff
    NSNetServiceBrowser *netServiceBrowser;
	NSNetService *serverService;
	NSMutableArray *serverAddresses;
    NSMutableArray *serverServices;
    NSMutableArray *sockets;
	GCDAsyncSocket *asyncSocket;
	BOOL connected;
    BOOL hasLoggedIn;
    
    //UI
    DetailViewController *detailVC;
    UIImage *userImage;
    UIBackgroundTaskIdentifier bgTask;
    BOOL hasCreatedServer;
    
    // Message stuff
    NSMutableArray *users;
    NSString *myUsername;
}

@property (strong) NSMutableArray *serverServices;
@property (strong) NSString *myUsername;
@property (strong, nonatomic) UIWindow *window;


//Utils
-(void) detectNoServer;
-(void) insertNewServer;
-(void) updateInterface;
-(void) enterChatroom: (int) num;

// Server stuff
-(void) startServer;
-(void) startClient;

// Handlers
-(void) handleMessage: (Message*) message;
-(void) handleLoginMessage: (Message*) message;
-(void) handleTextMessage: (Message*) message;

// Message stuff
-(void) sendLoginMessageForSocket: (GCDAsyncSocket *) sock;
-(void) sendTextMessage:(NSString*) message ForSocket:(GCDAsyncSocket *)sock toUser:(NSString *)usr;
-(void) sendLogoutMessageForSocket: (GCDAsyncSocket *) sock;
@end
