//
//  PCViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCViewController.h"
#import "Contact.h"
#import "Group.h"
#import "SelectRecipientsViewController.h"
#import "SocialNetworksViewController.h"
#import "IAPMasterViewController.h"
#import "CoreDataUtils.h"
#import "ContactDataModel.h"
#import "MessageDataModel.h"
#import "CustomMessagesController.h"
#import "LIALinkedInHttpClient.h"

//#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPRequestOperation.h"
#import "JSONResponseSerializerWithData.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface PCViewController ()

@end

@implementation PCViewController

@synthesize settingsController,subject,body,image;
@synthesize selectedRecipientsList,scrollView,recipientsController;
@synthesize smsSentOK,emailSentOK,sendButton;
@synthesize labelMessage,labelSubject,labelOnlySocial;
@synthesize sendToFacebook,sendToTwitter,sendToLinkedin,facebookSentOK,twitterSentOK;
@synthesize changeTimer,saveMessageSwitch,saveMessage,inAppPurchaseTableController;
@synthesize labelSaveArchive,lockImage;
@synthesize customMessagesController;
@synthesize imageName;
@synthesize storeController;
@synthesize popupView;
@synthesize showAds;
@synthesize  timeToShowPromoPopup;
@synthesize attachImageView;
@synthesize labelAttach;
@synthesize subjectView;
@synthesize recipientsLabel;
@synthesize attachImage;
@synthesize attachments;
@synthesize labelAttachCount;
@synthesize lblAsterisk,lblPremium;
@synthesize addRemoveRecipientsView;
@synthesize addImage, removeImage;
//google plus sdk
//TODO check
static NSString * const kClientId = @"122031362005-ibifir1r1aijhke7r3fe404usutpdnlq.apps.googleusercontent.com";

- (void)viewDidLoad
{
    //[super viewDidLoad];
    //settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = NSLocalizedString(@"app_name",@"EasyMessage");
    labelSaveArchive.text = NSLocalizedString(@"archive_message", @"save in archive");
 
    labelAttach.text = NSLocalizedString(@"attach_image", @"Attach an image?");
    
    //OOPPSS!!!
    attachments = [[NSMutableArray alloc] init];
    
    [self.imagesCollection registerNib:[UINib nibWithNibName:@"AttachCellCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    //[self.imagesCollection registerClass:AttachCellCollectionViewCell.class forCellWithReuseIdentifier:@"imageCell"];
   // [self.imagesCollection registerNib:[UINib nibWithNibName:@"AttachCellCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    //.register(UINib(nibName: "name", bundle: nil), forCellWithReuseIdentifier: "cellIdentifier")
    self.imagesCollection.scrollEnabled = true;
   //  self.imagesCollection setS
    self.imagesCollection.dataSource = self;
    self.imagesCollection.delegate = self;
    
    addImage = [UIImage imageNamed:@"add"];
    removeImage = [UIImage imageNamed:@"delete"];
    
    /*for(int i = 0; i < 3; i++) {
     UIImage *img = [UIImage imageNamed:@"attachment"];
        [attachments addObject:img];
    }
    [self.imagesCollection reloadData];*/
    
    smsSentOK = NO;
    emailSentOK = NO;
    facebookSentOK = NO;
    twitterSentOK = NO;
    sendToTwitter = NO;
    sendToFacebook = NO;
    sendToLinkedin = NO;
    saveMessage = NO;
    recipientsLabel.text =  NSLocalizedString(@"no_recipients",@"no_recipients");

    labelOnlySocial.text = NSLocalizedString(@"no_recipients_only_social","@only social post, no recipients selected");
    
    subject.delegate = self;
    body.delegate = self;
    
    subject.layer.borderWidth = 1.0f;
    subject.layer.borderColor = [[UIColor grayColor] CGColor];
    
    body.layer.borderWidth = 1.0f;
    body.layer.borderColor = [[UIColor grayColor] CGColor];
    
    [sendButton setTitle:NSLocalizedString(@"send_message",nil) forState:UIControlStateNormal];
    
    subject.placeholder = NSLocalizedString(@"placeholder_subject",nil);
    [body setPlaceholder: NSLocalizedString(@"placeholder_your_message", nil)];
    
    labelSubject.text = NSLocalizedString(@"subject_label",nil);
    labelMessage.text = [NSString stringWithFormat:@"%@ (*)", NSLocalizedString(@"message_label",nil)];
    
    //the table that shows the in app purchases
    inAppPurchaseTableController = [[IAPMasterViewController alloc] initWithNibName:@"IAPMasterViewController" bundle:nil];
    
    //set the images
    //imageLock = [UIImage imageNamed:@"Lock32"];
    //imageUnlock = [UIImage imageNamed:@"Unlock32"];
    
    selectedRecipientsList = [[NSMutableArray alloc]init];
    [scrollView flashScrollIndicators];
    
    [scrollView setContentSize: CGSizeMake(0, self.view.frame.size.height)];//;self.view.frame.size
    [self.scrollView setContentOffset: CGPointMake(0, self.scrollView.contentOffset.y)];
    self.scrollView.directionalLockEnabled = YES;
    
    [self.attachmentsScrollview setContentSize: CGSizeMake(self.imagesCollection.frame.size.width,0 )];//;self.view.frame.size
    [self.attachmentsScrollview setContentOffset: CGPointMake(self.attachmentsScrollview.contentOffset.x,0)];
    self.attachmentsScrollview.directionalLockEnabled = YES;
    
    //TODO possible solution check
    //CGSize scrollSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //[scrollView setContentSize: scrollSize];
    self.tabBarController.tabBar.tintColor = [self colorFromHex:0xfb922b];
    
    //load the contacts list when the view loads
    [self setupAddressBook];
    //self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableViewBackground.png"]];
    
    [self writeImportTime];
    
    attachImage = [UIImage imageNamed:@"attachment"];
    
    showAds = false;
    //shows / hides the banner, every 30 seconds interval
    //[NSTimer scheduledTimerWithTimeInterval: 30.0 target: self
    //                                                  selector: @selector(callBannerCheck:) userInfo: nil repeats: YES];
   
    //linkedin client here
    self._client = [self client];
    
    //to add attachments
    [self setupAttachViewTouch ];
    [self setupAddRemoveRecipientsViewTouch];
    
    //the ads stuff
    BOOL purchasedPremium = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE];
    if(!purchasedPremium) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    }

    [super viewDidLoad];
    
 
  
}

- (UIColor *)colorFromHex:(unsigned long)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:1.0];
}

-(void) updatePremiumLabels {
    if([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
        lblAsterisk.text =@"";
        lblAsterisk.enabled = false;
        lblPremium.text =@"";
        lblPremium.enabled = false;
    }
    else {
        lblPremium.text = NSLocalizedString(@"lite_only_2_attachments", nil);
    }
}

#pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.attachments.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"imageCell";
    AttachCellCollectionViewCell *cell = (AttachCellCollectionViewCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    /*if(cell==nil) {
        // [self.imagesCollection registerNib:[UINib nibWithNibName:@"AttachCellCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
       
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AttachCellCollectionViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }*/
    cell.removeAttachment.tag = indexPath.row;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAttachmentClicked:) ];
    singleTap.numberOfTapsRequired = 1;
    [cell.removeAttachment setUserInteractionEnabled:YES];
    [cell.removeAttachment addGestureRecognizer:singleTap];

    
    // get the image
    NSArray *data = [self.attachments objectAtIndex: indexPath.row];
    UIImage *image = [data objectAtIndex:0]; //[self.attachments objectAtIndex: indexPath.row];
    
     dispatch_async(dispatch_get_main_queue(), ^{
         // populate the cell
         cell.attachImage.image = image;
     });
    //cell.label.text =@"fucck";
    // return the cell
    return cell;
}

#pragma UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UIImage *selected = [self.attachments objectAtIndex:indexPath.row];
    NSLog(@"selected image at index %lu", indexPath.row);
}

-(void)removeAttachmentClicked:(UIGestureRecognizer* ) sender
{
    NSInteger pos = sender.view.tag;
    if(pos < self.attachments.count) {
        [self.attachments removeObjectAtIndex:pos];
        [self.imagesCollection reloadData];
        [self updateAttachmentsLabel];
        NSString *msg = [NSString stringWithFormat:@"%@ %@!",NSLocalizedString(@"removed",@"removed"),[NSString stringWithFormat:@"pic %ld",(long)pos+1]];
        
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:3000] show];
    }
}

-(void) writeImportTime {
    double nowMilis = [[NSDate date] timeIntervalSince1970] * 1000;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue: [NSString stringWithFormat:@"%f",  nowMilis] forKey:@"last_import"];
}

-(NSString *) readImportTime {
    //check time of last import, and do it again if older than 5 hours
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastImport = [defaults valueForKey:@"last_import"];
    return lastImport; //could be nil??
}
-(void) viewDidAppear:(BOOL)animated {
    
    //get current date/time
    double nowMilis = [[NSDate date] timeIntervalSince1970] * 1000;
    //read date/time of last import
    NSString *lastImport = [self readImportTime];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //this key is added every time i add a new contact
    bool forceImport = [defaults boolForKey:@"force_import"];
    
    if(lastImport != nil || forceImport) {
        double lastImportMilis = lastImport.doubleValue;
        //last import done more than 1 hours ago? load them again!
        if( (nowMilis - lastImportMilis > 1*60*60*1000) || forceImport ) {
            [self setupAddressBook];
            //update the import date/time
            [defaults setValue: [NSString stringWithFormat:@"%f",  nowMilis] forKey:@"last_import"];
            
            if(forceImport) {
                [defaults setBool:false forKey:@"force_import"];
            }
        }
    }
    
    
    
    //if we have a prefill text we use it
    [self checkForPrefilledMessage];
    //update the buuton to add/remove
    [self updateAddRemoveRecipients];
}

-(void) checkForPrefilledMessage{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if([defaults valueForKey:@"prefillMessage"] != nil) {
        self.body.text = [defaults valueForKey:@"prefillMessage"];
        [defaults removeObjectForKey:@"prefillMessage"];
        
        //is a prefill message of type birthday
        if([[defaults valueForKey:@"prefillMessageType"] isEqualToString:@"birthday"] ) {
            //day & month of the birthday (same as today date maybe?)
            NSUInteger day = [[defaults valueForKey:@"day"] integerValue];
            NSUInteger month = [[defaults valueForKey:@"month"] integerValue];
            
            [defaults removeObjectForKey:@"day"];
            [defaults removeObjectForKey:@"month"];
            
             [defaults removeObjectForKey:@"prefillMessageType"];
            
            //TODO improve this, i should not need to fetch the contacts again, but for 1st implementation is OK!
            [self.recipientsController searchForBirthdayIn:day month:month];
            
        }
        
        [defaults synchronize];
    }
}
//before IOS 10
//TODO make generic for other type of notifications
-(void) scheduleNotification: (NSString *) type nameOfContact: name month: (NSInteger) month day: (NSInteger) day fireDelayInSeconds: (NSTimeInterval) delay{
    //Get all previous notifications..
    NSLog(@"scheduled notifications: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    NSString *possibleAlarmId = [NSString stringWithFormat: @"%@", [NSString stringWithFormat:@"%@%ld%ld",name,(long)day,(long)month]];
    for(UILocalNotification *notification in notifications ) {
        
        
        NSString *alarmID = [notification.userInfo valueForKey:@"alarmID"];
        if(alarmID !=nil && [alarmID isEqualToString: possibleAlarmId]) {
            NSLog(@"already scheduled this notification: %@ ,skip it...", alarmID);
            return;
        }
    }
    //otherwise continue
    
    NSDate *fireDate = [NSDate date];
    fireDate = [fireDate dateByAddingTimeInterval: delay]; //60 seconds or 24 hours
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit fromDate: fireDate];
    
    
    NSDate *SetAlarmAt = [calendar dateFromComponents:components];
    
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = SetAlarmAt;
    
    //if more than one we do not add the name, but if only 1 then it is more personalized msg!!!
    //TODO translate this str
    
    if([type isEqualToString:@"birthday"]) {
        
        NSLog(@"birthday notification fire date: %@ ",[SetAlarmAt description]);
        
        //aniversary_of
        NSString *message = [NSString stringWithFormat: NSLocalizedString(@"aniversary_of", @"aniversary_of"), name];
        localNotification.alertBody = message;// [NSString stringWithFormat:@"Its the Aniversary of %@", name];
        
        localNotification.alertAction = [NSString stringWithFormat:@"My test for Weekly alarm"];
        
        //add to user defaults to avoid schedule it again
        NSString *alarmID = [NSString stringWithFormat: @"%@", [NSString stringWithFormat:@"%@%ld%ld",name,(long)day,(long)month]];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:alarmID forKey:@"alarmID"];
        
        localNotification.userInfo = @{
                                       @"alarmID":alarmID,//,
                                       @"Type":type,
                                       @"day" : [NSString stringWithFormat:@"%ld", (long)day ],
                                       @"month" : [NSString stringWithFormat:@"%ld", (long)month ],
                                       @"name" : name
                                       };
        localNotification.repeatInterval=0; //[NSCalendar currentCalendar];
    }//else do other cases on other releases
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(void) notifsAfter10 {
    //https://stackoverflow.com/questions/39941778/how-to-schedule-a-local-notification-in-ios-10-objective-c
    NSDate *now = [NSDate date];
    
    // NSLog(@"NSDate--before:%@",now);
    
    now = [now dateByAddingTimeInterval:60];
    
    NSLog(@"NSDate:%@",now);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit fromDate:now];
    
    NSDate *todaySehri = [calendar dateFromComponents:components]; //unused
    
    
    
    UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Notification!" arguments:nil];
    objNotificationContent.body = [NSString localizedUserNotificationStringForKey:@"This is local notification message!"
                                                                        arguments:nil];
    objNotificationContent.sound = [UNNotificationSound defaultSound];
    
    /// 4. update application icon badge number
    objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ten"
                                                                          content:objNotificationContent trigger:trigger];
    /// 3. schedule localNotification
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
}


//override
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"email"];
        self.tabBarItem.title = NSLocalizedString(@"compose",nil);
        
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"clear", @"clear") style:UIBarButtonItemStyleDone target:self action:@selector(clearClicked:)];
        
        clearButton.tintColor = UIColor.whiteColor;
        self.navigationItem.rightBarButtonItem = clearButton;
        
   
        
        //attach buttom
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"share", @"share") style:UIBarButtonItemStyleDone target:self action:@selector(shareClicked:)];
        
        shareButton.tintColor = UIColor.whiteColor;
        self.navigationItem.leftBarButtonItem = shareButton;
        
    }
    return  self;
}

//setup touch on promo image
-(void) setupPromoViewTouch {

        popupView.imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPromoViewWithGesture:)];
        [popupView.imageView addGestureRecognizer:tapGesture];

}
- (void)didTapPromoViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    [popupView.view removeFromSuperview];
    [self openAppStore];

    
}

//setup touch on promo image
-(void) setupAttachViewTouch {
    
    attachImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAttachViewWithGesture:)];
    [attachImageView addGestureRecognizer:tapGesture];
    
}


#pragma remove or add recipients
//TODO NEW
-(void) setupAddRemoveRecipientsViewTouch {
    //add or remove from main page
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addRemoveRecipientsClicked:) ];
    singleTap.numberOfTapsRequired = 1;
    [addRemoveRecipientsView setUserInteractionEnabled:YES];
    [addRemoveRecipientsView addGestureRecognizer:singleTap];
}

- (void)addRemoveRecipientsClicked:(UITapGestureRecognizer *)tapGesture {
    //TODO either add or remove
    if(self.selectedRecipientsList.count > 0) {
        //REMOVE
        [self.recipientsController clearRecipients]; //will remove all
        [self.selectedRecipientsList removeAllObjects];
        [self updateAddRemoveRecipients];
        recipientsLabel.text = NSLocalizedString(@"no_recipients",@"no_recipients");;
     } else {
          //ADD
          //TODO NAVIGATE
          [self.tabBarController setSelectedIndex:1];
        }
}

- (void)didTapAttachViewWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (![[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE] && self.attachments.count == MAX_ATTACHMENTS_WITHOUT_PREMIUM) {
        [self showAlertBox:NSLocalizedString(@"lite_reached_max_attachments", nil)];
    }
    else {
        [self presentMediaPicker:nil];
    }
    
}


//update at a given interval
/*
-(void) updateBannerView {
    
    if(self.showAds==false){
        
        [self.adView setHidden: true];
    }
    else {
        [self.adView setHidden:!self.adView.isHidden];
    }
}*/

//called every 30 seconds
/*
-(void) callBannerCheck:(NSTimer*) t
{
 
    if(self.adView!=nil) {
        
        [self updateBannerView];
        
    }
}*/



/**
 *Adjust banner view stuff
 *
- (void) adjustBannerView {
    CGRect contentViewFrame = self.view.bounds;
    CGRect adBannerFrame = self.adBannerView.frame;
    
    if([self.adBannerView isBannerLoaded])
    {
        CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:self.adBannerView.currentContentSizeIdentifier];
        contentViewFrame.size.height = contentViewFrame.size.height - bannerSize.height;
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    else
    {
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.adBannerView.frame = adBannerFrame;
        self.view.frame = contentViewFrame;
    }];
}*/

//appear/disappear logic
-(void) viewWillAppear:(BOOL)animated {
    
    if (@available(iOS 11.0, *)) {
        self.sendButton.accessibilityIgnoresInvertColors = true;
    }
    
    [self showHideSocialOnlyLabel];
    [self updateAttachmentsLabel];
    [self updatePremiumLabels];
    
    //subject is disabled for SMS only or social posts
    [self checkIfPostToSocial];
    if( (sendToFacebook || sendToTwitter || sendToLinkedin) && (selectedRecipientsList.count==0) ) {
        
        //[self.navigationItem.leftBarButtonItem setEnabled:true];
        //if(selectedRecipientsList.count==0) {
        if(settingsController.selectSendOption != OPTION_ALWAYS_SEND_BOTH_ID) {
            [subject setEnabled:false];
            [subjectView setHidden:true];
        } else {
            //always send both is selected
            [subject setEnabled:true];
            [subjectView setHidden:false];
        }
        
    }
    else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
        
          [subject setEnabled:false];
          [subjectView setHidden:true];
    }
    else {
          [subject setEnabled:true];
          [subjectView setHidden:false];
    }
    
    //always ON
    //[saveMessageSwitch setEnabled:purchasedCommonMessages];
    [saveMessageSwitch setEnabled:true];
    [self.navigationItem.rightBarButtonItem setEnabled: (subject.text.length > 0 || body.text.length>0) ];
    
    [self updateAttachButton];
    
    //always hide the social if the subject is showing
    if(!subjectView.hidden) {
       [labelOnlySocial setHidden:true];
    }
}

//clear stuff

-(IBAction)clearClicked:(id)sender
{
    [self clearInputFields];
}



-(void) showHideSocialOnlyLabel {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //always hide if this is showing, cause it is on the same place
        if(!subjectView.hidden) {
            [labelOnlySocial setHidden:true];
        } else {
            
            if(selectedRecipientsList.count==0 && settingsController.socialOptionsController.selectedServiceOptions.count>0) {
                labelOnlySocial.hidden = NO;
            }
            else {
                labelOnlySocial.hidden = YES;
            }
        }

    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//delegate for the subject uitextfield 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == subject) {
        [subject resignFirstResponder];
        return YES;
    }

    return YES;
}
//show teh clear button
-(void) checkIfShowClearButton:(UITextField *)textField  {
    
    BOOL isEnabled = [self.navigationItem.rightBarButtonItem isEnabled];
    NSInteger lengthBody = textField.text.length;
    
    if(lengthBody>=1 && !isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else if(lengthBody==0 && isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self checkIfShowClearButton:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self checkIfShowClearButton:textField];
    
    return YES;
}

//text view delegate to enable/disable the clear button
-(void)textViewDidChange:(UITextView *)textView {
   
    NSLog(@"textViewDidChange YES");
    BOOL isEnabled = [self.navigationItem.rightBarButtonItem isEnabled];
    NSInteger lengthBody = textView.text.length;
    
    if(lengthBody>=1 && !isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else if(lengthBody==0 && isEnabled) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
}

//delegate for the body uitextview
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        [body resignFirstResponder];
        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    // For any other character return TRUE so that the text gets added to the view
    return YES;
}





/**
 * Checks if post to social is active
 */
- (void) checkIfPostToSocial {
    BOOL isFacebookAvailable = settingsController.socialOptionsController.isFacebookAvailable;
    BOOL isTwitterAvailable = settingsController.socialOptionsController.isTwitterAvailable;
    BOOL isFacebookSelected = NO;
    BOOL isTwitterSelected = NO;

    
    if(isFacebookAvailable) {
        isFacebookSelected = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_FACEBOOK_ONLY];
        
        //if ([FBSDKAccessToken currentAccessToken]) {
            // User is logged in, do work such as go to next view controller.
        //}
    }
    if(isTwitterAvailable) {
        isTwitterSelected = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_TWITTER_ONLY];
    }
    
    sendToFacebook = isFacebookSelected;
    sendToTwitter = isTwitterSelected;
    sendToLinkedin = [settingsController.socialOptionsController.selectedServiceOptions containsObject: OPTION_SENDTO_LINKEDIN_ONLY];
}

- (IBAction)sendMessage:(id)sender {
    
    
    [self checkIfPostToSocial];
    
    if(subject.text.length==0 && body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_both_empty", @"Subject and message body cannot be empty!")];
         
    }
    else if(body.text.length==0) {
        
        [self showAlertBox: NSLocalizedString(@"alert_message_body_empty",@"The message body cannot be empty!")];

    }
    else if(selectedRecipientsList.count==0 ) {
        
        if(!sendToFacebook && !sendToTwitter && !sendToLinkedin) {
           [self showAlertBox: NSLocalizedString(@"alert_message_select_least_one",@"You need to select at least one recipient!")]; 
        }
        else {
            [self sendToSocialNetworks:body.text];
        
        }
        //if we do not have recipients, neither are using social networks show message
        
    }
    else { //we have recipients
       
        /**
         #define OPTION_ALWAYS_SEND_BOTH   @"Always send both" 0
         #define OPTION_SEND_EMAIL_ONLY    @"Send email only" 1
         #define OPTION_SEND_SMS_ONLY      @"Send SMS only" 2
         
         #define OPTION_PREF_SERVICE_ALL    @"Use both services" 0
         #define OPTION_PREF_SERVICE_EMAIL  @"Email service" 1
         #define OPTION_PREF_SERVICE_SMS    @"SMS service" 2
         
         //further options
         #define ITEM_PHONE_MOBILE_ID 0
         #define ITEM_PHONE_IPHONE_ID 1
         #define ITEM_PHONE_HOME_ID   2
         #define ITEM_PHONE_WORK_ID   3
         #define ITEM_PHONE_MAIN_ID   4
         
         
         #define ITEM_EMAIL_HOME_ID  0
         #define ITEM_EMAIL_WORK_ID  1
         #define ITEM_EMAIL_OTHER_ID 2
         
         **/
       
        @try {
            
            //show the warning and exit!
            if( (settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID || settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID) ) {
                
                if([self checkIfShouldWarnAboutImessage]) {
                  [self warnAboutImessage];
                }
                
                //proceeed normally only after dismiss the popup
                if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                    
                    emailSentOK = NO;
                    
                    [self sendEmail:nil];//will send sms on dismiss email
                    //need to check is there is any email on the recipients list
                }
                else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                    
                    smsSentOK = NO;
                    [self sendSMS:nil];
                }
            } else {
                //proceed normally
                if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                    
                    emailSentOK = NO;
                    
                    [self sendEmail:nil];//will send sms on dismiss email
                }
                else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                    
                    smsSentOK = NO;
                    [self sendSMS:nil];
                }
            }
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error sending message: %@", exception.description);
        }
        @finally {
            //clear facebook and twitter selection
            //if(isTwitterSelected || isFacebookSelected) {
            //    [self resetSocialNetworks];
            //}
            
        }

        
    }
    
    //reset image attachment TODO not here
    /**
    image = nil;
    imageName = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"attach",@"attach");
    });**/
    
    
}

//have i show this before? show only once
-(BOOL) checkIfShouldWarnAboutImessage {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL warnedBefore = [defaults boolForKey:KEY_WARNED_ABOUT_IMESSAGE];
    
    if(!warnedBefore) {
        [defaults setBool:true forKey:KEY_WARNED_ABOUT_IMESSAGE];
        return true;
    }
    return false;
}

//shows a message to disable iMessage
-(void) warnAboutImessage {
    
    Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                       subTitle:NSLocalizedString(@"imessage_warn",nil)
                                    cancelTitle:NSLocalizedString(@"Cancel",nil)
                                   successTitle:@"Ok"
                                    cancelBlock:^{
                                        //Custom code after cancel button was pressed
                                        NSLog(@"nok");
                                    } successBlock:^{
                                        //Custom code after success button was pressed
                                        NSLog(@"ok");
                                    }];
    
    [popup setBackgroundColor:[self colorFromHex:0xfb922b]];
    //https://github.com/miscavage/Popup
    [popup setBorderColor:[UIColor blackColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup setSuccessBtnColor:[self colorFromHex:0x4f6781]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelBtnColor:[self colorFromHex:0x4f6781]];
    [popup setCancelTitleColor:[UIColor whiteColor]];
    //[popup setBackgroundBlurType:PopupBackGroundBlurTypeLight];
    [popup setRoundedCorners:YES];
    [popup setTapBackgroundToDismiss:YES];
    [popup setDelegate:self];
    [popup showPopup];
    //do not warn me again
}

-(void) checkIfAskForReview {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numMessages = [defaults integerForKey:KEY_ASK_FOR_REVIEW];
    
    numMessages+=1;
    
    //NSLog(@"NUM MESSAGES IS: %ld", (long)numMessages);
    if(numMessages > 2) {
        
        if (@available(iOS 10.3, *)) {
         [SKStoreReviewController requestReview];
         }
         else {
        
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Easy Message"
                                                        message: NSLocalizedString(@"ask_to_rate", nil)
                                                       delegate:self
                                              cancelButtonTitle: NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:@"OK", nil];
             [alert show];
        }
    }
    
    [defaults setInteger:numMessages forKey:KEY_ASK_FOR_REVIEW];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save/ok
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1448046358?mt=8&action=write-review"]];
    }
}

//showAlertBox messageios
-(void) showAlertBox:(NSString *) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Easy Message"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)showUpgradeToPremiumMessage {
    
    Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                       subTitle:NSLocalizedString(@"premium_feature_only", nil)
                                    cancelTitle:NSLocalizedString(@"Cancel",nil)
                                   successTitle:@"OK"
                                    cancelBlock:^{
                                        //Custom code after cancel button was pressed
                                    } successBlock:^{
                                        //Custom code after success button was pressed
                                        //NSLog(@"Try Buying %@...", PRODUCT_PREMIUM_UPGRADE);
                                        [self buyProductWithidentifier:PRODUCT_PREMIUM_UPGRADE];
                                    }];
    
    [popup setBackgroundColor:[self colorFromHex:0xfb922b]];
    //https://github.com/miscavage/Popup
    [popup setBorderColor:[UIColor blackColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup setSuccessBtnColor:[self colorFromHex:0x4f6781]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelBtnColor:[self colorFromHex:0x4f6781]];
    [popup setCancelTitleColor:[UIColor whiteColor]];
    //[popup setBackgroundBlurType:PopupBackGroundBlurTypeLight];
    [popup setRoundedCorners:YES];
    [popup setTapBackgroundToDismiss:YES];
    [popup setDelegate:self];
    [popup showPopup];
}


//get the notification when a product is purchased
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    if([productIdentifier isEqualToString:PRODUCT_PREMIUM_UPGRADE]) {
        //NSLog(@"Purchased %@...",productIdentifier);
        //unlock any stuff
        [self updateAttachmentsLabel];
        [self updatePremiumLabels];
    }
    
}

- (void) buyProductWithidentifier: (NSString *) productId/* andCompletionHandler:  (void (^)(BOOL success))completion*/ {
    
    [[EasyMessageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            for(SKProduct *product in products) {
                if([product.productIdentifier isEqualToString:productId]) {
                    
                    [[EasyMessageIAPHelper sharedInstance] buyProduct:product];
                }
                
            }
            
            
        }
    }];
    
}


//send to social networks
-(void)sendToSocialNetworks: (NSString*) message {
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:message];
    
    [[[[iToast makeText:NSLocalizedString(@"message_copied_clipboard", @"")]
       setGravity:iToastGravityBottom] setDuration:1000] show];
    
        if(sendToFacebook) {
            //NOTE: if twitter is also selected, it will show up/send on facebook result
            [self sendToFacebook:message];
        }
        else if(sendToTwitter) {
            //on dismiss we check if send to linkedin is selected
            [self sendToTwitter:message];
        }
        else if(!sendToFacebook && !sendToTwitter && sendToLinkedin) {
            //send to linkedin only
            //before send check if we need authorization
            [self authorizeAndSendToLinkedin: message];
            
        }
    
  
}
//auth and send
-(void) authorizeAndSendToLinkedin: (NSString *) message {
    NSString * token = [self accessToken];
    if(token!=nil && [self validToken]) {
        [self sendToLinkedin:message withToken:token];
    }
    else {
        //either is nill or invalid
        [self connectWithLinkedIn:message];
    }
}
//create the address book reference and register the callback
-(void)setupAddressBook {
    
    @try {
        [self loadContactsList:nil];
        double nowMilis = [[NSDate date] timeIntervalSince1970] * 1000;
        NSString *lastImport = [NSString stringWithFormat:@"%f",  nowMilis];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:lastImport forKey:@"last_import"];
    }
    @catch (NSException *exception) {
        [self showAlertBox:[NSString stringWithFormat: NSLocalizedString(@"unable_load_contacts_error_%@", @"unable to read contacts from AB"),exception.description]];
    }
    @finally {
        //do nothing
    }
    
    
}
// we need to show this message if we don´t have permissions
-(void) showPermissionsMessage {
    
    // Display an error.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permissions issue!"
                                                        message:@"Permission was denied. Cannot load address book. Please change privacy settings in settings app"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
    [alert show];
}

// for these we do not need any special permissions
-(void) loadContactsFromCoreDataOnly {
    
    NSInteger duplicates = 0;
    NSMutableArray *cleanList = [[NSMutableArray alloc] init];
    //load also the local contact models, from local database
    NSMutableArray *models = [self fetchLocalContactModelRecords];
    
    //auxiliar list to check for duplicates (might slow down stuff)
    for(Contact *c in models) {
        c.isNative = false;
        if(![cleanList containsObject:c]) {
            [cleanList addObject:c];
        }
        else {
            duplicates++;
        }
    }
    
    NSLog(@"readed %ld contacts from core data models, but will only add %ld",(unsigned long)models.count, cleanList.count);
    
    [recipientsController.contactsList addObjectsFromArray:cleanList];
    
    [recipientsController.selectedContactsList removeAllObjects];
    [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
    
    NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
}

-(IBAction)loadContactsList:(id)sender {
    
    //cannot proceed without this or a get a black screen
    if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted ) {
        [self showPermissionsMessage];
        //still load these anyway, no need permissions
        [self loadContactsFromCoreDataOnly];
        //load also the groups
        NSMutableArray *groupsFromDB = [self fetchGroupRecords];
        [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.groupsList removeAllObjects];
        [recipientsController.groupsNamesArray removeAllObjects];
        
        [recipientsController refreshPhonebook:nil];
        return;
    }
    
    
    CFErrorRef * error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    NSMutableArray __block *contacts;
    
    CFRetain(addressBook);
    
    //register a callback to track adressbook changes
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, (__bridge void *)(self));
    
    // Request authorization to Address Book
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            // First time access has been granted, add the contact
            if(granted==true) {
                
                NSMutableArray *cleanList = [[NSMutableArray alloc] init];
                NSLog(@"granted permission");
                //load from address book
                contacts = [self loadContacts: addressBook];
                
                NSInteger duplicates = 0;
                //auxiliar list to check for duplicates (might slow down stuff)
                for(Contact *c in contacts) {
                    c.isNative = true;
                    if(![cleanList containsObject:c]) {
                        [cleanList addObject:c];
                    }
                    else {
                        duplicates++;
                    }
                }
                
                NSLog(@"readed %ld contacts from local address book, but will only add %ld",(unsigned long)contacts.count, cleanList.count);
                
                NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
                [recipientsController.contactsList removeAllObjects];
                [recipientsController.contactsList addObjectsFromArray:cleanList];
                
                [self loadContactsFromCoreDataOnly];
                
                //load native groups, from icloud
                NSMutableArray *groupsFromICloud = [self loadGroups:addressBook];
                if(groupsFromICloud!=nil && groupsFromICloud.count > 0) {
                    [recipientsController.contactsList addObjectsFromArray:groupsFromICloud];
                }
                
                //load also the groups
                NSMutableArray *groupsFromDB = [self fetchGroupRecords];
                [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
                
                [recipientsController.groupsList removeAllObjects];
                [recipientsController.groupsNamesArray removeAllObjects];
                
                [recipientsController refreshPhonebook:nil];
                
                /*
                
                NSLog(@"readed %ld contacts from core data models, but will only add %ld",(unsigned long)models.count, cleanList.count);
                
                [recipientsController.contactsList addObjectsFromArray:cleanList];
                
                [recipientsController.selectedContactsList removeAllObjects];
                [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
                
                [recipientsController refreshPhonebook:nil];
                 */
            }
            
 
        });
        
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        NSLog(@"previously granted permission");
        // The user has previously given access, add the contact
        contacts = [self loadContacts: addressBook];
        
        NSMutableArray *cleanList = [[NSMutableArray alloc] init];
        NSInteger duplicates = 0;
        //auxiliar list to check for duplicates (might slow down stuff)
        for(Contact *c in contacts) {
            c.isNative = true;
            if(![cleanList containsObject:c]) {
                [cleanList addObject:c];
            }
            else {
                duplicates++;
            }
        }
        
        [recipientsController.contactsList removeAllObjects];
        [recipientsController.contactsList addObjectsFromArray:cleanList];
        
        NSLog(@"readed %ld contacts from local address book, but will only add %ld",(unsigned long)contacts.count, cleanList.count);
        
        NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
        
        [self loadContactsFromCoreDataOnly];
        
        //load native groups, from icloud
        NSMutableArray *groupsFromICloud = [self loadGroups:addressBook];
        if(groupsFromICloud!=nil && groupsFromICloud.count > 0) {
            [recipientsController.contactsList addObjectsFromArray:groupsFromICloud];
        }
        
        //load also the groups
        NSMutableArray *groupsFromDB = [self fetchGroupRecords];
        [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.groupsList removeAllObjects];
        [recipientsController.groupsNamesArray removeAllObjects];
        
        [recipientsController refreshPhonebook:nil];
        /*
        
        NSLog(@"readed %ld contacts from core data models, but will only add %ld",(unsigned long)models.count, cleanList.count);
        
        [recipientsController.contactsList addObjectsFromArray:cleanList];
        
        NSMutableArray *groupsFromDB = [self fetchGroupRecords];
        [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
        
        [recipientsController.groupsList removeAllObjects];

        
        [recipientsController.selectedContactsList removeAllObjects];
        [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
        
        NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
        
        [recipientsController refreshPhonebook:nil];*/
        
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
        if ( ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted ) {
            // Display an error.
            [self showPermissionsMessage];
            
            //still load these anyway, no need permissions
            [self loadContactsFromCoreDataOnly];
            //load also the groups
            NSMutableArray *groupsFromDB = [self fetchGroupRecords];
            [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
            
            [recipientsController refreshPhonebook:nil];
        }
        
    }
 
    CFRelease(addressBook);
    
    
}

//get all the records from db
- (NSMutableArray*) fetchGroupRecords{
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSMutableArray *databaseRecords = [CoreDataUtils fetchGroupRecordsFromDatabase];

    for(GroupDataModel *model in databaseRecords) {
               
        //NSLog(@"Loaded group %@ which has %d contacts",model.name,model.contacts.count);
        
        Group *group = [[Group alloc] init];
        group.name = model.name;
        group.isNative = false;
        
        for(ContactDataModel *contact in model.contacts) {
            
            Contact *c = [[Contact alloc] init];
            c.name = contact.name;
            c.phone = contact.phone;
            c.email = contact.email;
            c.lastName = contact.lastname;
            
            [group.contactsList addObject:c];
            
        }
        //avoid duplicates
        if(![records containsObject:group]) {
           [records addObject:group];
        }
        

       
    }
    return records;
    
}

-(BOOL) wasAlreadyAddedToList:(NSMutableArray *)existingContacts otherName:(NSString*)name otherLastName:(NSString *) lastName otherPhone:(NSString*) phone otherEmail:(NSString*) email {
    
    NSLog(@"existing contacts size: %ld", existingContacts.count);
    BOOL exists = false;
    for(Contact *existing in existingContacts) {
        
        //NSLog(@"existing contact name: %@ lastname: %@", existing.name, existing.lastName);
        if(name!=nil && existing.name!=nil) {
            if([name isEqualToString:existing.name]) {
                //also check last name, just the name is not enough
                if(lastName!=nil && existing.lastName!=nil && [lastName isEqualToString:existing.lastName] ) {
                    NSLog(@"same contact %@ %@",name, lastName);
                    exists = true;
                    break;
                }
            }
        }
        else if(email!=nil && existing.email!=nil) {
            if([email isEqualToString:existing.email]) {
                NSLog(@"same email %@",email);
                exists = true;
                break;
            }
        }
        else if(phone!=nil && existing.phone!=nil) {
            if([phone isEqualToString:existing.phone]) {
                NSLog(@"same phone %@",phone);
                exists = true;
                break;
            }
        }
        
    }
    return exists;
}
//ContactModel from the local database, not ALAAssets
- (NSMutableArray*) fetchLocalContactModelRecords{
    
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSMutableArray *databaseRecords = [CoreDataUtils fetchContactModelRecordsFromDatabase];
    //we already added the ones from AlaAssets here
    NSMutableArray* existingContacts = recipientsController.contactsList;
    
    NSDate *today = [NSDate date];
    //today date components
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: today];
    
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate: today];
    //tomorrow date components
    NSDateComponents *componentsTomorrow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: tomorrow];
    
    NSLog(@"num of core data database contacts %ld",(unsigned long) databaseRecords.count);
        for(ContactDataModel *contact in databaseRecords) {
            
            NSString *name = contact.name;
            NSString *email = contact.email;
            NSString *phone =  contact.phone;
            NSString *lastname = contact.lastname;
            //NSDate *birthday = contact.birthday;
            
            //NSLog(@"readed model name: %@",name);
            //NSLog(@"readed model lastname: %@",lastname);
            
            BOOL exists = [self wasAlreadyAddedToList:existingContacts otherName:name otherLastName:lastname otherPhone:phone otherEmail:email];
            //NSLog(@"first pass: exists %d",exists);
            if(!exists) {
             //check also the other list
                exists = [self wasAlreadyAddedToList:records otherName:name otherLastName:lastname otherPhone:phone otherEmail:email];
                //NSLog(@"second pass: exists %d so it was already added",exists);
            }
            
            //NSLog(@"it exists is? %d",exists);
            if(!exists) {
                //avoid add repeating ones
                Contact *c = [[Contact alloc] init];
                c.name = contact.name;
                c.phone = contact.phone;
                c.email = contact.email;
                c.lastName = contact.lastname;
                c.birthday = contact.birthday;
                if(c.birthday!=nil) {
                    
                    NSDateComponents *componentsContact = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:c.birthday];
                    //we have a birthday
                    if(components.day == componentsContact.day && components.month == componentsContact.month) {
                        //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                        //so we need to clearly identify it
                        
                        [self scheduleNotification:@"birthday" nameOfContact:name month:components.month day:components.day fireDelayInSeconds:60];
                    }
                    //we have a birthday tomorrow
                    else if(componentsTomorrow.day == componentsContact.day && componentsTomorrow.month == componentsContact.month) {
                        
                        //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                        //so we need to clearly identify it
                        
                        
                        [self scheduleNotification: @"birthday" nameOfContact: name month: componentsTomorrow.month day: componentsTomorrow.day fireDelayInSeconds:(24*60*60)];
                        
                    }
                    
                }
                
                NSLog(@"adding this contact: %@",c.description);
                [records addObject:c];
            }
            
            
            
            
        }
    

    return records;
    
}


//load the groups from the address book
-(NSMutableArray *)loadGroups: (ABAddressBookRef) addressBook {
    
    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    if(groups) {
        CFIndex numGroups = CFArrayGetCount(groups);
        NSLog(@"Num groups is %ld",numGroups);
        for(CFIndex idx=0; idx<numGroups; ++idx) {
            
            ABRecordRef groupItem = CFArrayGetValueAtIndex(groups, idx);
            
            NSString *groupName = (__bridge_transfer NSString*)ABRecordCopyCompositeName(groupItem);
            //NSLog(@"Loaded icloud group named %@",groupName);
            
            //create the group object
            Group *group = [[Group alloc] init];
            group.email=@"";
            group.name = groupName;
            group.lastName = groupName;
            group.person = nil;
            
            group.isNative = true;
            
            //always add
            if(![groupsArray containsObject:group]) {
                [groupsArray addObject:group];
            }
            
            CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupItem);
            if(members) {
                NSUInteger count = CFArrayGetCount(members);
                
                for(NSUInteger idx=0; idx<count; ++idx) {
                    
                    //create the contact
                    Contact *c = [[Contact alloc] init];
                    
                    ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                    //get the name
                    NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                    //no name? get the composite one
                    if(name == nil) {
                        name = (__bridge NSString*)ABRecordCopyCompositeName(person);
                    }
                    NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                    
                    if(name!=nil) {
                        c.name = name;
                    }
                    if(lastName!=nil) {
                        c.lastName = lastName;
                    }
                    
                    //load phone and email
                    NSString *phone;
                    ABMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    int countPhones = ABMultiValueGetCount(phoneMulti);
                    if(countPhones>0) {
                        phone = [self getPreferredPhone: phoneMulti forLabel:kABPersonPhoneMobileLabel count: countPhones];
                        if(phone!=nil) {
                            c.phone = phone;
                        }
                    }
                    //get email
                    NSString *email;
                    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
                    int count = ABMultiValueGetCount(multi);
                    //do we have more than 1?
                    if(count > 0) {
                        email = [self getPreferredEmail: multi forLabel:kABHomeLabel count: count];
                        if(email!=nil) {
                            c.email = email;
                        }
                    }
                    
                    //check for blanks (only phone number for instance, no name
                    if(c.name == nil || [[c.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                        c.name = (phone!= nil ? phone : email);
                    }
                    
                    //NSLog(@"added person  %@ to the icloud group %@",name, groupName);
                    [group.contactsList addObject:c];
                    
                }// end for
                CFRelease(members);
            }// end if members
            
        }//end for
    }
    
    
    return groupsArray;
}

//Load the contacts list from the address book
-(NSMutableArray *)loadContacts : (ABAddressBookRef) addressBook {
    
    NSLog(@"START IMPORT");
    
    //get current date
    
    NSDate * today = [NSDate date];
    
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate: today];
    
    //today date components
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    //tomorrow date components
    NSDateComponents *componentsTomorrow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: tomorrow];
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    NSMutableArray *nameOfContacts; //for birthday reminder
    
    //need to have permission first, otherwise it can crash
    if(ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
    
       //*****
        //CFRetain(addressBook);
        NSArray *arrayOfPeople = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        for(int i = 0; i < arrayOfPeople.count; i++) {
            
            Contact *contact = [[Contact alloc] init];
            ABRecordRef person = (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:i];
            
            //get the first name
            
            NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            if(name == nil) {
                name = (__bridge NSString*)ABRecordCopyCompositeName(person);
            }
            //NSString *name = (__bridge NSString*)ABRecordCopyCompositeName(person);
            NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            NSDate *data = (__bridge NSDate *)ABRecordCopyValue(person, kABPersonBirthdayProperty);
            if(data!=nil) {
                //NSDateFormatter *f = [[NSDateFormatter alloc]init];
                //[f setDateFormat:@"MMMM dd,yyyy"]
                contact.birthday = data;
                
                NSDateComponents *componentsContact = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:data];
                //we have a birthday today
                if(components.day == componentsContact.day && components.month == componentsContact.month) {
                    //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                    //so we need to clearly identify it
                    
                    
                    [self scheduleNotification: @"birthday" nameOfContact: name month: components.month day: components.day fireDelayInSeconds:60];
                    
                }
                //we have a birthday tomorrow
                else if(componentsTomorrow.day == componentsContact.day && componentsTomorrow.month == componentsContact.month) {
                    
                    //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                    //so we need to clearly identify it
                    
                    
                    [self scheduleNotification: @"birthday" nameOfContact: name month: componentsTomorrow.month day: componentsTomorrow.day fireDelayInSeconds:(24*60*60)];
                    
                }
                
            }
            //save the reference
            contact.person=person;
            contact.isNative = true;
            
            NSString *email;
            
            //NSString *theName = (__bridge NSString*)ABRecordCopyCompositeName(person);
            
            
            ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
            
#pragma GET EMAIL ADDRESS
            
            
            int count = ABMultiValueGetCount(multi);
            
            //do we have more than 1?
            if(count > 0) {
                email = [self getPreferredEmail: multi forLabel:kABHomeLabel count: count];
            }
            //else, we don´t have email
            
            //add it if we have it
            if(email!=nil) {
                contact.email = email;
            }
            
            
#pragma GET PHONE NUMBER
            
            NSString *phone;
            
            ABMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
            int countPhones = ABMultiValueGetCount(phoneMulti);
            
            if(countPhones>0) {
                phone = [self getPreferredPhone: phoneMulti forLabel:kABPersonPhoneMobileLabel count: countPhones];
                
            }
            
            //NSLog(@"READED %@", name);
            //NSLog(@"ANDREIA PHONE %@  count: %d", phone, countPhones);
            
            
            //add the phone number
            if(phone!=nil) {
                contact.phone = phone;
            }
            
            
            //i must have some sort of contact info
            if(phone!=nil || email!=nil) {
                
                if(name!=nil) {
                    contact.name = name;
                }
                if(lastName!=nil) {
                    contact.lastName = lastName;
                }
                
                //check for blanks (only phone number for instance, no name
                if(contact.name == nil || [[contact.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                    contact.name = (phone!= nil ? phone : email);
                }
                
                //try to get the photo if available
                @try {
                    NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
                    if(imgData!=nil) {
                        UIImage  *img = [UIImage imageWithData:imgData];
                        contact.photo = img;
                    }
                    //else {
                    //    UIImage  *img = [UIImage imageNamed:@"user"];
                    //    contact.photo = img;
                    //}
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"Unable to get contact photo, %@",[exception description]);
                }
                @finally {
                    ;
                }
                
                [contacts addObject:contact];
                
            }
            
            
        }//end for loop

       //****
    //CFRelease(addressBook);
    }
    
    NSLog(@"DONE IMPORT");
    
    
   return contacts;
    
    
}

//get the preferred email address to use
-(NSString *) getPreferredEmail: (ABMultiValueRef) properties forLabel:(CFStringRef) labelConst count: (NSInteger) size {
    for (int k=0;k<size; k++)
    {
        NSString *mail = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        CFStringRef labelValue  =  ABMultiValueCopyLabelAtIndex(properties, k);
        
        //NSLog(@"mail address: %@ with label %@: ",mail, labelValue);
        if (labelValue && CFStringCompare(labelValue, labelConst, 0) == 0) {
            //NSLog(@"found preferred email label %@  whose value is %@",labelConst,mail);
            return mail;
        }
        
    }
    return [self grabFirstEmailAddressInList:properties];
    
}

//just grab the first email address
-(NSString *) grabFirstEmailAddressInList:(ABMultiValueRef) properties {
    //if still here just grab the first one
    NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(properties, 0);
    return email;
}

//get the preferred phone number to use
-(NSString *) getPreferredPhone: (ABMultiValueRef) properties forLabel:(CFStringRef) labelConst count: (NSInteger) size {
    for (int k=0;k<size; k++)
    {
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        CFStringRef labelValue  =  ABMultiValueCopyLabelAtIndex(properties, k);
        
        //NSLog(@"phone number: %@ with label %@: ",phone, labelValue);
        if (labelValue && CFStringCompare(labelValue, labelConst, 0) == 0) {
           // NSLog(@"found preferred phone label %@ whose value is %@",labelConst,phone);
            return phone;
        }
        
    }
    return [self grabFirstPhoneNumberInList:properties];
}

//just grab the first phone number
-(NSString *) grabFirstPhoneNumberInList:(ABMultiValueRef) properties {
    //if still here just grab the first one
    NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(properties, 0);
    return phone;
}



- (IBAction)showSettings:(id)sender {
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (IBAction)sendEmail:(id)sender {
    // Email Subject
    NSString *emailTitle = subject.text;
    // Email Content
    NSString *messageBody = body.text;
    // To address
    NSMutableArray *toRecipents = [self getEmailAdresses];
    

    
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
            
            //i do have recipients for the email but i cannot send it due to settings
            if(settingsController.selectSendOption != OPTION_ALWAYS_SEND_BOTH_ID) {
                
                if(sendToFacebook || sendToTwitter || sendToLinkedin) {
                    
                    [self sendToSocialNetworks: body.text];
                }
                //TODO message saying that will port to social media only??
                
            } else {
                //send both is selected and i did not sent any email due to settings
                [self sendSMS:nil];
            }
            
            
        } else {
            //send the email normally
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setBccRecipients:toRecipents];
            
            //Get all the image info
            if(self.attachments.count > 0) {
                
                for(int i = 0; i < self.attachments.count; i++) {
                    //"image/jpeg" png
                    NSArray *data = [self.attachments objectAtIndex:i];
                    UIImage *img = [data objectAtIndex:0]; //[self.attachments objectAtIndex:i];
                    self.imageName = [data objectAtIndex:1];
                    NSData *imageData =  [self getImageInfoData: img];
                    BOOL isPNG = [self isImagePNG];
                    NSString *name = [NSString stringWithFormat:@"pic_%d.%@",i,isPNG ? @"png" : @"jpg"];
                    [mc addAttachmentData:imageData mimeType: isPNG ? @"image/png" : @"image/jpeg" fileName:name];//imageName
                }
            }
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:NULL];
        }
        
        
        
    } else {
        //no recipients for the email
        if(settingsController.selectSendOption != OPTION_ALWAYS_SEND_BOTH_ID) {
            
            //means is OPTION_SEND_EMAIL_ONLY_ID
            //it means it´s selected only email... and we don´t have email adresses and we´re not sending SMS next either
            
            //but if we have social networks, we don´t care and will post to those only
            if(sendToFacebook || sendToTwitter || sendToLinkedin) {
                
                [self sendToSocialNetworks: body.text];
            }
            else {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_email_title",@"EasyMessage: Send email")
                                                                message:NSLocalizedString(@"recipients_least_one_recipient", @"select valid recipient")
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                
                [alert show];
            }
        } else {
                //send both is selected and i did not sent any email
            [self sendSMS:nil];
        }
    }
    
    
    //#BUGFIX this way was sending SMS 2 times! here and on checkIfSendBoth
    //else {
    //    [self sendSMS:nil];
    //}
    
    
    
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
            emailSentOK = YES;
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
    [self dismissViewControllerAnimated:YES completion:^{[self checkIfSendBoth];}];
    
    
}
//This is called after send email , if option is send both, send the SMS
-(void) checkIfSendBoth {
    //#define OPTION_ALWAYS_SEND_BOTH_ID      0
    //#define OPTION_SEND_EMAIL_ONLY_ID       1
    //#define OPTION_SEND_SMS_ONLY_ID         2
    
    if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID ) {//OPTION_ALWAYS_SEND_BOTH
        [self sendSMS:nil];
    }
    else {
        //not sending to social media, ask for review?
        if(!sendToTwitter && !sendToFacebook && !sendToLinkedin) {
            [self checkIfAskForReview];
            [self clearFieldsAndRecipients];
        }
        else {
            [self doSocialNetworksIfSelected];
        }

    }
}

//this is called only from sms or email
-(void) doSocialNetworksIfSelected{
    
    if(sendToFacebook || sendToTwitter || sendToLinkedin) {
        [self sendToSocialNetworks: body.text];
  
    }
    else {
        
       //should ask for review?
       [self checkIfAskForReview];
       [self clearFieldsAndRecipients];
    }
    
}

-(void)updateAttachmentsLabel {
    if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
        labelAttachCount.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)attachments.count, MAX_ATTACHMENTS];
    }
    else {
        labelAttachCount.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)attachments.count, MAX_ATTACHMENTS_WITHOUT_PREMIUM];
    }
   
}

//delegate for the sms controller
#pragma sms delegate
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
            smsSentOK = YES;
			break;
		default:
			break;
	}
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
	[self dismissViewControllerAnimated:YES completion:^{[self doSocialNetworksIfSelected];}];
}

//will send the message to facebook
- (void)sendToFacebook:(NSString *)message {
    //TODO show a toast saying that we copied the content to clipboard
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/app/id1448046358?mt=8"];
    content.quote = message;
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:message];
    
    [[[[iToast makeText:@"message copied to clipboard"]
       setGravity:iToastGravityBottom] setDuration:1000] show];
    
    //if(image!=nil && imageName!=nil) {
    //}
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
}

//reset the booleans after sending the message
-(void) resetSocialNetworks: (BOOL) clear {
    
    if(clear) {
        sendToFacebook = NO;
        sendToTwitter = NO;
        sendToLinkedin = NO;
        [settingsController resetSocialNetworks];
        
        if(body.text.length > 0) {
            //we still haven´t cleared
            [self clearFieldsAndRecipients];
        }
        
    }

    
    
    //NSLog(@"resetting....");
}

//send the message also to twitter (facebook is always first if available)
- (void)sendToTwitter:(NSString *)message {
    
    // Objective-C
    
    // Check if current session has users logged in
    if ([[Twitter sharedInstance].sessionStore hasLoggedInUsers]) {
        [self doTwitterShare:message];
    } else {
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                [self doTwitterShare:message];
            } else {
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Twitter Accounts Available" message:@"You must log in before presenting a composer." preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

-(void) doTwitterShare:(NSString *) message {
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    
    [composer setText:message];
    [composer setImage:[UIImage imageNamed:@"icon-76"]];
    [composer setURL: [NSURL URLWithString: @"https://itunes.apple.com/app/id1448046358?mt=8"]];
    
    // Called from a UIViewController
    [composer showFromViewController:self completion:^(TWTRComposerResult result) {
        
        if(self.presentedViewController!=nil) {
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        }
        NSString *msg;
        BOOL clear = YES;
        
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
            msg = NSLocalizedString(@"twitter_post_canceled", @"twitter_post_canceled");
            clear = NO;
        }
        else {
            NSLog(@"Sending Tweet!");
            msg = NSLocalizedString(@"twitter_post_ok", @"twitter_post_ok");
        }
        
        if(msg!=nil) {
            [[[[iToast makeText:msg]
               setGravity:iToastGravityBottom] setDuration:1000] show];
        }
        
        //check if send to linkedin
        if(sendToLinkedin) {
            
            //before send check if we need authorization
            [self authorizeAndSendToLinkedin:message];
            
        }
        else {
            [self resetSocialNetworks:clear];
        }
    }];
}

//post to linkedin
-(void) sendToLinkedin: (NSString* ) message withToken: (NSString*) token {
    
        
        //https://developer.linkedin.com/docs/share-on-linkedin
        
        NSMutableString *str = [[NSMutableString alloc] init];
        
        [str appendString:@"https://api.linkedin.com/v1/people/~/shares?oauth2_access_token="];
        [str appendString: token];
        NSString *postURL = [NSString stringWithString:str];
        
        //get the status message
        NSString *title = (subject.text!=nil && subject.text.length>0) ? subject.text : message;

    
        NSMutableString *thePost = [[NSMutableString alloc] init];
        [thePost appendString:@"<share>"];
        [thePost appendString: [NSString stringWithFormat: @"<comment>%@</comment>",message] ];
        [thePost appendString:@"<content>"];
        [thePost appendString: [NSString stringWithFormat: @"<title>%@</title>",title] ];
        [thePost appendString: [NSString stringWithFormat: @"<description>%@</description>",message] ];
        [thePost appendString:@"<submitted-url>https://itunes.apple.com/app/id1448046358?mt=8</submitted-url>"];
        [thePost appendString:@"<submitted-image-url>https://is1-ssl.mzstatic.com/image/thumb/Purple/v4/ff/f7/ce/fff7ce0f-933f-6448-46d1-5945fef9783e/Icon-76@2x.png.png/75x9999bb.png</submitted-image-url>"];
        [thePost appendString:@"</content>"];
        [thePost appendString:@"<visibility>"];
        [thePost appendString:@"<code>anyone</code>"];
        [thePost appendString:@"</visibility>"];
        [thePost appendString:@"</share>"];
        
        
        // Create the request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
        // Specify that it will be a POST request
        [request setHTTPMethod: @"POST"];
        //with xml body
        [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        NSData *requestBodyData = [thePost dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestBodyData];
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
        /**
         <?xml version="1.0" encoding="UTF-8"?>
         <share>
         <comment>Check out the LinkedIn Share API!</comment>
         <content>
         <title>LinkedIn Developers Documentation On Using the Share API</title>
         <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
         <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
         <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
         </content>
         <visibility>
         <code>anyone</code>
         </visibility>
         </share>
         */

    
}

//if the message mentions EasyMessage then is a regular share
-(BOOL) isEasyMessageShare: (NSString *) message {
    return [message rangeOfString:@"EasyMessage"].location !=NSNotFound ;
}

-(IBAction)sendSMS:(id)sender {
    
 MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
 if([MFMessageComposeViewController canSendText]) {
    
    NSMutableArray *recipients = [self getPhoneNumbers];

    if(recipients.count>0) {
        
        controller.body = body.text;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        
        if(self.attachments.count > 0) {
            if( IS_OS_7_OR_LATER && [MFMessageComposeViewController canSendAttachments]) {
                
                for(int i = 0; i < self.attachments.count; i++) {
                    //"image/jpeg" png
                    NSArray *data = [self.attachments objectAtIndex:i];
                    UIImage *img = [data objectAtIndex:0]; //[self.attachments objectAtIndex:i];
                    self.imageName = [data objectAtIndex:1];
                    NSData *imageData = [self getImageInfoData: img];
                    BOOL isPNG = [self isImagePNG];
                    NSString *name = [NSString stringWithFormat:@"pic_%d.%@",i,isPNG ? @"png" : @"jpg"];
                    [controller addAttachmentData:imageData typeIdentifier:isPNG ? @"image/png" : @"image/jpeg" filename:name];
                    //[controller addAttachmentData:imageData typeIdentifier:isPNG ? @"image/png" : @"image/jpeg" fileName:name];//imageName
                }
                
                
                //NSData *imageData = [self getImageInfoData: ];
                //BOOL isPNG = [self isImagePNG];
                //[controller addAttachmentData:imageData typeIdentifier:isPNG ? @"image/png" : @"image/jpeg" filename:imageName];
            }
        }
        
        
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        //means we have no available phones
        //since we´re not sending SMS, social networks will not be on that dismiss, so we need to check if send it now
      
        if(sendToTwitter || sendToFacebook || sendToLinkedin) {
            [self sendToSocialNetworks: body.text];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"easymessage_send_sms_title", @"EasyMessage: Send SMS")
                                                            message: NSLocalizedString(@"recipients_least_one_recipient",@"recipient not valid")
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
 }
 else {
   
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"easymessage_send_sms_title", @"EasyMessage: Send SMS")
                                                    message:NSLocalizedString(@"no_sms_device_settings",@"can´ send sms")
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
 }
    
    
}

//clear stuff, this is called after sending sms or email
-(void)clearFieldsAndRecipients {
    
    
    //NSLog(@"clearing stuff...");
    
    recipientsLabel.text = @"";
    
    [selectedRecipientsList removeAllObjects];
    [recipientsController.selectedContactsList removeAllObjects];
    [self updateAddRemoveRecipients];
    [recipientsController.tableView reloadData];
    
    
    if(saveMessage) {
        //TODO SAVE THE MESSAGE
        [self saveMessageInArchive];
    }
    
    [self clearInputFields];
    
    //the default action on beginning is also NOT save
    saveMessage = NO;
    [saveMessageSwitch setOn:NO];
    
    customMessagesController.selectedMessageIndex=-1;
    customMessagesController.selectedMessage = nil;
    
    //update button UI
    image = nil;
    imageName = nil;
    
    [self updateAttachButton];
    
    
    
}
-(void) clearInputFields{
    subject.text = @"";
    body.text = @"";
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

//save the message in archive, core data
-(void)saveMessageInArchive {
    
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    
    NSString *msg = body.text;
    //get all the records and see if we have already this one
    //MessageDataModel
    NSMutableArray *allRecords = [CoreDataUtils fetchMessageRecordsFromDatabase];
    
    //Message
    NSMutableArray *fromList = [[NSMutableArray alloc] init];
    [fromList addObjectsFromArray:customMessagesController.messagesList];
    
    //TODO this should be more efficient but anyway
    
    BOOL exists = NO;
    for(MessageDataModel *model in allRecords) {
        if([model.msg isEqualToString:msg]) {
            exists=YES;
            break;
        }
    }
    //only check the other one if not exists
    if(!exists) {
        //now the other one
        for(Message *message in fromList) {
            if([message.msg isEqualToString:msg]) {
                exists=YES;
                break;
            }
        }
    }
    
    
    if(!exists) {
        MessageDataModel *message = (MessageDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"MessageDataModel" inManagedObjectContext:managedObjectContext];
        message.msg = body.text;
        message.isDefault = @NO;
        message.creationDate = [NSDate date];
        
        //BOOL OK = NO;
        NSError *error;
        if(![managedObjectContext save:&error]){
            NSLog(@"Unable to save object, error is: %@",error.description);
        } else {
            [customMessagesController addRecordsFromDatabase];
        }
    }
    
    //else {
    //    OK = YES;
    //    [[[[iToast makeText:NSLocalizedString(@"group_created",@"group_created")]
    //       setGravity:iToastGravityBottom] setDuration:2000] show];
    //}
    
    
}

//get all emails
-(NSMutableArray *) getEmailAdresses {
    
    NSMutableArray *emails = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
        if([c isKindOfClass:Group.class]) {
            
            Group *group = (Group *)c;
            for(Contact *other in group.contactsList) {
                NSString *emailAddress = other.email; // [self extractEmailAddress:other];
                if(emailAddress!=nil && ![emails containsObject:emailAddress]) {
                    [emails addObject:emailAddress];
                }
            }  
         }
        else {
            NSString *emailAddress = c.email;// [self extractEmailAddress:c];
            NSLog(@"email address is: %@ for contact %@ ",emailAddress, c.description);
            if(emailAddress!=nil && ![emails containsObject:emailAddress]) {
                [emails addObject:emailAddress];
            }
        }
        
    }
    return emails;
}
//deprecated
-(NSString *) extractEmailAddress: (Contact *)c {
    
    
    
    //first check is see if we have an email address
    if(c.email!=nil) {
        
        //if there is a preference other than ALL??
        if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
            
            if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID) {
                //the preferred method is SMS
                if(c.phone!=nil) {
                    
                    //OK, we have an SMS, but are we sending SMS?
                    if(settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                        //we are just sending email, so we need to include it anyway
                        //NSLog(@"We prefere to use SMS service but we´re sending just email so %@ will be added to the addresses list",c.email);
                        return c.email;
                    }
                    //else {//means we are sending either BOTH or just SMS
                    //so we skip it, cause it will inlcuded in the SMS check
                    //}
                    
                }
                else {
                    //contact does not have phone number, so MUST be reached by email, even if not preferered
                    //NSLog(@"We prefere to use SMS service but we don´t have a phone number, just email, so %@ will be added to the addresses list",c.email);
                    return c.email;
                }
                
            }
            else {
                //preference is email, so it´s ok to add it
                //NSLog(@"We prefere to use email service and for that reason %@ will be added to the addresses list",c.email);
                return c.email;
            }
            
        }
        else {
            //option is OPTION_PREF_SERVICE_ALL_ID , so it´s ok to add it
            //NSLog(@"We prefere to use both services, so %@ will be added to the addresses list",c.email);
            return c.email;
        }
    }
    
    return nil;
}

//get all phones
-(NSMutableArray *) getPhoneNumbers {
    
    NSMutableArray *phones = [[NSMutableArray alloc] init];
    for(Contact *c in selectedRecipientsList) {
        
        if([c isKindOfClass:Group.class]) {
            
            Group *group = (Group *)c;
            for(Contact *other in group.contactsList) {
                NSString *phoneNumber = other.phone;// [self extractPhoneNumber:other];
                if(phoneNumber!=nil && ![phones containsObject:phoneNumber]) {
                    [phones addObject:phoneNumber];
                }
            }
        }
        else {
            //NSLog(@"CONTACT IS %@", c.description);
            NSString *phoneNumber = c.phone;//[self extractPhoneNumber:c];
            if(phoneNumber!=nil && ![phones containsObject:phoneNumber]) {
                //NSLog(@"adding phone number %@",phoneNumber);
                [phones addObject:phoneNumber];
            }
        }
    }
    
    return phones;
}

-(NSString *) extractPhoneNumber: (Contact *)c {
    
    if(c.phone!=nil) { //first thing we need is a phone number, otherwise we don´t even consider it
        
        //if there is a preference other than ALL??
        if(settingsController.selectPreferredService!= OPTION_PREF_SERVICE_ALL_ID) {
            
            if(settingsController.selectPreferredService == OPTION_PREF_SERVICE_EMAIL_ID) {
                //if the prefereed service is email, and this one has it, we skip it
                if(c.email!=nil) {
                    //ok the contact has email, and this is the preferred service
                    //but did we send the email already??
                    if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                        //we have choosed just to send SMS, so definetely it was not reached by email before
                        //therefore, we need to add it
                        //NSLog(@"We want to send just SMS, so %@ will be added to the phones list",c.phone);
                        //[phones addObject:c.phone];
                        return c.phone;
                        
                    }
                    else if(emailSentOK==NO) {//means it was EMAIL AND SMS, OR JUST EMAIL, but failed
                        //NSLog(@"We wanted to send just email or both, but the email delivery has failed, so %@ will be added to the phones list",c.phone);
                        //[phones addObject:c.phone];
                        return c.phone;
                        
                    }
                    //else {
                    //do nothing, cause the email was already sent for sure, and with success
                    //skip it
                    //}
                }
                else {
                    //the contact does not have email, so it MUST be reached by SMS, despite the preference
                    //NSLog(@"We prefere to use email service, but we don´t have and address so %@ will be added to the phones list",c.phone);
                    //[phones addObject:c.phone];
                    return c.phone;
                }
                
            }
            else {//means settingsController.selectPreferredService == OPTION_PREF_SERVICE_SMS_ID
                //if the prefereed service is SMS, we can add it
                //NSLog(@"We prefere to use SMS service, so %@ will be added to the phones list",c.phone);
                //[phones addObject:c.phone];
                return c.phone;
            }
            
        }
        else {
            //preference is send both, so it´s ok to add it
            //NSLog(@"We prefere to use both services, so %@ will be added to the phones list",c.phone);
            //[phones addObject:c.phone];
            return c.phone;
        }
        
    
  }//end if phone!=nil

 return nil;
}

//Callback to detect adressbook changes
//this sometimes get called multiple times, so we just log and do not show the alert message
//update we use a timer, to call after it ends only
void addressBookChanged(ABAddressBookRef reference,
                        CFDictionaryRef dictionary,
                        void *context)
{
    ABAddressBookRegisterExternalChangeCallback(reference,dictionary,context);
    
    PCViewController *_self = (__bridge PCViewController *)context;
    
    if(_self !=nil) {
    
        if(_self.changeTimer!=nil) {
            [_self.changeTimer invalidate];
        }
      _self.changeTimer = nil;
      _self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                        target:_self
                                                      selector:@selector(handleAdressBookExternalCallbackBackground)
                                                      userInfo:nil
                                                      repeats:NO];
    }
}


//this will be called when the timer ends, after an address book changed notification
-(void) handleAdressBookExternalCallbackBackground {
    
        
        [self showAlertBox: NSLocalizedString(@"address_book_changed_msg",@"address has changed")];
        //NSLog(@"address book has changed");
        [self.selectedRecipientsList removeAllObjects];
        [self loadContactsList:nil];
        //refresh is already done inside loadContactsList
        //[_self.recipientsController refreshPhonebook:nil];
        
    
}

/**
 MMS
 MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
 
 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
 pasteboard.persistent = YES;
 pasteboard.image = [UIImage imageNamed:@"PDF_File.png"];
 
 NSString *phoneToCall = @"sms:";
 NSString *phoneToCallEncoded = [phoneToCalll stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
 NSURL *url = [[NSURL alloc] initWithString:phoneToCallEncoded];
 [[UIApplication sharedApplication] openURL:url];
 
 if([MFMessageComposeViewController canSendText]) {
 NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"Your Email Body"];
 picker.messageComposeDelegate = self;
 picker.recipients = [NSArray arrayWithObject:@"123456789"];
 [picker setBody:emailBody];// your recipient number or self for testing
 picker.body = emailBody;
 NSLog(@"Picker -- %@",picker.body);
 [self presentModalViewController:picker animated:YES];
 NSLog(@"SMS fired");
 }
 */


#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"Selected assets:");
    NSLog(@"%@", assets);
    
    /**
     let asset : PHAsset = self.selectedAssets[0].phAsset! as PHAsset
     PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width : 400, height : 400), contentMode: .aspectFit, options: options, resultHandler: {(result: UIImage!, info) in
     if let image = result
     {
     let imageData: NSData = UIImageJPEGRepresentation(image, 1.0)! as NSData
     mail.addAttachmentData(imageData as Data, mimeType: "image/jpg", fileName: "BeforePhoto.jpg")
     }
     })
     */
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.networkAccessAllowed = true;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    // this one is key
    requestOptions.synchronous = YES;
    
    self.imagesArray = [NSMutableArray arrayWithArray:assets];
    PHImageManager *manager = [PHImageManager defaultManager];
    //NSMutableArray *images = [NSMutableArray arrayWithCapacity:[assets count]];
    
    NSUInteger maxAttach = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE] ? MAX_ATTACHMENTS : MAX_ATTACHMENTS_WITHOUT_PREMIUM;
    
    //already have the max 5, need to remove the extra ones
    if(self.attachments.count >= maxAttach) {
        //already have 5 remove all and replace them by the new ones
        if(self.imagesArray.count == maxAttach) {
            [self.attachments removeAllObjects];
            [self.imagesCollection reloadData];
            [self updateAttachmentsLabel];
        }
        else {
            NSInteger toRemove = self.imagesArray.count;
            for(int i = 0; i < toRemove; i++ ) {
                [self.attachments removeObjectAtIndex:i];
            }
            [self.imagesCollection reloadData];
            [self updateAttachmentsLabel];
            
        }
        
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        for (PHAsset *asset in self.imagesArray) {
            // Do something with the asset
            
            [manager requestImageForAsset:asset
                               targetSize:PHImageManagerMaximumSize
                              contentMode:PHImageContentModeDefault
                                  options:requestOptions
                            resultHandler:^void(UIImage *image, NSDictionary *info) {
                                if(image!=nil) {
                                    //PHImageFileURLKey could be nil if the key is not present, so we add dummy string instead
                                    NSURL *url = [info objectForKey: @"PHImageFileURLKey"];
                                    if(url==nil) {
                                        url = [NSURL URLWithString:@"file:///var/mobile/media/dcim/100apple/pic.png"];
                                    }
                                    NSArray *data = [[NSArray alloc] initWithObjects:image, url.absoluteString, nil];
                                    [self.attachments addObject:data];
                                }
                                
                            }];
            
            
        }
        [self.imagesCollection reloadData];
        [self updateAttachmentsLabel];
    });
    
    
    
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void) updateAddRemoveRecipients {
   //[addRemoveRecipientsView setHidden:true];
   if(self.selectedRecipientsList.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            addRemoveRecipientsView.image = self.removeImage;
        });
   } else {
        dispatch_async(dispatch_get_main_queue(), ^(){
             recipientsLabel.text = NSLocalizedString(@"no_recipients",@"no_recipients");
             addRemoveRecipientsView.image = self.addImage;
        });
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSLog(@"Canceled.");
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)presentMediaPicker:(id)sender {
    
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage; //only images for now
    imagePickerController.allowsMultipleSelection = YES;
    
    NSUInteger maxAttach = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE] ? MAX_ATTACHMENTS : MAX_ATTACHMENTS_WITHOUT_PREMIUM;
    //max i can add - the ones i already added
    imagePickerController.maximumNumberOfSelection = maxAttach - self.attachments.count;
    
    imagePickerController.showsNumberOfSelectedAssets = YES;
   
    [self presentViewController:imagePickerController animated:YES completion:NULL];
    //OLD IMPL
    //if i have something the idea is clear
    /*if(image==nil && imageName==nil) {
        
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:nil];
        
        
        
    }
    else {
        
        NSString *msg = [NSString stringWithFormat:@"%@ %@!",NSLocalizedString(@"removed",@"removed"),imageName];
        
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:3000] show];
        
        imageName = nil;
        image = nil;
        [self updateAttachButton];
        
    }*/
    
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    
    imageName = [imagePath lastPathComponent];
    NSString *msg = [NSString stringWithFormat:@"%@ %@!",NSLocalizedString(@"added",@"added"),imageName];

    
    [[[[iToast makeText:msg]
       setGravity:iToastGravityBottom] setDuration:3000] show];
    
    
    //update image...
    [self updateAttachButton];
    
}


#pragma rotation stuff
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
 
        //adjust the banner view to the current orientation
        //if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        //    self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        //else
        //    self.adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                     animations:^(void) {
                         //if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                         //    self.scrollView.alpha = 0.0f;
                         //} else {
                             self.scrollView.alpha = 1.0f;
                             
                         //}
                     }];
}

- (IBAction)switchSaveMessageValueChanged:(id)sender {
    saveMessage = saveMessageSwitch.on ? YES : NO;
    if(saveMessage == YES) {
        
        if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
            [[[[iToast makeText:NSLocalizedString(@"save_archive_explain", @"save_archive_explain")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
        }
        else {
            //[self showAlertBox:NSLocalizedString(@"premium_feature_only", nil)];
            [self showUpgradeToPremiumMessage];
            [saveMessageSwitch setOn:false];
            saveMessage = saveMessageSwitch.on ? YES : NO;
        }
        
        
    }
}


//Get data
- (NSData *) getImageInfoData: (UIImage *)img {
    
    NSData *imageData = nil;
    // TODO
    if ([self isImagePNG]) {
        imageData = UIImagePNGRepresentation(img);
    }
    else {
        imageData = UIImageJPEGRepresentation(img, 0.7); // 0.7 is JPG quality
    }

    return imageData;
    
}

//check is is PNG
-(BOOL) isImagePNG {
    bool isPNG = true;
    if ([imageName.lowercaseString rangeOfString:@".png"].location != NSNotFound) {
        return isPNG;
    }
    else if([imageName.lowercaseString rangeOfString:@".jpg"].location != NSNotFound
            || [imageName.lowercaseString rangeOfString:@".jpeg"].location != NSNotFound) {
        isPNG = false;
    }
    else {
        isPNG = true;
    }
    return isPNG;
}

-(IBAction)shareClicked:(id)sender {
    //to get any selected ones
    [self checkIfPostToSocial];
    
    imageName = @"icon-76";
    image = [UIImage imageNamed:@"icon-76"];
    [self updateAttachButton];
    
    NSString *shareMessage = @"Checkout EasyMessage: SMS,Email & Social in one!";
    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:shareMessage];
    
    [[[[iToast makeText:NSLocalizedString(@"message_copied_clipboard", @"")]
       setGravity:iToastGravityBottom] setDuration:1000] show];
    
    if(!sendToLinkedin && !sendToTwitter && !sendToFacebook) {
        
        
        //send at least to twitter
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
           [self sendToTwitter:shareMessage];
        }
        else if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {

            [self sendToFacebook:shareMessage];
        }
        else {
          [self authorizeAndSendToLinkedin:shareMessage];
        }
        
        
    }
    else {
        [self sendToSocialNetworks:@"Checkout EasyMessage: SMS,Email & Social in one!"];
    }
    
}

-(IBAction)showPopupView:(id)sender {
    
    
    popupView = [[PCPopupViewController alloc] initWithNibName:@"PCPopupViewController" bundle:nil];
    popupView.view.alpha=0.9;
    
    [self setupPromoViewTouch];
    
    [self.view addSubview:popupView.view];
    
    
}

-(IBAction)hideStoreView:(id)sender {
    [storeController dismissViewControllerAnimated:YES completion:nil];
}

//updates the button title
-(void) updateAttachButton {
    if(image==nil && imageName==nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            attachImageView.image = attachImage;
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            attachImageView.image = image;
        });
    }
}


//to connect with linkedin when no token is available
- (void)connectWithLinkedIn:(NSString *) message {
    [self.client getAuthorizationCode:^(NSString *code) {
        [self.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            
            //[self requestMeWithToken:accessToken];
            
            [self sendToLinkedin:message withToken:accessToken];
            
        }                   failure:^(NSError *error) {
            
            
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}

//get personal info from linkedin
- (void)requestMeWithToken:(NSString *)accessToken {

    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        NSLog(@"current user %@", result);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.pcdreams-software.com/"
                                                                                    clientId:@"77un3d1vtdhswr"
                                                                                clientSecret:@"HiZlQkFkdvbxVfMh"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_basicprofile",@"w_share"]]; //@"w_messages"
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

- (NSString *)accessToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
    return token;
    
}

//check if the token is valid
- (BOOL)validToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([[NSDate date] timeIntervalSince1970] >= ([userDefaults doubleForKey:LINKEDIN_CREATION_KEY] + [userDefaults doubleForKey:LINKEDIN_EXPIRATION_KEY])) {
        return NO;
    }
    else {
        return YES;
    }
}

/**
 
 Company:
 
 PC Dreams Software
 
 Application Name:
 
 EasyMessage
 
 API Key:
 
 77l4jha5fww7gl
 
 Secret Key:
 
 tJYyGefrcnz7FAyg
 
 OAuth User Token:
 
 6896ca8e-6e39-4109-8fe9-64691dcdb5c8
 
 OAuth User Secret:
 
 49df1d5b-c2ae-49f9-8179-20678dc36f69
 
 
-(void) doLinkedin {
 //Member Permission Scopes
 NSArray *permissions = @[@"r_network",@"r_fullprofile",@"rw_nus"];
 
 // Set up the request
 NSDictionary *options = @{ACLinkedInAppIdKey : @"API Key",ACLinkedInPermissionsKey: permissions};
 
 ACAccountStore *store = [[ACAccountStore alloc] init];
 ACAccountType *linkedInAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierLinkedIn];
 
 // Request access to LinkedIn account on device
 [store requestAccessToAccountsWithType:linkedInAccountType options:options completion:^(BOOL granted, NSError *error) {
 
 if(granted) {
     SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeLinkedIn
                                             requestMethod:SLRequestMethodGET
                                                       URL:[NSURL URLWithString:@"https://api.linkedin.com/v1/people/~"]
                                                    parameters:@{@"format" : @"json"}];
 
        request.account = store.accounts.lastObject;
 
        [request performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse,
                                             NSError *error) {
     
                if (responseData) {
 
                        //Handle Response
                }
     
 }];
 
 
 {"expires_in":5184000,"access_token":"AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR"}
 The value of parameter expires_in is the number of seconds from now that this access_token will expire in (5184000 seconds is 60 days). 
 Please ensure to keep the user access tokens secure, as agreed upon in our APIs Terms of Use.https://api.linkedin.com/v1/people/~?oauth2_access_token=AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR
 
 Step 4. Make the API calls
 You can now use this access_token to make API calls on behalf of this user by appending "oauth2_access_token=access_token" at the end of the API call that you wish to make.
 
 https://api.linkedin.com/v1/people/~?oauth2_access_token=AQXdSP_W41_UPs5ioT_t8HESyODB4FqbkJ8LrV_5mff4gPODzOYR
 
 post too
 http://api.linkedin.com/v1/people/~/shares
 
 <share>
 <comment>Check out the LinkedIn Share API!</comment>
 <content>
 <title>LinkedIn Developers Documentation On Using the Share API</title>
 <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
 <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
 <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
 </content>
 <visibility>
 <code>anyone</code>
 </visibility>
 </share>
 
 <?xml version="1.0" encoding="UTF-8"?>
 <share>
 <comment>Check out the LinkedIn Share API!</comment>
 <content>
 <title>LinkedIn Developers Documentation On Using the Share API</title>
 <description>Leverage the Share API to maximize engagement on user-generated content on LinkedIn</description>
 <submitted-url>https://developer.linkedin.com/documents/share-api</submitted-url>
 <submitted-image-url>http://m3.licdn.com/media/p/3/000/124/1a6/089a29a.png</submitted-image-url>
 </content>
 <visibility>
 <code>anyone</code>
 </visibility>
 </share>
 
 // store credentials
 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
 [userDefaults setObject:accessToken forKey:LINKEDIN_TOKEN_KEY];
 [userDefaults setDouble:expiration forKey:LINKEDIN_EXPIRATION_KEY];
 [userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:LINKEDIN_CREATION_KEY];
 [userDefaults synchronize];
 
 - (BOOL)validToken {
 NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
 if ([[NSDate date] timeIntervalSince1970] >= ([userDefaults doubleForKey:LINKEDIN_CREATION_KEY] + [userDefaults doubleForKey:LINKEDIN_EXPIRATION_KEY])) {
 return NO;
 }
 else {
 return YES;
 }
 }
 
 - (NSString *)accessToken {
 return [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
 }
 
 current user {
 firstName = Paulo;
 headline = "Founder at advancedeventmanagement.com";
 lastName = Cristo;
 siteStandardProfileRequest =     {
 url = "http://www.linkedin.com/profile/view?id=14868785&authType=name&authToken=DhuV&trk=api*a3233463*s3306483*";
 };
 }
 
 }*/
#pragma LINKEDIN NSREQUEST STUFF
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    NSString *msg;
    if([responseString rangeOfString:@"<update-key>"].location!=NSNotFound) {
        //post ok
        msg = NSLocalizedString(@"linkedin_post_ok", @"linkedin_post_ok");
    }
    else {
        //error
        msg = NSLocalizedString(@"linkedin_post_canceled", @"linkedin_post_canceled");
    }
    
    [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    
    [self resetSocialNetworks:true];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"Failed with %@",error.localizedDescription);
}

#pragma OPEN APP STORE

-(void)openAppStore {

    NSString *appStoreID = @"837165900";
    if(storeController==nil) {
       storeController = [[SKStoreProductViewController alloc] init];
    }
    
    storeController.delegate = self;
    
    //[storeController.navigationItem.leftBarButtonItem setTarget:self];
    //[storeController.navigationItem.leftBarButtonItem setAction:@selector(hideStoreView:)];

    
    NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : appStoreID };
    [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
        //Handle response
        
        //NSLog(@"Do something here %d",result);
        if(result ) {
            [self presentViewController:storeController animated:YES completion:nil];
        }
    }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    if (storeController!=nil){
        [storeController dismissViewControllerAnimated:YES completion:nil];
    }
}

//don´t think this is really necessary
- (void)dealloc {
    // ... your other -dealloc code ...
    //self.adView = nil;
}

//easymessage ADMOP
// iphone 8ad4ab8f6c3e4798bad4472517acf8a6
/**
 // MyViewController.h
 
 #import "MPAdView.h"
 
 @interface MyViewController : UIViewController <MPAdViewDelegate>
 
 @property (nonatomic, retain) MPAdView *adView;
 
 @end
 
 // MyViewController.m
 
 #import "MyViewController.h"
 
 @implementation MyViewController
 
 - (void)viewDidLoad {
 // ... your other -viewDidLoad code ...
 self.adView = [[[MPAdView alloc] initWithAdUnitId:@"8ad4ab8f6c3e4798bad4472517acf8a6"
 size:MOPUB_BANNER_SIZE] autorelease];
 self.adView.delegate = self;
 CGRect frame = self.adView.frame;
 CGSize size = [self.adView adContentViewSize];
 frame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - size.height;
 self.adView.frame = frame;
 [self.view addSubview:self.adView];
 [self.adView loadAd];
 [super viewDidLoad];
 }
 
 
 - (void)dealloc {
 // ... your other -dealloc code ...
 self.adView = nil;
 [super dealloc];
 }
 
 #pragma mark - <MPAdViewDelegate>
 - (UIViewController *)viewControllerForPresentingModalView {
 return self;
 }
 
 @end
 
 IPAD : f549ddd3a0944768a4f85f0cdd717faf
 
 initWithAdUnitId:@"f549ddd3a0944768a4f85f0cdd717faf"
 size:MOPUB_LEADERBOARD_SIZE] autorelease];
 
 NEEDED FRAMEWORKS:
 AdSupport.framework (*)
 AudioToolbox.framework
 AVFoundation.framework
 CoreGraphics.framework
 CoreLocation.framework
 CoreTelephony.framework
 iAd.framework
 MediaPlayer.framework
 MessageUI.framework
 MobileCoreServices.framework
 PassKit.framework (*)
 QuartzCore.framework
 Social.framework (*)
 StoreKit.framework (*)
 SystemConfiguration.framework
 Twitter.framework (*)
 (all files with arc)
 
 https://app.mopub.com/inventory/adunit/8ad4ab8f6c3e4798bad4472517acf8a6/generate/?status=success
 */


//FOR THE MOPUB
#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

//MOPUB only when the AD is received, we can adjust the size
// iAd's portrait banner size is 320x50, whereas AdMob's banner size is 320x48.
//In order to resize and position our adView accurately every time a new ad is retrieved,
//we can implement the -adViewDidLoadAd: delegate callback in our view controller
/*
- (void)adViewDidLoadAd:(MPAdView *)view
{
    CGSize size = [view adContentViewSize];
    CGFloat centeredX = (self.view.bounds.size.width - size.width) / 2;
    CGFloat bottomAlignedY = self.view.bounds.size.height - (2 * size.height);
    view.frame = CGRectMake(centeredX, bottomAlignedY, size.width, size.height);
}*/

/**
 *Create the banner view
 */
/*
- (void) createAdBannerView {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iPhone 3.2 or later.
        // [for example, load appropriate iPad nib file]
        self.adView = [[MPAdView alloc] initWithAdUnitId:@"f549ddd3a0944768a4f85f0cdd717faf"
                                                    size:MOPUB_LEADERBOARD_SIZE];
    }
    else {
        // The device is an iPhone or iPod touch.
        // [for example, load appropriate iPhone nib file]
        self.adView = [[MPAdView alloc] initWithAdUnitId:@"8ad4ab8f6c3e4798bad4472517acf8a6"
                                                    size:MOPUB_BANNER_SIZE];
    }
    
    
    self.adView.delegate = self;
    CGRect frame = self.adView.frame;
    CGSize size = [self.adView adContentViewSize];
    frame.origin.y = [[UIScreen mainScreen] applicationFrame].size.height - (2 * size.height);
    self.adView.frame = frame;
    [self.view addSubview:self.adView];
    [self.adView loadAd];
    

}
*/
#pragma mark - ADBannerViewDelegate

/*
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    //user clicked on the banner
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}*/

#pragma FacebookShareDelegate
- (void) sharer: (id<FBSDKSharing>)sharer didCompleteWithResults: (NSDictionary *)results {
    NSString* message = self.body.text;
    NSString *msg = NSLocalizedString(@"facebook_post_ok", @"facebook_post_ok");
    
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    if(self.presentedViewController!=nil) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    if(sendToTwitter) {
        [self sendToTwitter:message]; //will reset inside
    }
    else if(sendToLinkedin) {
        //before send check if we need authorization
        [self authorizeAndSendToLinkedin:message];
    }
    else {
        //reset now
        [self resetSocialNetworks:YES];
    }
}

- (void) sharer:  (id<FBSDKSharing>)sharer didFailWithError: (NSError *)error {
    [self handleFacebookFailure];
}

- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
    [self handleFacebookFailure];
}

-(void) handleFacebookFailure {
    NSString* message = self.body.text;
    NSString *msg = NSLocalizedString(@"facebook_post_canceled", @"facebook_post_canceled");
    if(msg!=nil) {
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    if(self.presentedViewController!=nil) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    if(sendToTwitter) {
        [self sendToTwitter:message]; //will reset inside
    }
    else if(sendToLinkedin) {
        //before send check if we need authorization
        [self authorizeAndSendToLinkedin:message];
    }
    else {
        //reset now
        [self resetSocialNetworks:NO];
    }
}

@end
