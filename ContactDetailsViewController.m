//
//  ContactDetailsViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 16/12/2018.
//  Copyright © 2018 Paulo Cristo. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "SelectRecipientsViewController.h"
#import <Contacts/Contacts.h>
#import "PCAppDelegate.h"
#import "AddContactViewController.h"
#import "NBPhoneNumber.h"
#import "NBPhoneNumberUtil.h"
#import "iToast.h"
#import "PCViewController.h"

@interface ContactDetailsViewController ()

@end

@implementation ContactDetailsViewController

@synthesize contactModel, contact, tooltipView,isShowingTooltip;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        contact = [[Contact alloc] init];
        contactModel = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelection = false;
}

//handle tooltips on view appear and disapear
-(void) viewDidDisappear:(BOOL)animated {
    if(self.isShowingTooltip && self.tooltipView!=nil) {
        self.isShowingTooltip = false;
        [self.tooltipView dismissAnimated:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:SHOW_HELP_TOOLTIP_CONTACT_DETAILS]) {
        //shows help tooltip
        self.tooltipView = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"tooltip_contact_details",nil)];
        self.tooltipView.delegate = self;
        //self.tooltipView.title = NSLocalizedString(@"message_recipients",nil);
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        self.tooltipView.backgroundColor =  [delegate colorFromHex:PREMIUM_COLOR]; //normal lite color
        [self.tooltipView  presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        self.isShowingTooltip = true;
        [defaults setBool:YES forKey:SHOW_HELP_TOOLTIP_CONTACT_DETAILS];
    }
    
    
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // any code, dismissed by user
    self.isShowingTooltip = false;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        contact = contactToShow;
        self.title = contact.name;
        //UIBarButtonItem *deteleContactButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
          //                                                                style:UIBarButtonItemStyleDone target:self action:@selector(deleteContactClicked:)];
    
        //deteleContactButton.tintColor = UIColor.whiteColor;
        //elf.navigationItem.rightBarButtonItem = deteleContactButton;
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        self.navigationItem.rightBarButtonItem = optionsButton;
        self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
    }
    
    [self searchForFavoritePhone];
    [self searchForFavoriteEmail];
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow andModel: (NSObject *) model {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        contact = contactToShow;
        contactModel = model;
        self.title = contact.name;
        
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        self.navigationItem.rightBarButtonItem = optionsButton;
        self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
        
    }
    [self searchForFavoritePhone];
    [self searchForFavoriteEmail];
    
    return self;
}

-(BOOL) isNativeContact {
    if( (contact!=nil && [contact isNativeContact ] ) || ( contactModel!= nil && [contactModel isKindOfClass:CNMutableContact.class] ) ) {
        return true;
    }
    return false;
}

- (void)optionsClicked:(id)sender event:(UIEvent *)event{
    [self showMenu:sender withEvent: event];
}

-(void) closeNativeContactController:(id) sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
}

-(void) addContactToFavorites: (BOOL) addORemove{
    
    if(self.contactModel == nil || self.contact == nil) {
        return;
    }
    
    self.contact.isFavorite = addORemove;
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    ContactDataModel *contactModel = (ContactDataModel *) self.contactModel;
    contactModel.favorite = contact.isFavorite;
    
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
   
        OK = YES;
        
        [[[[iToast makeText:NSLocalizedString(@"done_button",@"done_button")]
           setGravity:iToastGravityBottom] setDuration:2000] show];
        //force
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:@"force_reload"];
    }
    
    if(OK) {
       
        [self.navigationController popToRootViewControllerAnimated:YES];
     
    }
}

- (void) showMenu:(id)sender withEvent: (UIEvent *)event
{
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor whiteColor];
    configuration.menuWidth = 200;
    
    PCAppDelegate *delegate = (PCAppDelegate *) [[UIApplication sharedApplication] delegate];
    configuration.separatorColor = [delegate colorFromHex:0xfb922b];
    
    BOOL canDoPhoneCall = contact!= nil && [self isValidPhone:contact.phone];
    BOOL canSendEmail = contact!=nil && [self isValidEmail:contact.email];
    BOOL canDoFaceTime = (canSendEmail || canDoPhoneCall) && [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"facetime://"]];
    BOOL canAddToFavorites = contact!=nil && ![self isNativeContact];
    
    NSArray* options = [self getMenuArray:canDoFaceTime call:canDoPhoneCall email:canSendEmail showFavoriteOption: canAddToFavorites];
    
    NSArray* images = [self getImagesArray:canDoFaceTime call:canDoPhoneCall email:canSendEmail showFavoriteOption: canAddToFavorites];
    
    //no selection @[NSLocalizedString(@"edit",@"edit"),NSLocalizedString(@"delete",@"delete"),@"facetime",@"call", @"email"]
    [FTPopOverMenu showFromEvent:event withMenuArray:options
                  imageArray:images
               configuration:configuration
                   doneBlock:^(NSInteger selectedIndex) {
                       //NSLog(@"selected %ld", (long)selectedIndex);
                       if(selectedIndex == 0) {
                           //edit
                           //TODO if native contact show native interface otherwise the controller in edit mode
                           [self showAddContactController];
                       }
                       else if(selectedIndex == 1){
                           //delete
                           [self deleteContactClicked: sender];
                       } else if(selectedIndex == 2){
                           
                           if(canDoFaceTime) {
                               //facetime
                               NSString *str = [NSString stringWithFormat:@"facetime://%@", canDoPhoneCall ? contact.phone :  contact.email];
                               [self warnAboutFacetimeOrShow:str];
                           } else if(canDoPhoneCall) {
                               //NSLog(@"do call selected");
                               NSString *phoneToCall = [[contact.phone mutableCopy] stringByReplacingOccurrencesOfString:@" " withString:@""];
                               [self makePhoneCall:phoneToCall];
                           } else if(canSendEmail) {
                               //NSLog(@"send email selected");
                               [self sendEmail:contact.email];
                           } else if(!canDoFaceTime && !canSendEmail && !canDoPhoneCall && canAddToFavorites) {
                               [self addContactToFavorites : !self.contact.isFavorite];
                           }
                           
                       } else if(selectedIndex == 3){
                           
                           //facetime will be at position 2
                           if(canDoFaceTime) {
                               
                               //either call or mail
                               if(canDoPhoneCall) {
                                   //NSLog(@"do call selected");
                                   NSString *phoneToCall = [[contact.phone mutableCopy] stringByReplacingOccurrencesOfString:@" " withString:@""];
                                   [self makePhoneCall:phoneToCall];
                               } else if(canSendEmail) {
                                   //NSLog(@"send email selected");
                                   [self sendEmail:contact.email];
                               } else if(canAddToFavorites) {
                                   [self addContactToFavorites : !self.contact.isFavorite];
                               }
                               
                           } else if(canSendEmail) {
                        
                               //send email selected
                               [self sendEmail:contact.email];
                               //favorites selected
                           } else if(canAddToFavorites) {
                               [self addContactToFavorites : !self.contact.isFavorite];
                           }
                           
                       }
                       else if(selectedIndex == 4){ //means i have at least 5 options, last one is either email or favorite
                           
                           if(canDoFaceTime) {
                               
                               if(canDoPhoneCall) {
                                   
                                   if(canSendEmail) {
                                     [self sendEmail:contact.email];
                                   } else {
                                       //favorite
                                       [self addContactToFavorites : !self.contact.isFavorite];
                                   }
                               } else {
                                   //favorite
                                   [self addContactToFavorites : !self.contact.isFavorite];
                               }
                               
                               
                           } else  {
                               //favorite
                               [self addContactToFavorites : !self.contact.isFavorite];
                           }
                           
                           
                           //means i have the 6 options, last one is canAddToFavorites
                       }else if(selectedIndex == 5 && canAddToFavorites) {
                           [self addContactToFavorites : !self.contact.isFavorite];
                       }
    
                   } dismissBlock:^{
                       
                   }];
}

-(NSArray *) getMenuArray: (BOOL) canDoFaceTime call: (BOOL) canDoPhoneCall email: (BOOL) canSendEmail showFavoriteOption: (BOOL) canAddToFavorites {
  
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    [options addObject:NSLocalizedString(@"edit",@"edit")];
    [options addObject:NSLocalizedString(@"delete",@"delete")];
    
    if(canDoFaceTime) {
        [options addObject:@"Facetime"];
    }
    
    if(canDoPhoneCall) {
        [options addObject:NSLocalizedString(@"call_phone", @"Call")];
    }
    
    if(canSendEmail) {
        [options addObject:NSLocalizedString(@"contact_email", @"Email")];
    }
    
    if(canAddToFavorites) {
        if(self.contact.isFavorite) {
            [options addObject: NSLocalizedString(@"remove_from_favorites", nil) ];
        } else {
           [options addObject: NSLocalizedString(@"add_to_favorites", nil) ];
        }
        
    }
    
    return options;
}

-(NSArray *) getImagesArray: (BOOL) canDoFaceTime call: (BOOL) canDoPhoneCall email: (BOOL) canSendEmail showFavoriteOption: (BOOL) canAddToFavorites {
    NSMutableArray *options = [[NSMutableArray alloc] init];
    
    [options addObject:@"edit40"];
    [options addObject:@"delete"];
    
    if(canDoFaceTime) {
        [options addObject:@"facetime"];
    }
    
    if(canDoPhoneCall) {
        [options addObject:@"call"];
    }
    
    if(canSendEmail) {
        [options addObject:@"email40"];
    }
    
    if(canAddToFavorites) {
        [options addObject:@"favorite"];
    }
    
    return options;
}

//validate a phone number
- (BOOL)isValidPhone:(NSString *)phoneNumber
{
    if(phoneNumber == nil) {
        return false;
    }
    
    NSString *phoneToCheck = [[phoneNumber mutableCopy] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    @try {
        
        //https://github.com/iziz/libPhoneNumber-iOS
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        NBPhoneNumber *theNumber = [phoneUtil parse:phoneToCheck defaultRegion:@"AT" error:&anError];
        
        BOOL valid = false;
        
        //firt check using iOS port from libphonenumber (Google's phone number handling library)
        if (anError == nil) {
            valid = [phoneUtil isValidNumber:theNumber];
        }
        
        if(!valid) {
            //second check using regex
            NSString *phoneRegex = @"^((\\+)|(00))[0-9]{6,14}$";
            NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
            valid =  [phoneTest evaluateWithObject:phoneToCheck];
        }
        
        if(valid) {
            return true;
        } else {
            //final check, just make sure it is a number
            
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            BOOL isDecimal = [nf numberFromString:phoneToCheck] != nil;
            return isDecimal;
            
        }
        
    }@catch(NSException *) {
        return false;
    }
    
    
}
//validate email address
-(BOOL) isValidEmail:(NSString *)email
{
    if(email == nil) {
        return false;
    }
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(void) makePhoneCall: (NSString *) numberToCall {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", numberToCall ]]];
}

-(void) sendEmail: (NSString*) address {
    
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_email_title", @"EasyMessage: Send Email")
                                                        message:NSLocalizedString(@"no_email_device_settings",nil)
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    } else {
        //send the email normally
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:@"Easy Message"];
        [mc setMessageBody:@"Easy Message" isHTML:NO];
        [mc setToRecipients:@[address]];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
}

//delegate for the email controller
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    
    {
        case MFMailComposeResultCancelled:
            msg = NSLocalizedString(@"message_mail_canceled",@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            msg = NSLocalizedString(@"message_mail_saved",@"Mail saved");
            break;
        case MFMailComposeResultSent:
            msg = NSLocalizedString(@"message_mail_sent",@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            msg = [NSString stringWithFormat:NSLocalizedString(@"message_mail_sent_failure_%@", @"Mail sent failure"),[error localizedDescription]];
            break;
        default:
            break;
    }
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

//shows a message about Facetime call
-(void) warnAboutFacetimeOrShow: (NSString *) facetimeURL{
    
    //only warn once!
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"warnAboutFacetime"] == nil) {
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        
        Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                           subTitle:NSLocalizedString(@"facetime_warning",nil)
                                        cancelTitle:NSLocalizedString(@"Cancel",nil)
                                       successTitle:@"Ok"
                                        cancelBlock:^{
                                            //Custom code after cancel button was pressed
                                            [defaults setObject:@"warnAboutFacetime" forKey:@"warnAboutFacetime"];
                                            
                                        } successBlock:^{
                                            //Custom code after success button was pressed
                                            [defaults setObject:@"warnAboutFacetime" forKey:@"warnAboutFacetime"];
                                            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: facetimeURL]];
                                        }];
        
        [popup setBackgroundColor:[delegate colorFromHex:0xfb922b]];
        //https://github.com/miscavage/Popup
        [popup setBorderColor:[UIColor blackColor]];
        [popup setTitleColor:[UIColor whiteColor]];
        [popup setSubTitleColor:[UIColor whiteColor]];
        
        [popup setSuccessBtnColor:[delegate colorFromHex:0x4f6781]];
        [popup setSuccessTitleColor:[UIColor whiteColor]];
        [popup setCancelBtnColor:[delegate colorFromHex:0x4f6781]];
        [popup setCancelTitleColor:[UIColor whiteColor]];
        //[popup setBackgroundBlurType:PopupBackGroundBlurTypeLight];
        [popup setRoundedCorners:YES];
        [popup setTapBackgroundToDismiss:YES];
        [popup setDelegate:self];
        [popup showPopup];
        //do not warn me again
        
    } else {
        //just show
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: facetimeURL]];
    }
    
}

//edit contact
-(void) showAddContactController {
    
    if([self isNativeContact]) {
        
        CNMutableContact* contact = (CNMutableContact *) self.contactModel;
        
        //avoid show empty contact
        CNContactViewController *controller = [CNContactViewController viewControllerForContact:contact];
        controller.allowsEditing = true;
        controller.allowsActions = true;
        //controller.displayedPropertyKeys = keysToFetch;
        
        controller.delegate = self;
        
        
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: controller];
        
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        controller.navigationController.navigationBar.hidden = false;
        controller.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
        
        controller.navigationController.navigationBar.hidden = false;
        
        
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"done_button", nil)  style:UIBarButtonItemStyleDone target:self action:@selector(closeNativeContactController:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        controller.navigationItem.leftBarButtonItem = optionsButton;
        
        controller.navigationController.navigationBar.backgroundColor = [delegate colorFromHex:0xfb922b];
        controller.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        [self showViewController:navigationController sender:self];
        
        
    } else {
        
        AddContactViewController *addNewContactController = [[AddContactViewController alloc] initWithNibName:@"AddContactViewController" bundle:nil];
        addNewContactController.editMode = true;
        addNewContactController.contactsList = [[NSMutableArray alloc] init]; //empty list
        addNewContactController.contactModel = contactModel; //same object
        addNewContactController.contact = contact;//our contact class (we need to show this info, and maybe edit the other)
        
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        //we present it modally on a navigation controller to get a status bar
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: addNewContactController];
        navigationController.navigationBar.barTintColor = [delegate colorFromHex:0xfb922b];
        
        [self presentViewController:navigationController animated:YES completion:^{
            //((SelectRecipientsViewController *) self.presentationController).reload = true;
        }];
    }
    
}

//TODO contact has alternates??


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(contact!=nil) {
        if( [contact hasAlternatePhonesAndEmails ]) {
            return 3;//one for details + 1 for phones and 1 for emails
        } else if( [contact hasAlternatePhones] || [contact hasAlternateEmails] ) {
            return 2;//one for details + 1 for phones OR 1 for emails
        }
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger altPhones = [contact hasAlternatePhones] ? contact.alternatePhones.count : 0;
    NSInteger altEmails = [contact hasAlternateEmails] ? contact.alternateEmails.count : 0;
    
    
    if(section == 0) {
        if(contact.phone!=nil && contact.email!=nil ){
            //has both, at least 3
            //return 3 + altEmails + altPhones;
            return 3; //details + phone + email
        } else {
            return 2;//details + phone OR email
        }
    } else if(section == 1) {
        //has alternates for both, first we show alternate phones
        if(altPhones > 0 && altEmails > 0) {
            //means it has 2 sections
            return altPhones;
        } else {
            //ret phones count
            if(altPhones > 0) {
               return altPhones;
            } else {
                //emails counts instead
                return altEmails;
            }
        }
    } else {
        //has alternates for both
        //emails counts instead
        return altEmails;
    }
    
    //should never happen
    //return 2;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"contact_info", nil);
    }
    else if(section == 1) {
        if(contact!=nil ) {
            
            if([contact hasAlternatePhones]) {
               return NSLocalizedString(@"alternative_phones", nil);
            } else if([contact hasAlternateEmails]) {
                return NSLocalizedString(@"alternative_emails", nil);
            }
            
        }
    }
    else if(section == 2) {
        return NSLocalizedString(@"alternative_emails", nil);
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
    if(contact!=nil) {
        
        if(section == 0) {
            
            // Configure the cell...
            BOOL hasPhone = contact.phone!=nil;
            BOOL hasEmail = contact.email!=nil;
            
            if(row==0){
                if(contact.name!=nil) {
                    if(contact.lastName!=nil) {
                        
                        NSRange range = [contact.name rangeOfString:contact.lastName
                                                            options:NSCaseInsensitiveSearch];
                        if (range.length == 0) { //if the substring did not match
                            //append also lastname
                            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.name, contact.lastName ];//use both
                        }
                        else {
                            //append just the name, since the last name is already included (happens on native contacts, not core data models)
                            cell.textLabel.text = contact.name;
                        }
                    }
                    else {
                        // just the name, since last name is null
                        cell.textLabel.text = contact.name;
                    }
                }
                else if(contact.lastName!=nil) {
                    cell.textLabel.text = contact.lastName;
                }
                //also add detail info
                if(hasEmail && hasPhone) {
                    //has both
                    cell.detailTextLabel.text =  [NSString stringWithFormat:@"Email + %@", NSLocalizedString(@"phone_label",@"Phone") ];
                }
                else if(hasEmail) {
                    //only email
                    cell.detailTextLabel.text = @"Email";
                }
                else {
                    //only phone
                    cell.detailTextLabel.text = NSLocalizedString(@"phone_label",@"Phone");
                }
                //cell.editing = true;
                //cell.editingStyle = UITableViewCellStyleE
            }
            else if(row==1){
                //either phone or email
                if(contact.email!=nil) {
                    cell.textLabel.text = [NSString stringWithFormat:@"Email: %@", contact.email];
                    
                    if(contact.alternateEmails!=nil && contact.alternateEmails.count > 0) {
                       cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav30"]];
                    }
                    
                }
                else if(contact.phone!=nil) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"phone_label",@"Phone"),contact.phone ];
                    
                    if(contact.alternatePhones!=nil && contact.alternatePhones.count > 0) {
                       cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav30"]];
                    }
                }
                
                
            
            }
            else {
                if(contact.phone!=nil) {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"phone_label",@"Phone"),contact.phone ];
                    //only show fav icon if have alternates
                    if(contact.alternatePhones!=nil && contact.alternatePhones.count > 0) {
                       cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav30"]];
                    }
                    
                   
                }
                else if(contact.email!=nil) {
                    cell.textLabel.text =  [NSString stringWithFormat:@"Email: %@", contact.email];
                    
                    if(contact.alternateEmails!=nil && contact.alternateEmails.count > 0) {
                       cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fav30"]];
                    }
                }
                
            }
            
        } else if(section == 1) {
            
            NSInteger altPhones = [contact hasAlternatePhones] ? contact.alternatePhones.count : 0;
            NSInteger altEmails = [contact hasAlternateEmails] ? contact.alternateEmails.count : 0;
            
            //if have both alternates phones and emails section 1 is for phones
            if(altPhones > 0 && altEmails > 0) {
                //show alternate phones here
                if(row < contact.alternatePhones.count ) {
                    cell.textLabel.text = [contact.alternatePhones objectAtIndex:row];
                    
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfav30"]];
                    cell.accessoryView.userInteractionEnabled = true;
                    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favPhoneTouched:)];
                    
                    
                    [cell.accessoryView addGestureRecognizer:touch];
                    [cell.accessoryView setTag: (100 + row)];
                }
                
                
            } else if(altPhones > 0) {
                if(row < contact.alternatePhones.count ) {
                    cell.textLabel.text = [contact.alternatePhones objectAtIndex:row];
                    
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfav30"]];
                    cell.accessoryView.userInteractionEnabled = true;
                    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favPhoneTouched:) ];
                    
                    
                    [cell.accessoryView addGestureRecognizer:touch];
                    [cell.accessoryView setTag: (100 + row)];
                    
                }
            } else {
                //altEmails > 0
                if(row < contact.alternateEmails.count ) {
                    cell.textLabel.text = [contact.alternateEmails objectAtIndex:row];
                    
                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfav30"]];
                    cell.accessoryView.userInteractionEnabled = true;
                    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favEmailTouched:) ];
                    
            
                    [cell.accessoryView addGestureRecognizer:touch];
                    [cell.accessoryView setTag:(100 + row)];
                }
            }
            
        } else {
            //section 2 is jus emails
            if(row < contact.alternateEmails.count ) {
                cell.textLabel.text = [contact.alternateEmails objectAtIndex:row];
                
                cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unfav30"]];
                cell.accessoryView.userInteractionEnabled = true;
                UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favEmailTouched:) ];
            
                [cell.accessoryView addGestureRecognizer:touch];
                [cell.accessoryView setTag:(200 + row)];
            }
        }
        
        
        
       
    }
    
    return cell;
}

-(IBAction) favPhoneTouched:(UIGestureRecognizer *)recognizer{
  
    NSInteger tag = recognizer.view.tag;
    NSInteger section = 1;
    NSInteger row = 0;
    if(tag >= 200) {
        section = 2;
        row = tag - 200;
    } else {
        row = tag - 100;
    }
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"set_as_prefered_phone", nil)
           message:nil
    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *phoneTouched = [UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *action)
                {
        
                        NSString *phone = self.contact.phone;
                        if(row < self.contact.alternatePhones.count) {
                            
                            NSString *key = [NSString stringWithFormat:@"prefered_phone_%@", contact.descriptionKey ];
                            
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            
                            
                            
                            NSString *alternate = [self.contact.alternatePhones  objectAtIndex:row];
                            self.contact.phone = alternate;
                            [self.contact.alternatePhones removeObjectAtIndex:row];
                            [self.contact.alternatePhones addObject:phone];
                            
                            [defaults setValue:alternate forKey:key];
                        
                            
                            [alertCtrl dismissViewControllerAnimated:YES completion:nil];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
        style:UIAlertActionStyleDefault
          handler:^(UIAlertAction *action)
            {
                [alertCtrl dismissViewControllerAnimated:YES completion:nil];
            }];
    
    [alertCtrl addAction:phoneTouched];
    [alertCtrl addAction:cancel];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

-(IBAction) favEmailTouched:(UIGestureRecognizer *)recognizer{
    NSInteger tag = recognizer.view.tag;
    NSInteger section = 1;
    NSInteger row = 0;
    if(tag >= 200) {
        section = 2;
        row = tag - 200;
    } else {
        row = tag - 100;
    }
    
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"set_as_prefered_email", nil)
           message:nil
    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *emailTouched = [UIAlertAction actionWithTitle:NSLocalizedString(@"save", nil)
            style:UIAlertActionStyleDefault
              handler:^(UIAlertAction *action)
                {

                    NSString *email = self.contact.email;
                    if(row < self.contact.alternateEmails.count) {
                        
                        NSString *key = [NSString stringWithFormat:@"prefered_email_%@", contact.descriptionKey ];
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        
                        
                        
                        NSString *alternate = [self.contact.alternateEmails  objectAtIndex:row];
                        self.contact.email = alternate;
                        [self.contact.alternateEmails removeObjectAtIndex:row];
                        [self.contact.alternateEmails addObject:email];
                        
                        [defaults setValue:alternate forKey:key];
                        
                        [alertCtrl dismissViewControllerAnimated:YES completion:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil)
        style:UIAlertActionStyleDefault
          handler:^(UIAlertAction *action)
            {
                [alertCtrl dismissViewControllerAnimated:YES completion:nil];
            }];
    
    [alertCtrl addAction:emailTouched];
    [alertCtrl addAction:cancel];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

-(void) searchForFavoritePhone {
    if(self.contact!=nil && self.contact.alternatePhones!=nil && self.contact.alternatePhones.count > 0) {
        
     
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"prefered_phone_%@", contact.descriptionKey ];

        //we have a key?
        if([defaults valueForKey:key]!=nil) {
            NSString *favourite = [defaults valueForKey:key];
            
            if(self.contact.phone!=nil && ![self.contact.phone isEqualToString:favourite]) {
                
                NSString *defaultPhone = self.contact.phone;
               //the one currently set as default phone is not the favorite one
                
                NSUInteger index = -1;
                NSInteger idx = 0;
                NSString *alternate = nil;
                //find where the alternate is located in the array of alternates, for the swap
                for(idx = 0; idx < self.contact.alternatePhones.count; idx++) {
                    alternate  =  [self.contact.alternatePhones objectAtIndex:idx];
                    
                    //found it
                    if(alternate!=nil && [alternate isEqualToString:favourite]) {
                      //swap them now
                        index = idx;
                        self.contact.phone = favourite;
                        [self.contact.alternatePhones removeObjectAtIndex:index];
                        [self.contact.alternatePhones addObject:defaultPhone];
                        return;
                    }
                }
                
               
            }
        }
        
    }
}

-(void) searchForFavoriteEmail {
    if(self.contact!=nil && self.contact.alternateEmails!=nil && self.contact.alternateEmails.count > 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"prefered_email_%@", contact.descriptionKey];
       
        //we have a key?
        if([defaults valueForKey:key]!=nil) {
            NSString *favourite = [defaults valueForKey:key];
         
            if(self.contact.email!=nil && ![self.contact.email isEqualToString:favourite]) {
                
                NSString *defaultEmail = self.contact.email;
               //the one currently set as default email is not the favorite one
                
                NSUInteger index = -1;
                NSInteger idx = 0;
                NSString *alternate = nil;
                //find where the alternate is located in the array of alternates, for the swap
                for(idx = 0; idx < self.contact.alternateEmails.count; idx++) {
                    alternate  =  [self.contact.alternateEmails objectAtIndex:idx];

                    //found it
                    if(alternate!=nil && [alternate isEqualToString:favourite]) {
                      //swap them now
                        index = idx;
                        self.contact.email = favourite;
                        [self.contact.alternateEmails removeObjectAtIndex:index];
                        [self.contact.alternateEmails addObject:defaultEmail];
                        return;
                    }
                }

            }
        }
        
    }
}

-(IBAction) deleteContactClicked:(id)sender {
    
    //@property(nonatomic, copy) NSArray *viewControllers
    
    //Discussion: The root view controller is at index 0 in the array, the back view controller is at index n-2, and the top controller is at index n-1, where n is the number of items in the array.
    
    SelectRecipientsViewController *root;
    for(UIViewController *controller in self.navigationController.viewControllers) {
        
        if([controller isKindOfClass: SelectRecipientsViewController.class]) {
            root = (SelectRecipientsViewController*)controller;
            break;
        }
    }
    if(root!=nil) {
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                         message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                        delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        self.root = root;
        [alert show];
        
        
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES]; //normal dismiss
    }
    //-[NSManagedObjectContext deleteObject:]
}

#pragma uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1 && self.root!=nil) {
        // OK
        [ (SelectRecipientsViewController *)self.root deleteContact:contact];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
