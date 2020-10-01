//
//  PCViewController.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <MessageUI/MessageUI.h> 
#import "UIPlaceHolderTextView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "EasyMessageIAPHelper.h"
#import "iToast.h"
#import <iAd/iAd.h>
#import <AddressBook/AddressBook.h>
#import "AFHTTPRequestOperation.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"
#import "PCPopupViewController.h"
#import <StoreKit/StoreKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterKit/TwitterKit.h>
#import <QBImagePickerController/QBImagePickerController.h>
#import "AttachCellCollectionViewCell.h"
#import "Popup.h"
#import "CMPopTipView.h"

@class SelectRecipientsViewController;
@class IAPMasterViewController;
@class CustomMessagesController;

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//after 3 messages
#define KEY_ASK_FOR_REVIEW  @"ask_for_review"
#define KEY_WARNED_ABOUT_IMESSAGE @"warn_about_imessage"
#define PROMO_SHOW_COUNTER @"promo_show_counter"
#define MAX_ATTACHMENTS 5
#define MAX_ATTACHMENTS_WITHOUT_PREMIUM 1
#define MAX_RECIPIENTS_WITHOUT_PREMIUM 5
#define MAX_GROUP_MEMBERS_WITHOUT_PREMIUM 3
#define MAX_TEMPLATES_WITHOUT_PREMIUM 2
#define MAX_GROUPS_WITHOUT_PREMIUM 2

#define LINKEDIN_ME_KEY   @"linkedin_me"

#define LITE_COLOR 0xfb922b
#define PREMIUM_COLOR 0x4f6781

#define FAILED_MESSAGE_COUNTER @"FAILED_MSG_COUNT"
#define APP_OPENED_FROM_PUSH @"OPENED_FROM_PUSH"

#define SHOW_HELP_TOOLTIP_MAIN @"show_help_tooltip_main"
#define SHOW_HELP_TOOLTIP_RECIPIENTS @"show_help_tooltip_recipients"
#define SHOW_HELP_TOOLTIP_SETTINGS @"show_help_tooltip_settings"
#define SHOW_HELP_TOOLTIP_TEMPLATES @"show_help_tooltip_templates"
#define SHOW_HELP_TOOLTIP_CONTACT_DETAILS @"show_help_tooltip_contact_details"
#define SHOW_HELP_TOOLTIP_APP_SETTINGS @"show_help_tooltip_app_settings"

//if i have this selected
#define FORCE_INDIVIDUAL_SMS @"force_individual_sms"
//if i have already shown the warning
#define SHOW_FORCE_INDIVIDUAL_SMS_WARN @"show_force_individual_sms_warn"

@interface PCViewController : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate, FBSDKSharingDelegate,UICollectionViewDataSource,UICollectionViewDelegate,
UITextFieldDelegate, NSURLConnectionDelegate,SKStoreProductViewControllerDelegate,QBImagePickerControllerDelegate, PopupDelegate, CMPopTipViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *attachmentsScrollview;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollection;
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblAsterisk;
@property (weak, nonatomic) IBOutlet UILabel *lblPremium;
- (IBAction)switchSaveMessageValueChanged:(id)sender;
- (IBAction)switchScheduleMessageValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelSubject;
@property (strong, nonatomic) IBOutlet UILabel *labelOnlySocial;
@property (weak, nonatomic) IBOutlet UILabel *labelAttachCount;

@property (strong, nonatomic) IBOutlet UISwitch *saveMessageSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *scheduleLaterSwitch;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;

@property (weak, nonatomic) IBOutlet UILabel *labelAttach;
//@property ABAddressBookRef addressBook;
//@property (strong, nonatomic) IBOutlet ADBannerView *adBannerView;

@property (strong, nonatomic) IBOutlet UIImageView *attachImageView;

@property (strong, nonatomic) IBOutlet UIImage *attachImage;
//@property (strong, nonatomic) IBOutlet UIImage *previewImage;
@property (weak, nonatomic) IBOutlet UIImageView *addRemoveRecipientsView;

@property (strong, nonatomic) IBOutlet NSMutableArray *attachments;

@property (strong, nonatomic) UIImage *addImage;
@property (strong, nonatomic) UIImage *removeImage;

//for the linkdin request
@property NSMutableData *responseData;

@property NSMutableArray *imagesArray;

@property (strong, nonatomic) LIALinkedInHttpClient *_client;

@property (strong, nonatomic) PCPopupViewController  *popupView;
@property (strong, nonatomic) UIView *pickerBlockView;

//will hold all the recipients for the text message only (so we can send 1 by 1)
@property (strong, nonatomic) NSMutableArray *messageRecipients;

@property BOOL isDeviceOnline;

-(IBAction)loadContactsList:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)sendEmail:(id)sender;
-(IBAction)sendSMS:(id)sender isRecursive:(BOOL) isRecursive;
-(IBAction)presentMediaPicker:(id) sender;
-(NSMutableArray *) getEmailAdresses;
-(NSMutableArray *) getPhoneNumbers;
- (NSData *) getImageInfoData: (UIImage *)img;

@property (strong, nonatomic) UIAlertController *pending;

void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context);
-(void)setupAddressBook;
-(void) checkForPrefilledMessage;
-(BOOL) checkIfShouldWarnAboutImessage;
-(void) warnAboutImessage: (void (^)(BOOL finished))completion;
-(void) checkForPrefilledScheduledMessage: (NSString *) modelIdentifier;
-(void) updateAddRemoveRecipients;
//Purchase stuff
-(void)showUpgradeToPremiumMessage;
- (void)productPurchased:(NSNotification *)notification;
- (void) buyProductWithidentifier: (NSString *) productId; /*andCompletionHandler:  (void (^)(BOOL success))completion*/

@property (strong, nonatomic) IBOutlet UITextField *subject;

//attach image
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageName;

@property (weak, nonatomic) IBOutlet UIView *subjectView;

@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *body;
@property (strong, nonatomic) IBOutlet UIImageView *lockImage;

//@property (strong, nonatomic) UIImage *attachImage;
//@property (strong, nonatomic) UIImage *imageUnlock;

@property (strong, nonatomic) IBOutlet UILabel *labelSaveArchive;
@property (strong, nonatomic) NSTimer *changeTimer;


@property(strong,nonatomic) SettingsViewController* settingsController;
@property(strong,nonatomic) SelectRecipientsViewController *recipientsController;
@property(strong,nonatomic) IAPMasterViewController *inAppPurchaseTableController;
@property (strong, nonatomic) CustomMessagesController *customMessagesController;


@property (strong,nonatomic) NSMutableArray *selectedRecipientsList;
//to open flappy
@property SKStoreProductViewController *storeController;

@property BOOL emailSentOK;
@property BOOL smsSentOK;
@property BOOL showAds;
@property BOOL facebookSentOK;
@property BOOL twitterSentOK;
@property BOOL sendToFacebook;
@property BOOL sendToTwitter;
@property BOOL sendToLinkedin;
@property BOOL timeToShowPromoPopup;
@property BOOL saveMessage;

@property (strong,nonatomic) CMPopTipView *tooltipView;
@property BOOL isShowingTooltip;

@end
