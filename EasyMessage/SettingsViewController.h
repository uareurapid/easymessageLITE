//
//  SettingsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "CMPopTipView.h"
#import "FAQViewController.h"

//TODO PC this is not translated??
#define OPTION_ALWAYS_SEND_BOTH   @"Always send both"
#define OPTION_SEND_EMAIL_ONLY    @"Send email only"
#define OPTION_SEND_SMS_ONLY      @"Send SMS only"

#define OPTION_ALWAYS_SEND_BOTH_ID      0
#define OPTION_SEND_EMAIL_ONLY_ID       1
#define OPTION_SEND_SMS_ONLY_ID         2


#define OPTION_PREF_SERVICE_ALL    @"Use both services"
#define OPTION_PREF_SERVICE_EMAIL  @"Email service"
#define OPTION_PREF_SERVICE_SMS    @"SMS service"

#define OPTION_PREF_SERVICE_ALL_ID    0
#define OPTION_PREF_SERVICE_EMAIL_ID  1
#define OPTION_PREF_SERVICE_SMS_ID    2


#define OPTION_PREFERED_EMAIL_PHONE_ITEMS    @"Preferred email/phone"
#define OPTION_PREFERED_EMAIL_PHONE_ITEMS_ID    0

#define OPTION_ORDER_BY_LASTNAME_KEY    @"order_by_lastname"
#define OPTION_ORDER_BY_FIRSTNAME_KEY    @"order_by_firstname"
#define OPTION_ORDER_BY_LASTNAME_ID    0
#define OPTION_ORDER_BY_FIRSTNAME_ID    1

#define OPTION_FILTER_CONTACTS_ONLY_KEY    @"show_contacts_only"
#define OPTION_FILTER_GROUPS_ONLY_KEY    @"show_group_only"
#define OPTION_FILTER_FAVORITES_ONLY_KEY    @"show_favorites_only"
#define OPTION_FILTER_SHOW_ALL_KEY    @"show_all"
#define SETTINGS_FILTER_OPTIONS         @"filter_options"
#define SETTINGS_FILTER_PREVIOUS_OPTIONS         @"previous_filter_options"

//save on device
#define SETTINGS_PREF_SEND_OPTION_KEY    @"pref_send_option_key"
#define SETTINGS_PREF_SERVICE_KEY        @"pref_service_key"
#define SETTINGS_PREF_ORDER_BY_KEY        @"pref_oder_by_key"
//force a reload
#define SETTINGS_PREF_ORDER_BY_KEY_FORCE_RELOAD        @"pref_order_by_key_force_reload"
#define SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS       @"pref_order_by_key_previous_setting"



@class SocialNetworksViewController;
@class FilterOptionsViewController;
@class IAPMasterViewController;

@interface SettingsViewController : UITableViewController<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,CMPopTipViewDelegate>

@property(strong,nonatomic)NSMutableArray *sendOptions;
@property(strong,nonatomic)NSMutableArray *preferedServiceOptions;

@property (assign,nonatomic) NSInteger selectOrderByOption;
@property (assign,nonatomic) NSInteger selectSendOption;
@property (assign,nonatomic) NSInteger selectPreferredService;


@property (assign,nonatomic) NSInteger initiallySelectedSendOption;
@property (assign,nonatomic) NSInteger initiallySelectedPreferredService;
@property (assign,nonatomic) NSInteger initiallySelectedOrderByOption;

@property BOOL showToast;

@property (strong,nonatomic) IAPMasterViewController *purchasesController;
@property (strong,nonatomic) FilterOptionsViewController *filterOptionsController;
@property (strong,nonatomic) CMPopTipView *tooltipView;
@property BOOL isShowingTooltip;
@property BOOL isDeviceOnline;
@property(strong,nonatomic) FAQViewController *faqView;
//scrolls to last section of table
-(void) scrollToLastRowOfFAQSection;
-(void) resetSocialNetworks;
- (BOOL) forceIndividualSMS;

@end
