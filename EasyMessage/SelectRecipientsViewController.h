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
#import "FTPopOverMenu.h"
//new contacts framework
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "CMPopTipView.h"

@class PCViewController;



@interface SelectRecipientsViewController : UITableViewController <UISearchBarDelegate,UISearchResultsUpdating, UIPickerViewDataSource,UIPickerViewDelegate, CMPopTipViewDelegate>

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts
   selectedOnes: (NSMutableArray *) selectedRecipients rootViewController: (PCViewController*) viewController;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController;
-(void) addContactToGroup: (NSString *) groupName contact: (Contact *) contact isSingleInsert: (BOOL) single;
-(void) removeContactFromGroup: (NSString *) groupName contact: (Contact *) contact;
@property (strong,nonatomic) AddContactViewController *addNewContactController;
-(BOOL) isContactModel: (ContactDataModel *) model sameAsContact: (Contact *)contact;
-(UIImage*) drawText:(NSString*) text inImage:(UIImage*) image atPoint:(CGPoint) point;
-(NSString *) getInitialsFromContact: (NSString *) firstString andLastString: (NSString *) lastString;
-(void) createFilteredList: (NSString *) filterOption;
-(BOOL) onlyHasNativeiCloudGroups;
-(IBAction)refreshPhonebook:(id)sender;
-(void) addMultipleContactsToGroup: (NSString *) groupName;
-(void) deleteGroup:(Group *)group;
-(void) deleteContact:(Contact *)contact;

-(void) searchForBirthdayIn: (NSInteger) day month: (NSInteger) month;
-(void)searchAndDeleteContactInContactsList: (Contact *)contact;
-(void) showPermissionsMessage;
-(void) reloadContacts: (NSMutableArray *) contacts;
-(CNMutableContact*) searchContactOnNativeAddressBook: (Contact *) contact;
-(NSMutableArray *) findRecipientsFromScheduledModel: (NSMutableArray *) recipientsList;
-(BOOL) isNativeContact:(Contact *) contact;
//visible api
-(void)clearRecipients;

//filtered list
@property (strong,nonatomic) NSMutableArray *filteredContactsList;

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
@property (strong,nonatomic) UISearchController *searchController;

@property (strong,nonatomic) CMPopTipView *tooltipView;
@property BOOL isShowingTooltip;

//will hold a list of contacts per each letter

@property NSInteger initialSelectedContacts;
@property BOOL groupLocked;
@property BOOL reload;
@property BOOL isFiltered;
@end
