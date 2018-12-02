//
//  SettingsViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
//#import <Accounts/Accounts.h>

//TODO PC this is not translated??
#define OPTION_ALWAYS_SEND_BOTH   @"Always send both"
#define OPTION_SEND_EMAIL_ONLY    @"Send email only"
#define OPTION_SEND_SMS_ONLY      @"Send SMS only"
#define OPTION_INCLUDE_SOCIAL_SERVICES @"Include social services"

#define OPTION_ALWAYS_SEND_BOTH_ID      0
#define OPTION_SEND_EMAIL_ONLY_ID       1
#define OPTION_SEND_SMS_ONLY_ID         2
#define OPTION_INCLUDE_SOCIAL_SERVICES_ID       3

#define OPTION_SENDTO_FACEBOOK_ONLY    @"Send to Facebook only"
#define OPTION_SENDTO_TWITTER_ONLY      @"Send to Twitter only"
#define OPTION_SENDTO_LINKEDIN_ONLY      @"Send to Linkedin only"

#define OPTION_SENDTO_FACEBOOK_ONLY_ID     0
#define OPTION_SENDTO_TWITTER_ONLY_ID      1
#define OPTION_SENDTO_LINKEDINR_ONLY_ID    2

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

//save on device
#define SETTINGS_PREF_SEND_OPTION_KEY    @"pref_send_option_key"
#define SETTINGS_PREF_SERVICE_KEY        @"pref_service_key"
#define SETTINGS_PREF_ORDER_BY_KEY        @"pref_oder_by_key"

@class SocialNetworksViewController;

@interface SettingsViewController : UITableViewController

@property(strong,nonatomic)NSMutableArray *sendOptions;
@property(strong,nonatomic)NSMutableArray *preferedServiceOptions;
@property(strong,nonatomic)NSMutableArray *socialServicesOptions;

@property (assign,nonatomic) NSInteger selectOrderByOption;
@property (assign,nonatomic) NSInteger selectSendOption;
@property (assign,nonatomic) NSInteger selectPreferredService;


@property (assign,nonatomic) NSInteger initiallySelectedSendOption;
@property (assign,nonatomic) NSInteger initiallySelectedPreferredService;
@property (assign,nonatomic) NSInteger initiallySelectedOrderByOption;

@property BOOL showToast;

@property BOOL isFacebookAvailable;
@property BOOL isTwitterAvailable;
@property BOOL isLinkedinAvailable;

@property (strong,nonatomic) SocialNetworksViewController *socialOptionsController;
-(void) resetSocialNetworks;

@end
