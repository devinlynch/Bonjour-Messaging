//
//  MasterViewController.m
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-03-29.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import "MasterViewController.h"
#import "GCDAsyncSocket.h"
#import "DetailViewController.h"
#import "NSAdditions.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
- (void)connectToNextAddress;
@end

@implementation MasterViewController

@synthesize serverServices, myUsername;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    text = [[NSString alloc] init];
    
    serverServices = [[NSMutableArray alloc] init];
    
    server = [[BonjourServer alloc] init];
    users = [[NSMutableArray alloc] init];
        
    [self startClient];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////
//
// Table View Delegates
//
/////////////////////////////////////////////

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self enterChatroom:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSString *object = _objects[indexPath.row];
    cell.textLabel.text = object;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/////////////////////////////////////////////
//
// Client Utils
//
/////////////////////////////////////////////

// Adds a new server to the table view
- (void)insertNewServer:(NSString*)obj
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject: obj atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// Sends text message to server
-(void) sendText:(NSString*)txt toUser:(NSString*) usr
{
    [self sendTextMessage:txt ForSocket:asyncSocket toUser:usr];
}

// Sends data to destinated view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        DetailViewController *dvc = [segue destinationViewController];
        dvc.myself = myUsername;
        dvc.users = users;
        dvc.delegate = self;
        dvc.userImage = userImage;
        [dvc setDetailItem:object];
        detailVC = dvc;
    }
}

-(void) startServer{
    [server startServer];
}

- (void)startClient
{
	netServiceBrowser = [[NSNetServiceBrowser alloc] init];
	
	[netServiceBrowser setDelegate:self];
	[netServiceBrowser searchForServicesOfType:@"_im._tcp." inDomain:@""];
}

// Updates the list of services available
-(void) updateInterface{
    int i = 1;
    for(NSNetService* service in self.serverServices){
        if (service.port == -1) {
            NSLog(@"service %@ of type %@, not yet resolved",
                  service.name, service.type);
            if(![_objects containsObject:[NSString stringWithFormat:@"Chatroom %d", i]])
                [self insertNewServer: [NSString stringWithFormat:@"Chatroom %d", i]];

        } else {
            NSLog(@"service %@ of type %@, port %i, addresses %@",
                  service.name, service.type, service.port, service.addresses);
        }
        ++i;
    }
}

-(void) enterChatroom: (int) num{
    NSNetService *service = [serverServices objectAtIndex:num];
    [service setDelegate:self];
    [service resolveWithTimeout:10];
}

/////////////////////////////////////////////
//
// NSNetServiceBrowser Delegates
//
/////////////////////////////////////////////

-(void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser{
    NSLog(@"Starting search");
    NSOperationQueue *queue = [NSOperationQueue new];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(detectNoServer)
                                                                              object:nil];
    [queue addOperation:operation];
}

// Waits 3 seconds, if no server found then creates one
-(void) detectNoServer{
    NSDate *then = [NSDate date];
    while(1){
        NSDate *now = [NSDate date];
        NSTimeInterval execution = [now timeIntervalSinceDate:then];
        
        if(execution > 2)
            break;
    }
    
    [self startServer];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
{
	NSLog(@"DidNotSearch: %@", errorInfo);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	NSLog(@"DidFindService: %@, more coming: %c", [netService name], moreServicesComing);
	
    
    [self.serverServices addObject:netService];
    if (!moreServicesComing)
        [self updateInterface];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
	NSLog(@"DidRemoveService: %@", [netService name]);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
	NSLog(@"DidStopSearch");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"DidNotResolve");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Could not resolve service"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"DidResolve: %@", [sender addresses]);
	
    serverAddresses = [[sender addresses] mutableCopy];
	
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
		
    [self connectToNextAddress];
}

- (void)connectToNextAddress
{
	BOOL done = NO;
	
	while (!done && ([serverAddresses count] > 0))
	{
		NSData *addr;
		
		if (YES) // Iterate forwards
		{
			addr = [serverAddresses objectAtIndex:0];
			[serverAddresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [serverAddresses lastObject];
			[serverAddresses removeLastObject];
		}
		
		NSLog(@"Attempting connection to %@", addr);
		
		NSError *err = nil;
		if ([asyncSocket connectToAddress:addr error:&err])
		{
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}
		
	}
	
	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
	}
}

/////////////////////////////////////////////
//
// GCDAsync Socket Delegates
//
/////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
    asyncSocket = sock;
    [asyncSocket performBlock:^{
        [asyncSocket enableBackgroundingOnSocket];
    }];
    hasLoggedIn = false;
    
    text = [text stringByAppendingString:[NSString stringWithFormat:@"Socket:DidConnectToHost: %@ Port: %hu", host, port]];
    
    [self sendLoginMessageForSocket:sock];
    [sock readDataToData: [GCDAsyncSocket CRLFData] withTimeout: -1 tag: -1];
    
	connected = YES;
    
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"SENT DATA in client");
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    Message* msg = [Message initFromJSON:data];
    
    NSLog(@"READ DATA in client: %@", msg.head);
    
    [self handleMessage:msg];
    
    [sock readDataToData: [GCDAsyncSocket CRLFData] withTimeout: -1 tag: -1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);
	
	if (!connected)
	{
		[self connectToNextAddress];
	}
}

/////////////////////////////////////////////
//
// Message Senders
//
/////////////////////////////////////////////

// Send a login message on a given socket
-(void) sendLoginMessageForSocket: (GCDAsyncSocket *) sock{
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"LOGIN" forKey:@"type"];
    [[msg body] setValue:myUsername forKey:@"sender"];
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    [sock writeData:data withTimeout:-1 tag:-1];
    [sock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
}

// Sends a logout message to server
-(void) sendLogoutMessageForSocket:(GCDAsyncSocket *)sock{
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"LOGOUT" forKey:@"type"];
    [[msg body] setValue:myUsername forKey:@"sender"];
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    [sock writeData:data withTimeout:-1 tag:-1];
    [sock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
    [asyncSocket disconnectAfterWriting];
    NSLog(@"DONE WRITING LOGOUT");
}

-(void) sendTextMessage:(NSString*) message ForSocket:(GCDAsyncSocket *)sock toUser:(NSString *)usr{
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"TEXT" forKey:@"type"];
    [[msg body] setValue:myUsername forKey:@"sender"];
    [[msg body] setValue:usr forKey:@"receiver"];
    [[msg body] setValue:message forKey:@"message"];
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    [sock writeData:data withTimeout:-1 tag:-1];
    [sock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
}


/////////////////////////////////////////////
//
// Message Handlers
//
/////////////////////////////////////////////


-(void) handleMessage: (Message*) message{
    NSDictionary *head = [message head];
    NSString *type = [head objectForKey:@"type"];
    NSLog(@"Type: %@", type);
    if([type isEqualToString:@"LOGIN"]){
        [self handleLoginMessage:message];
    } else if([type isEqualToString:@"LOGOUT"]){
        [self handleLogoutMessage:message];
    } else if([type isEqualToString:@"TEXT"]){
        [self handleTextMessage:message];
    }
}

-(void) handleLoginMessage: (Message*) message{
    NSDictionary *body = [message body];
    if([body objectForKey:@"users"] != nil)
        users = [body objectForKey:@"users"];
    NSLog(@"Handled login rec users: %@", users);
    
    if(!hasLoggedIn){        
        NSString *imageString = [body objectForKey:@"sender"];
        NSData * data = [NSData dataWithBase64EncodedString:imageString];
        UIImage *image1 = [UIImage imageWithData:data];
        
        userImage = image1;
        hasLoggedIn = true;
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    } else{
        [detailVC updateUsers:users];
    }
}

-(void) handleLogoutMessage: (Message*) message{
    NSDictionary *body = [message body];
    if([body objectForKey:@"users"] != nil)
        users = [body objectForKey:@"users"];
    NSLog(@"Handled logout rec users: %@", users);
    
    [detailVC updateUsers:users];
}

-(void) handleTextMessage:(Message *)message{
    
    NSDictionary *body = [message body];
    if([body objectForKey:@"users"] != nil)
        users = [body objectForKey:@"users"];
    
    NSString *sender = [body objectForKey:@"sender"];
    NSString *msg = [body objectForKey:@"message"];
    [self createNotif: [NSString stringWithFormat:@"%@: %@", sender, msg]];
    NSLog(@"Handled text message: %@ from user: %@", msg, sender);
    
    if(hasLoggedIn)
        [detailVC addText: msg fromUser: sender];
}

/////////////////////////////////////////////
//
// Application Delegate
//
/////////////////////////////////////////////

// Logs user out when they return from chat room
-(void) viewWillAppear:(BOOL)animated{
    if(hasLoggedIn)
        [self sendLogoutMessageForSocket:asyncSocket];
}

// Attempts to send logout message if applicaiton is terminated
-(void) applicationWillTerminate:(UIApplication *)application{
    if(hasLoggedIn)
        [self sendLogoutMessageForSocket:asyncSocket];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BOOL isInBackground = YES;
    BOOL backgroundAccepted = [[UIApplication sharedApplication]
                               setKeepAliveTimeout:600 handler:^{ [self backgroundHandler]; }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
    }
    [self backgroundHandler];
}

-(void) backgroundHandler{
    NSLog(@"Background handler");
    UIApplication*    app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL haveSentLogout = false;
        while (1)
        {
            if(!haveSentLogout)
                [self sendLogout];
            haveSentLogout = true;
            [asyncSocket readDataToData: [GCDAsyncSocket CRLFData] withTimeout: -1 tag: -1];
            sleep(5);
        }
    });
}


-(void) sendLogout{
    NSLog(@"Logout sent");
    [self sendLogoutMessageForSocket:asyncSocket];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"Recieved Notification %@",localNotif);
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications]; 
    return YES;
}


-(void) createNotif: (NSString*) bdy{
    //Add next local notification
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;                  //Error (old iOS version?)
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.applicationIconBadgeNumber = 1;    //Fixed badge number (must be known at creation time - can't gbe set to increment etc)
    
    //TO DISPLAY A MESSAGE
    //Set Alert Text (appears under app name)
    localNotif.alertBody = bdy;
    //Set the action button label (appears with the 'Close' button)
    localNotif.alertAction = NSLocalizedString(@"View", nil);
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    NSLog(@"Recieved Notification %@",notif);
}

@end
