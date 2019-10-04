//
//  CustomMessagesController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCViewController.h"
#import "FTPopOverMenu.h"
#import "Message.h"

#define NUM_DEFAULT_MESSAGES 11
#define SAVED_DEFAULT_MESSAGES @"saved_default_messages"

@interface CustomMessagesController : UITableViewController


@property (strong,nonatomic) NSMutableArray * messagesList;
@property NSInteger selectedMessageIndex;//the index of the selected message
@property (strong, nonatomic) Message *selectedMessage;//the index of the selected message


@property (strong,nonatomic) PCViewController *rootViewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewController;
-(Message * ) getSelectedMessage;
- (void)optionsClicked:(id)sender event:(UIEvent *)event;
-(void) editSelectedMessage;
-(void) addRecordsFromDatabase;
-(void) setForceReload:(BOOL) force;
@property BOOL addNewMessage;
@property BOOL forceReload;
@end

