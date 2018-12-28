//
//  SelectRecipientsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import "Group.h"
#import "AddContactViewController.h"
#import "PickerView.h"
#import "ContactDataModel.h"


@class PCViewController;



@interface SelectRecipientsViewController : UITableViewController <UISearchBarDelegate,UISearchDisplayDelegate, UIPickerViewDataSource,UIPickerViewDelegate>

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts
   selectedOnes: (NSMutableArray *) selectedRecipients rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController;
-(void) addContactToGroup: (NSString *) groupName contact: (Contact *) contact;
-(void) removeContactFromGroup: (NSString *) groupName contact: (Contact *) contact;
@property (strong,nonatomic) AddContactViewController *addNewContactController;
-(BOOL) isContactModel: (ContactDataModel *) model sameAsContact: (Contact *)contact;

-(IBAction)refreshPhonebook:(id)sender;

-(void) deleteGroup:(Group *)group;
-(void) deleteContact:(Contact *)contact;

-(void) searchForBirthdayIn: (NSInteger) day month: (NSInteger) month;

-(void) reloadContacts: (NSMutableArray *) contacts;

@property (strong,nonatomic) NSMutableArray *contactsList;
@property (strong,nonatomic) NSMutableArray *groupsList;

@property (strong,nonatomic) NSMutableArray *selectedContactsList;
@property (strong,nonatomic) NSMutableArray * databaseRecords;
@property (strong,nonatomic) PCViewController *rootViewController;

@property (strong,nonatomic) NSMutableDictionary *contactsByLastNameInitial;

@property (strong,nonatomic) NSMutableArray *sortedKeys;
@property (strong,nonatomic) NSMutableArray *searchData;
@property (strong,nonatomic) NSMutableArray *searchDataSelection;

@property (strong,nonatomic)NSMutableArray *groupsNamesArray;

@property ABRecordID groupId;

@property (strong,nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) UISearchDisplayController *searchDisplayController;


//will hold a list of contacts per each letter

@property NSInteger initialSelectedContacts;
@property BOOL groupLocked;
@property BOOL reload;
@end
