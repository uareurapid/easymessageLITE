//
//  AddContactViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 14/11/15.
//  Copyright © 2015 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (IBAction)btnCancelClicked:(id)sender;
- (IBAction)btnCreateContactClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)dateSwitchChanged:(id)sender;

//reference to recipients controller list
@property (strong,nonatomic) NSMutableArray *contactsList;
@property (assign, nonatomic) BOOL editMode;

@end
