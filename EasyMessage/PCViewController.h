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

@class SelectRecipientsViewController;
@class IAPMasterViewController;
@class CustomMessagesController;

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define PROMO_SHOW_COUNTER @"promo_show_counter"


@interface PCViewController : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,UITextFieldDelegate, FBSDKSharingDelegate,
UITextFieldDelegate, NSURLConnectionDelegate,SKStoreProductViewControllerDelegate>
- (IBAction)sendMessage:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)switchSaveMessageValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *labelMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelSubject;
@property (strong, nonatomic) IBOutlet UILabel *labelOnlySocial;

@property (strong, nonatomic) IBOutlet UISwitch *saveMessageSwitch;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;

@property (weak, nonatomic) IBOutlet UILabel *labelAttach;
//@property ABAddressBookRef addressBook;
//@property (strong, nonatomic) IBOutlet ADBannerView *adBannerView;

@property (strong, nonatomic) IBOutlet UIImageView *attachImageView;

@property (strong, nonatomic) IBOutlet UIImage *attachImage;
//@property (strong, nonatomic) IBOutlet UIImage *previewImage;

//for the linkdin request
@property NSMutableData *responseData;

@property (strong, nonatomic) LIALinkedInHttpClient *_client;

@property (strong, nonatomic) PCPopupViewController  *popupView;


-(IBAction)loadContactsList:(id)sender;
- (IBAction)showSettings:(id)sender;
- (IBAction)sendEmail:(id)sender;
-(IBAction)sendSMS:(id)sender;
-(IBAction)presentMediaPicker:(id) sender;
-(NSMutableArray *) getEmailAdresses;
-(NSMutableArray *) getPhoneNumbers;

void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context);
-(void)setupAddressBook;
-(void) checkForPrefilledMessage;

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


@end
