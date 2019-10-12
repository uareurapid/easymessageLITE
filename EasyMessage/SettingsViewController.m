//
//  SettingsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SettingsViewController.h"
#import "iToast.h"
#import "SocialNetworksViewController.h"
#import <StoreKit/StoreKit.h>
#import "FilterOptionsViewController.h"
#import "PCAppDelegate.h"
#import "PCViewController.h"
#import "PCReachability.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize sendOptions,preferedServiceOptions,socialServicesOptions;
@synthesize selectPreferredService,selectSendOption,selectOrderByOption;
@synthesize socialOptionsController, purchasesController, filterOptionsController;
@synthesize showToast;
@synthesize initiallySelectedPreferredService,initiallySelectedSendOption, initiallySelectedOrderByOption;
@synthesize isFacebookAvailable,isTwitterAvailable,isLinkedinAvailable,isShowingTooltip,tooltipView;
@synthesize isDeviceOnline;

//ABOUT IOS MESSAGES:
//https://support.apple.com/en-us/HT202724

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)resetSocialNetworks {
    if(socialOptionsController!=nil) {
        [socialOptionsController.selectedServiceOptions removeAllObjects];
        [socialOptionsController.tableView reloadData];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isDeviceOnline = false;
    [self checkIfOnline];
    sendOptions = [[NSMutableArray alloc] initWithObjects:OPTION_ALWAYS_SEND_BOTH, OPTION_SEND_EMAIL_ONLY, OPTION_SEND_SMS_ONLY,nil];
    preferedServiceOptions = [[NSMutableArray alloc] initWithObjects:OPTION_PREF_SERVICE_EMAIL,OPTION_PREF_SERVICE_SMS,OPTION_PREF_SERVICE_ALL, nil];
    
    socialServicesOptions = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self checkSocialServicesAvailability];
    
    //deafult values on startup
    //by default (check the seetings for change)
    selectOrderByOption = OPTION_ORDER_BY_LASTNAME_ID;
    selectSendOption = OPTION_ALWAYS_SEND_BOTH_ID;
    selectPreferredService = OPTION_PREF_SERVICE_ALL_ID;
    
    
    
    NSString *selectedSendSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SEND_OPTION_KEY];
    NSString *selectedPrefServiceSaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_SERVICE_KEY];
    
    //TODO PC check
    NSString *selectedOrderBySaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
    
    if(selectedOrderBySaved!=nil) {
        if([selectedOrderBySaved isEqualToString:OPTION_ORDER_BY_LASTNAME_KEY]) {
            selectOrderByOption = OPTION_ORDER_BY_LASTNAME_ID;
        }
        else {
            selectOrderByOption = OPTION_ORDER_BY_FIRSTNAME_ID;
        }
    }
    
    
    if(selectedSendSaved!=nil) {
        if([selectedSendSaved isEqualToString:OPTION_SEND_EMAIL_ONLY]) {
            selectSendOption = OPTION_SEND_EMAIL_ONLY_ID;
        }
        if([selectedSendSaved isEqualToString:OPTION_SEND_SMS_ONLY]) {
            selectSendOption = OPTION_SEND_SMS_ONLY_ID;
        }
    }
    
    if(selectedPrefServiceSaved!=nil) {
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_SMS]) {
            selectPreferredService = OPTION_PREF_SERVICE_SMS_ID;
        }
        if([selectedPrefServiceSaved isEqualToString:OPTION_PREF_SERVICE_EMAIL]) {
            selectPreferredService = OPTION_PREF_SERVICE_EMAIL_ID;
        }
    }
    
    NSMutableArray *services = [[NSMutableArray alloc] init];
    if(sendOptions.count>3) {
        if(isFacebookAvailable) {
            [services addObject:OPTION_SENDTO_FACEBOOK_ONLY];
        }
        if(isTwitterAvailable ) {
            [services addObject:OPTION_SENDTO_TWITTER_ONLY];
        }
        if(isLinkedinAvailable) {
           [services addObject:OPTION_SENDTO_LINKEDIN_ONLY];
        }
        
    }
    
    
    socialOptionsController = [[SocialNetworksViewController alloc] initWithNibName:@"SocialNetworksViewController"
                                                                              bundle:nil previousController:self services:services];

    filterOptionsController = [[FilterOptionsViewController alloc] initWithNibName:@"FilterOptionsViewController" bundle:nil];
    
    showToast = YES;
    
}

-(void) checkIfOnline {
    
    // Allocate a reachability object
    PCReachability* reach = [PCReachability reachabilityWithHostname:@"www.google.com"];

    // Set the blocks
    reach.reachableBlock = ^(PCReachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        if(!self.isDeviceOnline) {
            
            self.isDeviceOnline = true;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
    };

    reach.unreachableBlock = ^(PCReachability*reach)
    {
        if(self.isDeviceOnline) {
            
            self.isDeviceOnline = false;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    };

    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}

//check if the facebook and twitter services are available/configured
//and add/remove them accordingly
-(void) checkSocialServicesAvailability {
    
    isLinkedinAvailable = true;
    isFacebookAvailable=true;
    isTwitterAvailable=true;
    
    if(isTwitterAvailable || isFacebookAvailable || isLinkedinAvailable) {
        if(![sendOptions containsObject:OPTION_INCLUDE_SOCIAL_SERVICES]) {
        //add it
           [sendOptions addObject:OPTION_INCLUDE_SOCIAL_SERVICES]; 
        }
        
    }
    else if(!isTwitterAvailable &&!isLinkedinAvailable && !isFacebookAvailable && [sendOptions containsObject:OPTION_INCLUDE_SOCIAL_SERVICES]) {
        //remove it
        [sendOptions removeObject:OPTION_INCLUDE_SOCIAL_SERVICES];
    }
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil  {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
        self.title =  NSLocalizedString(@"settings",nil);
    }
    
    return self;
}


//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    //remove the notification listener for account changes
    //[[NSNotificationCenter defaultCenter] removeObserver:ACAccountStoreDidChangeNotification];
    [self saveSettings];
}

-(void) viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:SHOW_HELP_TOOLTIP_APP_SETTINGS]) {
        //shows help tooltip
        self.tooltipView = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"tooltip_app_settings",nil)];
        self.tooltipView.delegate = self;
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        self.tooltipView.backgroundColor =  [delegate colorFromHex:PREMIUM_COLOR]; //normal lite color
        UIView *view = [self.tableView headerViewForSection:1];
        [self.tooltipView presentPointingAtView:view inView:self.view animated:YES];
        self.isShowingTooltip = true;
        [defaults setBool:YES forKey:SHOW_HELP_TOOLTIP_APP_SETTINGS];
    }
    
    
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // any code, dismissed by user
    self.isShowingTooltip = false;
}

-(void) viewWillAppear:(BOOL)animated {
    
    initiallySelectedSendOption = selectSendOption;
    initiallySelectedPreferredService = selectPreferredService;
    initiallySelectedOrderByOption = selectOrderByOption;
    

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    //add a notification listener to detect account changes
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSocialServicesAvailability) name:ACAccountStoreDidChangeNotification object:nil];
    
    if(socialOptionsController!=nil) {
        if(socialOptionsController.selectedServiceOptions.count > 0) {
            //toast we will use social services
        }
    }
    
    if([self hasShownAllTooltipsAlready] && self.tableView.numberOfSections == 6) {
        //1 section is missing, make it appear again
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    
    return [self hasShownAllTooltipsAlready] ? 7 : 6;
    //add an option to show them again, putting all to false 7;
    //added one for restore purchase/buy premium + reset
}

-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) saveSettings {
    
    //the default send option
    NSString *msg;

    switch (selectSendOption) {
        case OPTION_ALWAYS_SEND_BOTH_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_ALWAYS_SEND_BOTH forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_both",@"Settings have been updated. Will send both SMS and email!");
            break;
        case OPTION_SEND_EMAIL_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_EMAIL_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;
        case OPTION_SEND_SMS_ONLY_ID: //case 2 -> OPTION_SEND_SMS_ONLY_ID
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SEND_SMS_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_sms",@"Settings have been updated. Will send SMS only!");
            break;
            /*
        //twitter and facebook
        case OPTION_SENDTO_FACEBOOK_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SENDTO_FACEBOOK_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;
        case OPTION_SENDTO_TWITTER_ONLY_ID:
            [[NSUserDefaults standardUserDefaults] setObject:OPTION_SENDTO_TWITTER_ONLY forKey:SETTINGS_PREF_SEND_OPTION_KEY];
            msg = NSLocalizedString(@"alert_message_settings_updated_email",@"Settings have been updated. Will send email only!");
            break;*/
            
        
    }
    
    //now the preferred service
    if(selectPreferredService == OPTION_PREF_SERVICE_ALL_ID) {
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_ALL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    else if(selectPreferredService == OPTION_PREF_SERVICE_EMAIL_ID) {
   
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_EMAIL forKey:SETTINGS_PREF_SERVICE_KEY];
    }
    else { //OPTION_PREF_SERVICE_SMS_ID
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_PREF_SERVICE_SMS forKey:SETTINGS_PREF_SERVICE_KEY]; 
    }
    
    //order the list
    if(selectOrderByOption == OPTION_ORDER_BY_LASTNAME_ID) {
        [[NSUserDefaults standardUserDefaults] setObject:OPTION_ORDER_BY_LASTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY];
    }
    else {
         [[NSUserDefaults standardUserDefaults] setObject:OPTION_ORDER_BY_FIRSTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //if there were any changes
    if(initiallySelectedPreferredService != selectPreferredService || initiallySelectedSendOption!=selectSendOption /* || selectOrderByOption != initiallySelectedOrderByOption */) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
    
    BOOL forceReload = selectOrderByOption != initiallySelectedOrderByOption;
    [[NSUserDefaults standardUserDefaults] setBool:forceReload forKey:SETTINGS_PREF_ORDER_BY_KEY_FORCE_RELOAD];
    if(forceReload) {
        
        if(initiallySelectedOrderByOption == OPTION_ORDER_BY_LASTNAME_ID) {
           [[NSUserDefaults standardUserDefaults] setObject:OPTION_ORDER_BY_LASTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS];
        }
        else {
           [[NSUserDefaults standardUserDefaults] setObject:OPTION_ORDER_BY_FIRSTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section==0) {
        return sendOptions.count;
    }
    else if(section==1) {
       return preferedServiceOptions.count; 
    }
    else if(section == 2) {
        //order by last/first name
        return 2;
    }
    else if(section == 3) {
        return 1; //filter options
        
    }else if(section == 4) {
        //rate us/questions/suggestions
        return self.isDeviceOnline ? 2 : 1;//removeed the rate one
    }
    else if(section == 5) {
        //restore/purchase premium
        return 1;
    }
   
    return 1; //just one for the prefered item options
    
}

-(BOOL) hasShownAllTooltipsAlready {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:SHOW_HELP_TOOLTIP_MAIN] && [defaults boolForKey:SHOW_HELP_TOOLTIP_RECIPIENTS] &&
       [defaults boolForKey:SHOW_HELP_TOOLTIP_CONTACT_DETAILS] && [defaults boolForKey:SHOW_HELP_TOOLTIP_APP_SETTINGS]) {
        return true;
    }
    
    return false;
}

-(void) resetAllTooltips {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:FALSE forKey:SHOW_HELP_TOOLTIP_MAIN];
    [defaults setBool:FALSE forKey:SHOW_HELP_TOOLTIP_RECIPIENTS];
    [defaults setBool:FALSE forKey:SHOW_HELP_TOOLTIP_CONTACT_DETAILS];
    [defaults setBool:FALSE forKey:SHOW_HELP_TOOLTIP_APP_SETTINGS];
    self.isShowingTooltip = false;
    [defaults synchronize];
    [self.tableView reloadData];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return  NSLocalizedString(@"header_message_send_options",nil);
    }
    else if(section==1) {
      return NSLocalizedString(@"header_preferred_service",nil);
    }
    else if(section == 2) {
        
        return NSLocalizedString(@"order_contacts",nil);
    }
    else if(section == 3) {
       return NSLocalizedString(@"filter_options",nil);
    }
    else if(section == 4) {
        
        return NSLocalizedString(@"contact_us", nil);
    }
    else if(section == 5) {
        //TODO
        return NSLocalizedString(@"unlock_premium", nil);
    }
    else {
       return @"Advanced Options";
    }
    
    
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    if(section==0) {
        return NSLocalizedString(@"footer_select_service", nil);
    }
    else if(section==1) {
        return NSLocalizedString(@"footer_preferred_service", nil);   
    }
    else if(section==2) {
        return NSLocalizedString(@"order_contacts_explanation", nil);
    }
    else if(section == 3) {
        return NSLocalizedString(@"filter_options_explanation",nil);
        
    }else if(section==4) {
        return NSLocalizedString(@"send_feedback", nil);
    }
    else if(section==5) {
        //TODO
        return NSLocalizedString(@"unlock_premium", nil);
    }
    else {
        return @"";
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if(section==0) {
        cell.textLabel.text =  [self labelForOptionIndex:row atSection:section];// [sendOptions objectAtIndex:row];
        
        if(row == selectSendOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(row==0) {
            cell.imageView.image = [UIImage imageNamed:@"emblem_package"];
            //Author: VisualPharm, http://www.visualpharm.com/
        //License: CC Attribution No Derivatives

        }
        else if(row==1) {
             cell.imageView.image = [UIImage imageNamed:@"contact"];
            //VisualPharm (Ivan Boyko)
        }
        else if(row==2) {
            cell.imageView.image = [UIImage imageNamed:@"Sms-And-Mms-48"];
            cell.userInteractionEnabled = [self deviceSupportSMS];
            //Author: CrazEriC, http://crazeric.deviantart.com/
        //License: CC Attribution
        }
        else if(row==3) {
            //these are free but anyway Zen Nikki - http://zen-nikki.deviantart.com/
            cell.imageView.image = [UIImage imageNamed:@"world3"];//About-me-icon
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
    }
    else if(section==1){
        //if (section==1 ) {
        cell.textLabel.text = [self labelForOptionIndex:row atSection:section];//[preferedServiceOptions objectAtIndex:row];
        if(row == selectPreferredService) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        
        if(row==0) {
            cell.imageView.image = [UIImage imageNamed:@"contact"];
            //VisualPharm (Ivan Boyko)
        }
        else if(row==1) {
            cell.imageView.image = [UIImage imageNamed:@"Sms-And-Mms-48"];
            cell.userInteractionEnabled = [self deviceSupportSMS];
        }
        else {
            cell.imageView.image = [UIImage imageNamed:@"emblem_package"];
            cell.userInteractionEnabled = [self deviceSupportSMS];
        }
        
    }
    else if(section == 2) {
        cell.textLabel.text =  [self labelForOptionIndex:row atSection:section];
        if(row == selectOrderByOption) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if(row == 0) {
          cell.imageView.image = [UIImage imageNamed:@"sorta"];;
            
        }
        else{
            cell.imageView.image = [UIImage imageNamed:@"sortb"];
        }
        
        
    }
    else if(section == 3) {
        cell.textLabel.text = NSLocalizedString(@"filter_options",nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"eyes"];
    }
    else if(section == 4) {
        if(!self.isDeviceOnline) {
            cell.textLabel.text = NSLocalizedString(@"contact_us", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"contact"];
        }
        else if(row == 0) {
            cell.textLabel.text = NSLocalizedString(@"contact_us", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"contact"];
        }
        else {
            cell.textLabel.text = @"FAQ";//NSLocalizedString(@"contact_us", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"faq"];
        }
        
        
    }//TODO
    else if(section == 5) {
        cell.textLabel.text =  NSLocalizedString(@"unlock_premium", nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = [UIImage imageNamed:@"Unlock32"];
        //restore tooltips
    } else if (section == 6 && [self hasShownAllTooltipsAlready]) {
        
        cell.textLabel.text =  NSLocalizedString(@"show_tooltips_again", nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.imageView.image = [UIImage imageNamed:@"gear"];
    }
 
    
    return cell;
}

//delegate for the sms controller
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    
    NSString *msg;
    switch (result) {
        case MessageComposeResultCancelled:
            msg = NSLocalizedString(@"message_sms_canceled",@"Canceled");
            break;
        case MessageComposeResultFailed:
            msg = NSLocalizedString(@"message_sms_unable_compose",@"Unable to compose SMS");
            break;
        case MessageComposeResultSent:
            msg = NSLocalizedString(@"message_sms_sent",@"SMS sent");
            break;
        default:
            break;
    }
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
//check if we have SMS support
-(BOOL) deviceSupportSMS {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]]) {
        return YES;
    }
    return NO;
        // device has phone capabilities
}

-(NSString *) labelForOptionIndex: (NSInteger) rowIndex atSection: (NSInteger) section {
    
    
    if(section==0) {//send options
        switch (rowIndex) {
            case 0:
                //NSLog(@"returning %@", NSLocalizedString(@"option_send_both", @"send both email and sms"));
                return NSLocalizedString(@"option_send_both", @"send both email and sms");
            case 1:
                return NSLocalizedString(@"option_send_email_only", @"send email only");
            case 2:
                return NSLocalizedString(@"option_send_sms_only",@"send only sms");
                
            case 3:
                return NSLocalizedString(@"option_send_include_social_network",@"include social networks");
            default:
                return @"";
                      
  
        }
    }
    else if(section==1) {
        switch (rowIndex) {//preferred services
            case 0:
                return NSLocalizedString(@"preferred_email_service", @"prefer email");
            case 1:
                return NSLocalizedString(@"preferred_sms_service", @"prefer sms");
            default:
                return NSLocalizedString(@"preferred_use_both_services",@"use both");
        }
    }
    else if(section==2) {
        switch (rowIndex) {//preferred services
            case 0:
                return NSLocalizedString(@"order_by_lastname", @"order_by_lastname");
            case 1:
                return NSLocalizedString(@"order_by_firstname", @"order_by_firstname");
            default:
                return NSLocalizedString(@"order_by_lastname",@"order_by_lastname");
        }
    }
  
    return @"";
    //section 0
    //OPTION_ALWAYS_SEND_BOTH, OPTION_SEND_EMAIL_ONLY, OPTION_SEND_SMS_ONLY
    //section 1
    //OPTION_PREF_SERVICE_EMAIL,OPTION_PREF_SERVICE_SMS,OPTION_PREF_SERVICE_ALL
    /*
    "option_send_both" = "Always send both";
    "option_send_email_only" = "Send email only";
    "option_send_sms_only" = "Send SMS only";
    "footer_select_service" = "Select the service to send the message";
    
    "preferred_email_service" = "Email service";
    "preferred_sms_service"= "SMS service";
    "preferred_use_both_services" = "Use both services";*/
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row =indexPath.row;

    
    if(section==0) {
         
        if(row < 3) {
          //i do not consider row 3 as a valid option
          selectSendOption = row;
          [self.tableView reloadData];
        }
        else {
            showToast = NO;
            [self.navigationController pushViewController:socialOptionsController animated:YES];
        }
    }
    else if(section==1) {
        selectPreferredService = row;
        [self.tableView reloadData];
        
    }
    else if(section==2) {
        selectOrderByOption = row;
        [self.tableView reloadData];
        
    }//we show the options but only allow the default one (all contacts)
    else if(section == 3) {
        
        [self.navigationController pushViewController:filterOptionsController animated:YES];

    }
    else if(section == 4) {
        if(row == 0) {
            [self sendEmail:nil];
        } else if(self.isDeviceOnline && row == 1) {
            
            if(self.faqView == nil) {
                self.faqView = [[FAQViewController alloc] initWithNibName:@"FAQViewController" bundle:nil];
            }
           
            [self.navigationController pushViewController:self.faqView animated:YES];
        }
    }
    else if(section == 5 && row == 0) {
        
        if(self.purchasesController !=nil) {
            [self.navigationController pushViewController:purchasesController animated:YES];
        }
    } else if(section == 6 && row == 0 && [self hasShownAllTooltipsAlready]) {
        
        [self resetAllTooltips];
    }
    
  
}

- (IBAction)sendEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Questions Or Suggestions (L)";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSMutableArray *toRecipents = [[NSMutableArray alloc] initWithObjects:@"info@pcdreams-software.com", nil];
    
    
    if(toRecipents.count>0) {
        
        //avoid crash, cannot send email
        if (![MFMailComposeViewController canSendMail]) {
            NSLog(@"Mail services are not available.");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_email_title", @"EasyMessage: Send Email")
                                                            message:NSLocalizedString(@"no_email_device_settings",nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
        
    }
}

@end
