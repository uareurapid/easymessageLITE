//
//  AddContactViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 14/11/15.
//  Copyright © 2015 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface AddContactViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnAddContact;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *labelLastname;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnCreateContactClicked:(id)sender;
-(void) updateExistingContact;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)dateSwitchChanged:(id)sender;

//reference to recipients controller list
@property (strong,nonatomic) NSMutableArray *contactsList;
@property (assign, nonatomic) BOOL editMode;
@property (strong, nonatomic) NSObject *contactModel; //in edit mode
@property (strong, nonatomic) Contact *contact; //in edit mode
-(BOOL) isNativeContact;

@end
