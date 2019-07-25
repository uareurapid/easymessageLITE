//
//  ContactDetailsViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 16/12/2018.
//  Copyright © 2018 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
#import <ContactsUI/ContactsUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactDetailsViewController : UITableViewController <CNContactViewControllerDelegate>

@property (strong, nonatomic) NSObject *contactModel;
@property (strong, nonatomic) Contact *contact;
@property (assign, nonatomic) UIViewController *root;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow andModel: (NSObject *) model;
-(BOOL) isNativeContact;
-(void) showAddContactController;
-(void) closeNativeContactController:(id) sender;

@end

NS_ASSUME_NONNULL_END
