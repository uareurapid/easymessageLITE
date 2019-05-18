//
//  AddContactViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 14/11/15.
//  Copyright © 2015 Paulo Cristo. All rights reserved.
//

#import "AddContactViewController.h"
#import "ContactDataModel.h"
#import "Contact.h"
#import "PCAppDelegate.h"
#import "iToast.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

@interface AddContactViewController ()

@end

//TODO README how to center this http://stackoverflow.com/questions/26471661/auto-layout-xcode-6-centering-ui-elements

@implementation AddContactViewController

@synthesize editMode, contact, contactModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self.btnAddContact setTitle:NSLocalizedString(@"create_contact",@"create_contact") forState:UIControlStateNormal];
    [self.btnCancel setTitle:NSLocalizedString(@"cancel",@"cancel") forState:UIControlStateNormal];
    
    self.btnAddContact.layer.borderWidth = 1.5f;
    self.btnAddContact.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.btnCancel.layer.borderWidth = 1.5f;
    self.btnCancel.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.title = NSLocalizedString(@"new_contact", @"new_contact");
    
    self.txtPhone.delegate = self;
    self.txtName.delegate=self;
    self.txtLastName.delegate=self;
    self.txtEmail.delegate=self;
    self.datePicker.userInteractionEnabled = YES;
    
    [self.labelEmail setText: [NSString stringWithFormat:@"%@:", NSLocalizedString(@"contact_email",@"contact_email")] ];
    [self.labelPhone setText: [NSString stringWithFormat:@"%@:",NSLocalizedString(@"phone_label",@"phone_label")] ];
    [self.labelName setText: [NSString stringWithFormat:@"%@:(*)",NSLocalizedString(@"contact_name",@"contact_name")] ];
    [self.labelLastname setText: [NSString stringWithFormat:@"%@:",NSLocalizedString(@"contact_last_name",@"contact_last_name")] ];
    
}
- (void)viewWillAppear:(BOOL)animated {
    if(self.editMode && self.contact!=nil) {
        //populate fields
        if(self.contact.name!=nil) {
            self.txtName.text = self.contact.name;
        }
        if(self.contact.phone!=nil) {
            self.txtPhone.text = self.contact.phone;
        }
        if(self.contact.email!=nil) {
            self.txtEmail.text = self.contact.email;
        }
        if(self.contact.lastName!=nil) {
            self.txtLastName.text = self.contact.lastName;
        }
        if(self.contact.birthday!=nil) {
            //self.datePicker.enabled = true;
            self.datePicker.date = self.contact.birthday;
        }
    } else {
        
        //clear all
        self.txtName.text = @"";
        self.txtPhone.text = @"";
        self.txtEmail.text = @"";
        self.txtLastName.text = @"";
        //self.datePicker.enabled = false;
    }
}

- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
      return self;  
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //if(textField == subject) {
        [textField resignFirstResponder];
    //    return YES;
    //}
    
    return YES;
}

-(void) updateExistingContact{
    
    
    NSDate *birthday = self.datePicker.date;
    //name OK, save it!
    contact.name = self.txtName.text;
    contact.birthday = birthday;
    contact.phone = self.txtPhone.text.length==0 ? @"" : self.txtPhone.text;
    contact.email = self.txtEmail.text.length==0 ? @"" : self.txtEmail.text;
    contact.lastName = self.txtLastName.text.length==0? @"": self.txtLastName.text;
    
    NSLog(@"-----------------------------------");
    NSLog(@"contact name: %@",contact.name);
    NSLog(@"contact birthday: %@",contact.birthday.description);
    NSLog(@"contact phone: %@",contact.phone);
    NSLog(@"contact last name: %@",contact.lastName);
    NSLog(@"-----------------------------------");
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    ContactDataModel *contactModel = (ContactDataModel *) self.contactModel;
    //copy the new values
    contactModel.email = contact.email;
    contactModel.birthday = contact.birthday;
    contactModel.phone = contact.phone;
    contactModel.lastname = contact.lastName;
    contactModel.name = contact.name;
    
    BOOL OK = NO;
    NSError *error;
    
    if(![managedObjectContext save:&error]){
        [[[[iToast makeText: [NSString stringWithFormat:@"Unable to save object, error is: %@",error.description]]
           setGravity:iToastGravityBottom] setDuration:2000] show];
        NSLog(@"Unable to save object, error is: %@",error.description);
        //This is a serious error saying the record
        //could not be saved. Advise the user to
        //try again or restart the application.
        
    }
    else {
        
        NSLog(@"-----------------------------------");
        NSLog(@"contactModel name: %@",contactModel.name);
        NSLog(@"contactModel birthday: %@",contactModel.birthday.description);
        NSLog(@"contactModel phone: %@",contactModel.phone);
        NSLog(@"contactModel last name: %@",contactModel.lastname);
        NSLog(@"-----------------------------------");
        
        OK = YES;
        
        [[[[iToast makeText:NSLocalizedString(@"added",@"added")]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    if(OK) {
        //add to the list
        [self.contactsList addObject:contact];
        
        //force a reload of list on viewDidAppear
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:@"force_import"];
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (IBAction)btnCreateContactClicked:(id)sender {
    
    if(self.txtName.text.length==0 || (self.txtEmail.text.length==0 && self.txtPhone.text.length==0) ) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"contact_fields_required",@"contact_fields_required") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }//TODO msg, need either phone or email
    
    else {
        
        BOOL emailValid = YES;
        if(self.txtEmail.text.length > 0 ) {
            //check if email valid
            if(![self NSStringIsValidEmail: self.txtEmail.text]) {
                emailValid = NO;
                //not valid
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"invalid_email",@"invalid_email") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
       
        if(emailValid) {
            
            if(![self isNativeContact] && self.editMode && contact!=nil && contactModel!=nil) {
                //TODO EDIT change contact and call prepareModelFromContact
                //then update on core data
                [self updateExistingContact];
            }
            else if([self checkIfContactExists]==NO) {
                
                NSDate *birthday = self.datePicker.date;
                //name OK, save it!
                Contact *contact = [[Contact alloc] init];
                contact.name = self.txtName.text;
                contact.birthday = birthday;
                contact.phone = self.txtPhone.text.length==0 ? @"" : self.txtPhone.text;
                contact.email = self.txtEmail.text.length==0 ? @"" : self.txtEmail.text;
                contact.lastName = self.txtLastName.text.length==0? @"": self.txtLastName.text;
                
                contact.isNative = false;
                
                NSLog(@"-----------------------------------");
                NSLog(@"contact name: %@",contact.name);
                NSLog(@"contact birthday: %@",contact.birthday.description);
                NSLog(@"contact phone: %@",contact.phone);
                NSLog(@"contact last name: %@",contact.lastName);
                NSLog(@"-----------------------------------");
                
                NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
                ContactDataModel *contactModel = [self prepareModelFromContact:managedObjectContext :contact ];
                
                BOOL OK = NO;
                NSError *error;
                
                if(![managedObjectContext save:&error]){
                    [[[[iToast makeText: [NSString stringWithFormat:@"Unable to save object, error is: %@",error.description]]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                    NSLog(@"Unable to save object, error is: %@",error.description);
                    //This is a serious error saying the record
                    //could not be saved. Advise the user to
                    //try again or restart the application.
                    
                }
                else {
                    
                    NSLog(@"-----------------------------------");
                    NSLog(@"contactModel name: %@",contactModel.name);
                    NSLog(@"contactModel birthday: %@",contactModel.birthday.description);
                    NSLog(@"contactModel phone: %@",contactModel.phone);
                    NSLog(@"contactModel last name: %@",contactModel.lastname);
                    NSLog(@"-----------------------------------");
                    
                    OK = YES;
                    
                    [[[[iToast makeText:NSLocalizedString(@"added",@"added")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                }
                
                if(OK) {
                    //add to the list
                    [self.contactsList addObject:contact];
                    
                    //force a reload of list on viewDidAppear
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:true forKey:@"force_import"];
                    
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                }
                
                
            }
            else {
                //TODO contact already exists
                //group name already exists
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"EasyMessage" message:NSLocalizedString(@"contact_already_exists",@"contact_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    
}

-(ContactDataModel *) prepareModelFromContact: (NSManagedObjectContext *) managedObjectContext: (Contact *)contact {
    
    ContactDataModel *contactModel = (ContactDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ContactDataModel" inManagedObjectContext:managedObjectContext];
    contactModel.name = contact.name;
    contactModel.phone = contact.phone;
    contactModel.email = contact.email;
    contactModel.birthday = contact.birthday;
    contactModel.lastname = contact.lastName;
    contactModel.group = nil;
    
    return contactModel;
}


-(BOOL) checkIfContactExists {

    if(self.txtEmail.text == nil ) {
        self.txtEmail.text = @"";
    }
    
    if(self.txtName.text == nil) {
        self.txtName.text = @"";
    }
    
    if(self.txtLastName == nil) {
        self.txtLastName.text = @"";
    }
    
    if(self.txtPhone == nil) {
        self.txtPhone.text = @"";
    }
    
    for(Contact * contact in self.contactsList) {
        
        
        if([self.txtName.text isEqualToString:contact.name ] && [self.txtLastName.text isEqualToString:contact.lastName] &&
           self.txtName.text.length > 0 && self.txtLastName.text.length > 0){
            
            return YES;
        }
        
        else if([self.txtEmail.text isEqualToString:contact.email] && self.txtEmail.text.length > 0) {
            return YES;
        }
        
        else if([self.txtPhone.text isEqualToString:contact.phone] && self.txtPhone.text.length > 0) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dateSwitchChanged:(id)sender {
    UISwitch *stwitch = (UISwitch *) sender;
    if(stwitch.isOn) {
        self.datePicker.enabled = true;
    }
    else {
        self.datePicker.enabled = false;
    }
}
//repeated on ContactDetailsController
-(BOOL) isNativeContact {
    return (contactModel!= nil && [contactModel isKindOfClass:CNMutableContact.class]) || (contact!=nil && [contact isNativeContact ]);
}

@end
