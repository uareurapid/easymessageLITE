//
//  CustomMessagesController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "CustomMessagesController.h"
#import "EasyMessageIAPHelper.h"
#import "MessageDataModel.h"
#import "CoreDataUtils.h"
#import "CustomMessagesDetailController.h"

@interface CustomMessagesController ()

@end

@implementation CustomMessagesController

@synthesize messagesList,selectedMessage, selectedMessageIndex, rootViewController;
//lock,unlock;
//,headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewControllerArg {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"33-cabinet"];
        self.title = NSLocalizedString(@"archive",@"Archive");
        
        
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        
        self.navigationItem.rightBarButtonItem = optionsButton;
        //[addToGroupButton setEnabled:NO];
        [optionsButton setEnabled:YES];

        self.navigationController.toolbarHidden = NO;
        
        selectedMessageIndex = -1;
        selectedMessage = nil;
        self.rootViewController = rootViewControllerArg;
        
        //[self prepareCustomHeaderView];
        
    }
    return  self;
}


//the header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38;
}


-(void)viewWillAppear:(BOOL)animated {
    
    
    [self.navigationItem.leftBarButtonItem setEnabled: ![self isDefaultMessageSelected] ];
    
    [self.navigationItem.rightBarButtonItem setEnabled: YES];
    [self.tableView setAllowsSelection:YES];
    
    self.addNewMessage = ([self getSelectedMessageIfAny]==nil);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *force = [defaults objectForKey:@"force_msg_reload"];
    if(force!=nil && [force isEqualToString:@"force"]) {
        self.forceReload = true;
        [defaults removeObjectForKey:@"force_msg_reload"];
    }
    
    if(self.forceReload) {
        [self addRecordsFromDatabase];
    }
    
    
    //[self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}

-(IBAction)deleteMessageClicked:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                     message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                    delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag = 999;
    [alert show];
    
}

-(BOOL) isDefaultMessageSelected {
    
    return (selectedMessageIndex > -1 && selectedMessage!=nil && selectedMessage.isDefault.boolValue == TRUE);
}
//returns the selected message
-(Message * ) getSelectedMessageIfAny {
    
    if(messagesList.count == 0) {
        return nil;
    }
    if(selectedMessageIndex > -1 && selectedMessage!=nil && selectedMessageIndex < messagesList.count) {
        selectedMessage = [messagesList objectAtIndex:selectedMessageIndex];
        return selectedMessage;
    }
    return nil;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedMessageIndex = -1;
    selectedMessage = nil;
    
    self.forceReload = false;
    
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
    
    optionsButton.tintColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = optionsButton;
    //[addToGroupButton setEnabled:NO];
    [optionsButton setEnabled:YES];
    
    if(![self checkIfAlreadyDoneMessagesMigration]) {
        
        [self doMessagesMigration];
    } else {
        messagesList = [[NSMutableArray alloc] init];
        [self addRecordsFromDatabase];
    }
    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(BOOL) checkIfAlreadyDoneMessagesMigration {
    
    //do not have this saved on core data yet, save them now
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:SAVED_DEFAULT_MESSAGES]!=nil;
    
}
//save them on core data
-(BOOL) doMessagesMigration {
    
    //load default list from localized
    [self loadDefaultMessagesFromLocalized];
    
    BOOL ok = true;
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    for(Message *message in messagesList) {
        
        MessageDataModel *messageModel = (MessageDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
        messageModel.msg = message.msg;
        messageModel.isDefault = @YES;
        messageModel.creationDate = message.creationDate;
        
        //BOOL OK = NO;
        NSError *error;
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object, error is: %@",error.description);
            ok = false;
        }
    }
    
    if(ok) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"true" forKey:SAVED_DEFAULT_MESSAGES];
        return true;
    }
    
    return false;
}

-(void) loadDefaultMessagesFromLocalized {
    
    messagesList = [[ NSMutableArray alloc] initWithCapacity:NUM_DEFAULT_MESSAGES];
    
    NSDate *date = [NSDate date];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_christmas",@"Merry Christmas") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_birthday",@"Happy Birthday") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_whereareyou",@"Where are you?") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_whataredoing",@"What are you doing?") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_callback",@"Call back. Please") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_busy",@"Busy now. Call later please") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_meeting",@"Sorry, i have a meeting now") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_callsoon",@"Call you soon") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_noworry",@"Don´t worry. I´m fine") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_wayhome",@"On my way home now") defaultMessage:@YES date: date]];
    [messagesList addObject: [[Message alloc] initWithText:NSLocalizedString(@"custom_msg_arrivesoon",@"I´ll Arrive soon") defaultMessage:@YES date: date]];
    
    /*initWithObjects:NSLocalizedString(@"custom_msg_christmas",@"Merry Christmas"),
     NSLocalizedString(@"custom_msg_birthday",@"Happy Birthday"),
     NSLocalizedString(@"custom_msg_whereareyou",@"Where are you?"),
     NSLocalizedString(@"custom_msg_whataredoing",@"What are you doing?"),
     NSLocalizedString(@"custom_msg_callback",@"Call back. Please"),
     NSLocalizedString(@"custom_msg_busy",@"Busy now. Call later please"),
     NSLocalizedString(@"custom_msg_meeting",@"Sorry, i have a meeting now"),
     NSLocalizedString(@"custom_msg_callsoon",@"Call you soon"),
     NSLocalizedString(@"custom_msg_noworry",@"Don´t worry. I´m fine"),
     NSLocalizedString(@"custom_msg_wayhome",@"On my way home now"),
     NSLocalizedString(@"custom_msg_arrivesoon",@"I´ll Arrive soon"),nil];*/
    
    [self.tableView reloadData];
}


//called on viewAppear
-(void) addRecordsFromDatabase {
    
    NSLog(@"addRecordsFromDatabase");
    
    //make sure we load the default ones first
    NSMutableArray *databaseRecordsUnsorted = [CoreDataUtils fetchMessageRecordsFromDatabase];
    NSMutableArray *databaseRecords = [[NSMutableArray alloc] initWithCapacity:databaseRecordsUnsorted.count];
    
    //make sure the order is the creation date
    if(databaseRecordsUnsorted.count > 0) {
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate"
                                                     ascending:NO];
        [databaseRecords addObjectsFromArray: [databaseRecordsUnsorted sortedArrayUsingDescriptors:@[sortDescriptor]] ];
    }
    
    if(self.forceReload) {
        [self.messagesList removeAllObjects];
    }
    
    BOOL add = NO;
    for(MessageDataModel *model in databaseRecords) {
        
        Message *toAdd = [[Message alloc] initWithText:model.msg defaultMessage:model.isDefault date: model.creationDate];
        
        if(![messagesList containsObject:toAdd]) {
            
            [messagesList addObject:toAdd];
            //NSLog(@"Adding message %@ default? %d", toAdd.msg, toAdd.isDefault.boolValue);
            add = YES;
        }
        
    }
    
    
    //preserve selection
    //after updating the list i can update on main panel too
    Message *currentSelection = [self getSelectedMessageIfAny];
    if(currentSelection!=nil && selectedMessageIndex != -1) {
        [self selectionFinishWithoutNavigation];
    }
    
    
    
    //TODO check
    if(add || self.forceReload ) {
        NSLog(@"will reload messages");
        self.forceReload = false;
        [self.tableView reloadData];
       
    }
}

- (void) setForceReloadMSG:(BOOL) force {
    
    if(force) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@"force" forKey:@"force_msg_reload"];
        [defaults synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) deleteSelectedMessage {
    Message *msg = [self getSelectedMessageIfAny];
    if(msg!=nil) {
        
        [messagesList removeObject:msg];
        
        BOOL deleted = [CoreDataUtils deleteMessageDataModelByMsg:msg];
        if(deleted) {
            
            //clear stuff
            selectedMessage = nil;
            selectedMessageIndex = -1;
            self.rootViewController.body.text = @"";
            
            [self.tableView reloadData];
            [self.navigationItem.leftBarButtonItem setEnabled:NO];
            
            [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
            
        }
    }
}

-(void) showAlertBox:(NSString *) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void) createNewMessage {
    
    if(self.messagesList.count > 15 &&  ![[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
        [self showAlertBox:NSLocalizedString(@"lite_only_5_contacts_template_messages", nil)];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"compose",@"compose") message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"save",@"save"),nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        [alert show];
    }
    
}
//the delegate for the new Group
//TODO create message on new popup view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
        
        //delete message
        if(alertView.tag == 999) {
            [self deleteSelectedMessage];
            return;
        }
        //else save message on database!
        NSString *message = [alertView textFieldAtIndex:0].text;
        //NSLog(@"message is %@",message);
        if(message.length==0) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"alert_message_body_empty",@"alert_message_body_empty") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            //check if exists already
            BOOL exists = false;
            //NSLog(@"checking if exists");
            
            Message *toAdd = [[Message alloc] initWithText:message defaultMessage:@NO date: [NSDate date] ];
            for(Message *msg in messagesList) {
                NSLog(@"model msg: %@",msg);
                if([msg isEqual:toAdd]) {
                    exists = true;
                }
                
            }
            if(!exists) {
                NSLog(@"not exists adding: %@",message);
                NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
                MessageDataModel *messageModel = (MessageDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
                messageModel.msg = message;
                messageModel.isDefault = @NO;
                
                //BOOL OK = NO;
                NSError *error;
                if(![managedObjectContext save:&error]){
                    NSLog(@"Unable to save object, error is: %@",error.description);
                }
                else {
                    //add to list and reload table
                    [messagesList addObject:toAdd];
                    [self.tableView reloadData];
                    //show a success toast
                    [[[[iToast makeText:NSLocalizedString(@"added", @"added")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                }
            }
            else {
                //group name already exists
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"message_already_exists",@"message_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            
        }
        
        
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return messagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    
    
    // Configure the cell...
    if(row < messagesList.count) {
        
        Message *msg = (Message *)[messagesList objectAtIndex:row];
        //paranoid check
        cell.textLabel.text = msg.msg;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)row];
        
        if(row == selectedMessageIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row =  indexPath.row;
    
    if(row==selectedMessageIndex) {
        selectedMessageIndex = -1;
        selectedMessage = nil;
        [self clearRootMessageText];
        //Nothing selected
        
        self.addNewMessage = YES;
        
        //[self.navigationItem.leftBarButtonItem setEnabled:NO];//no delete
        //NOTE if the item is not purchased selection is not even possible
    }
    else {
        selectedMessageIndex = row;
        selectedMessage = [messagesList objectAtIndex:selectedMessageIndex];
        //[self.navigationItem.rightBarButtonItem setEnabled:YES];//can save
        self.addNewMessage = NO;
        
        //write the message on the main screen without apply
        [self selectionFinishWithoutNavigation];
    }
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
     if(self.addNewMessage){
     [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"add", @"add")];
     }
     else{
     [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"done_button", @"done_button")];
     }
     });*/
    
    
    [self.tableView reloadData];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     
     */
}
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return NSLocalizedString(@"select_custom_message",@"select a message");
    }
    return @"";
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==0 && selectedMessageIndex!=-1 &&  selectedMessageIndex < messagesList.count) {
        
        Message *msg = (Message *)[messagesList objectAtIndex:selectedMessageIndex];
        return [NSString stringWithFormat: @"%@ '%@'",NSLocalizedString(@"selected_message",@"Selected message"), msg.msg];
    }
    return @"";
}

//done with the message selection
-(IBAction)selectFinished:(id)sender {
    //go back to compose
    
    if(self.addNewMessage) {
        [self createNewMessage];
    }
    else {
        if(selectedMessageIndex!=-1 && selectedMessage!=nil) {
            self.rootViewController.body.text = selectedMessage.msg;
        }
        
        [self.tabBarController setSelectedIndex:0];
    }
    
    
}

-(void) clearRootMessageText{
    if(selectedMessageIndex==-1 || selectedMessage==nil) {
        self.rootViewController.body.text = @"";
    }
}

-(void) selectionFinishWithoutNavigation{
    if(selectedMessageIndex!=-1 && selectedMessage!=nil) {
        self.rootViewController.body.text = selectedMessage.msg;
    }
}

- (void)optionsClicked:(id)sender event:(UIEvent *)event{
    [self showMenu:sender withEvent: event];
}

-(void) editSelectedMessage {
    
    
    CustomMessagesDetailController *detailViewController = [[CustomMessagesDetailController alloc] initWithNibName:@"CustomMessagesDetailController" bundle:nil previousController:self message: self.selectedMessage];
    
    //search and set the model
    NSMutableArray *databaseRecords = [CoreDataUtils fetchMessageRecordsFromDatabase];
    
    for(MessageDataModel *model in databaseRecords) {
        NSLog(@"COMPARE MODEL msg: %@ selected msg: %@, model isDefault? %d selected isDefault? %d", model.msg, selectedMessage.msg, model.isDefault.boolValue, selectedMessage.isDefault.boolValue );
        if([model.msg isEqualToString:self.selectedMessage.msg] && (model.isDefault.boolValue == self.selectedMessage.isDefault.boolValue) ) {
            detailViewController.model = model;
            break;
        }
    }
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (void) showMenu:(id)sender withEvent: (UIEvent *)event
{
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor whiteColor];
    configuration.menuWidth = 200;
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    configuration.separatorColor = [delegate colorFromHex:0xfb922b];
    
    Message *selected = [self getSelectedMessageIfAny];
    //has selection
    if(selected!=nil) {
        
        if( [self isDefaultMessageSelected]) {
            //OPTIONS:
            // Edit
            // Add
            [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"edit", nil), NSLocalizedString(@"add",@"add")]
                              imageArray:@[@"edit40", @"add"]
                           configuration:configuration
                               doneBlock:^(NSInteger selectedIndex) {
                                   NSLog(@"selected %ld", (long)selectedIndex);
                                   if(selectedIndex == 0) {
                                       //todo edit
                                       [self editSelectedMessage];
                                       
                                   } else {
                                       //add
                                       [self createNewMessage];
                                       //no delete
                                   }
                                   
                               } dismissBlock:^{
                                   
                               }];
        } else {
            //OPTIONS:
            // Edit
            // Delete
            // Add
            //mageArray:@[@"edit40",@"delete"]
            [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"edit", nil),NSLocalizedString(@"delete", nil), NSLocalizedString(@"add",@"add")]
                              imageArray:@[@"edit40",@"delete",@"add"]
                           configuration:configuration
                               doneBlock:^(NSInteger selectedIndex) {
                                   NSLog(@"selected %ld", (long)selectedIndex);
                                   if(selectedIndex == 0) {
                                       //todo edit
                                       [self editSelectedMessage];
                                   } else if(selectedIndex == 1) {
                                       //delete
                                       [self deleteMessageClicked:nil];
                                   }
                                   else {
                                       [self createNewMessage];
                                   }
                               } dismissBlock:^{
                                   
                               }];
        }
        
        
    } else {
        
        //no selection
        //OPTIONS:
        //Add
        [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"add",@"add")]
                          imageArray:@[@"add"]
                       configuration:configuration
                           doneBlock:^(NSInteger selectedIndex) {
                               NSLog(@"selected %ld", (long)selectedIndex);
                               if(selectedIndex == 0) {
                                   [self createNewMessage];
                               }
                           } dismissBlock:^{
                               
                           }];
    }
}

@end

