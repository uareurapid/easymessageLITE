//
//  CustomMessagesController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/6/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCViewController.h"

#define NUM_DEFAULT_MESSAGES 11

@interface CustomMessagesController : UITableViewController


@property (strong,nonatomic) NSMutableArray * messagesList;
@property NSInteger selectedMessageIndex;//the index of the selected message
@property NSString *selectedMessage;//the index of the selected message

//@property (strong,nonatomic) UIImage *lock;
//@property (strong,nonatomic) UIImage *unlock;

//@property (strong,nonatomic) UIView *headerView;

@property (strong,nonatomic) PCViewController *rootViewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewController;
-(NSString * ) getSelectedMessage;
@property BOOL addNewMessage;
@end
