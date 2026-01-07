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
#import "ScheduledModel.h"
#import "SimpleContactModel.h"
#import "PCReachability.h"
#import "AFHTTPSessionManager.h"
#import "AFURLResponseSerialization.h"
#import "AFHTTPRequestOperation.h"
#import "JSONResponseSerializerWithData.h"
#import "NBPhoneNumberUtil.h"

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
@synthesize addImage, removeImage, tooltipView,pickerBlockView;
@synthesize scheduleLaterSwitch;
@synthesize messageRecipients;
@synthesize pending;
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
    

    self.imagesCollection.scrollEnabled = true;
   //  self.imagesCollection setS
    self.imagesCollection.dataSource = self;
    self.imagesCollection.delegate = self;
    
    addImage = [UIImage imageNamed:@"add"];
    removeImage = [UIImage imageNamed:@"delete"];

    self.isDeviceOnline = false;
    
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
    
    
    selectedRecipientsList = [[NSMutableArray alloc]init];
    [scrollView flashScrollIndicators];
    
    [scrollView setContentSize: CGSizeMake(0, self.view.frame.size.height)];//;self.view.frame.size
    [self.scrollView setContentOffset: CGPointMake(0, self.scrollView.contentOffset.y)];
    self.scrollView.directionalLockEnabled = YES;
    
    [self.attachmentsScrollview setContentSize: CGSizeMake(self.imagesCollection.frame.size.width,0 )];//;self.view.frame.size
    [self.attachmentsScrollview setContentOffset: CGPointMake(self.attachmentsScrollview.contentOffset.x,0)];
    self.attachmentsScrollview.directionalLockEnabled = YES;

    self.tabBarController.tabBar.tintColor = [self colorFromHex:LITE_COLOR];
    
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

//handle tooltips on view appear and disapear
-(void) viewDidDisappear:(BOOL)animated {
    if(self.isShowingTooltip && self.tooltipView!=nil) {
        [self.tooltipView dismissAnimated:YES];
        self.isShowingTooltip = false;
    }
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // any code, dismissed by user
    self.isShowingTooltip = false;
}
-(void) viewDidAppear:(BOOL)animated {
    
    [self checkIfOnline];
    
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
            
            //also avoid unnecessary reload of recipients screen
            [defaults setBool:false forKey:@"force_reload"];
        }
    }

    if(![defaults boolForKey:SHOW_HELP_TOOLTIP_MAIN]) {
        //shows help tooltip
        self.tooltipView = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"tooltip_easy_message",nil)];
        self.tooltipView.delegate = self;
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        self.tooltipView.backgroundColor =  [delegate colorFromHex:PREMIUM_COLOR]; //normal lite color
        //self.tooltipView.title = NSLocalizedString(@"welcome_message", nil);
        [self.tooltipView  presentPointingAtView:self.sendButton.imageView inView:self.view animated:YES];
        self.isShowingTooltip = true;
        [defaults setBool:YES forKey:SHOW_HELP_TOOLTIP_MAIN];
    }
    
    
    
    //if we have a prefill text we use it
    [self checkForPrefilledMessage];
    //update the buuton to add/remove
    [self updateAddRemoveRecipients];
}

-(void) checkForPrefilledMessage{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if([defaults valueForKey:@"prefillMessage"] != nil) {
        
        //is a prefill message of type birthday
        if([[defaults valueForKey:@"prefillMessageType"] isEqualToString:@"birthday"] ) {
            
            NSDate *date = [[NSDate alloc] init];
            NSCalendar* calendarToday = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *componentsToday = [calendarToday components: NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
            
            //day & month of the birthday (same as today date maybe?)
            NSUInteger day = [[defaults valueForKey:@"day"] integerValue];
            NSUInteger month = [[defaults valueForKey:@"month"] integerValue];
            
            //if is a birthday match only show Happy Anniversary if that is the matching day
            if(day == componentsToday.day && month == componentsToday.month) {
                self.body.text = [defaults valueForKey:@"prefillMessage"];
                
                //TODO improve this, i should not need to fetch the contacts again, but for 1st implementation is OK!
                [self.recipientsController searchForBirthdayIn:day month:month];
            }
            //in any case remove these keys
            [defaults removeObjectForKey:@"day"];
            [defaults removeObjectForKey:@"month"];
            [defaults removeObjectForKey:@"prefillMessageType"];
            
            
        } else {
            //Ok to set the body anyway
            self.body.text = [defaults valueForKey:@"prefillMessage"];
        }
        
        [defaults removeObjectForKey:@"prefillMessage"];
        
        [defaults synchronize];
    }
}

//prefill all the stuff form the scheduled model
-(void) checkForPrefilledScheduledMessage: (NSString *) modelIdentifier {
    
    
    //TODO save current settings and restore them after the prefilled message? or not?!!!
    if(modelIdentifier!=nil) {
        
        ScheduledModel *model = [ScheduledModel getModelFromIndentifier:modelIdentifier];
        if(model!=nil) {
            self.body.text = model.message;
            self.subject.text = model.subject!=nil ? model.subject : @"";
            self.saveMessage = model.saveAsTemplate;
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.saveMessageSwitch setOn:self.saveMessage];
                [self.scheduleLaterSwitch setOn:false];
            });
            
            if(model.socialNetworks!=nil && model.socialNetworks.count > 0) {
             
                BOOL isFacebookAvailable = settingsController.socialOptionsController.isFacebookAvailable;
                BOOL isTwitterAvailable = settingsController.socialOptionsController.isTwitterAvailable;

                [settingsController.socialOptionsController.selectedServiceOptions removeAllObjects]; //we clear the current list
                
                if(isFacebookAvailable && [model.socialNetworks containsObject:@"facebook"]) {
                    
                    [settingsController.socialOptionsController.selectedServiceOptions addObject:OPTION_SENDTO_FACEBOOK_ONLY];
                    
                }
                if (isTwitterAvailable && [model.socialNetworks containsObject:@"twitter"]){
                     [settingsController.socialOptionsController.selectedServiceOptions addObject:OPTION_SENDTO_TWITTER_ONLY];
                }
                  
                if ([model.socialNetworks containsObject:@"linkedin"]){
                     [settingsController.socialOptionsController.selectedServiceOptions addObject:OPTION_SENDTO_LINKEDIN_ONLY];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [settingsController.socialOptionsController.tableView reloadData];
                });
            }
            
            
            settingsController.selectSendOption = model.sendOptions;
            settingsController.selectPreferredService = model.preferredService;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [settingsController.tableView reloadData];
            });
            //TODO the social networks and reload the tables? maybe not a god idea! just change the values
            //and after we send this message we restore the previous settings?
            
            NSMutableArray *results = [self.recipientsController findRecipientsFromScheduledModel: model.recipients];
            if(results.count > 0) {
                [self.selectedRecipientsList removeAllObjects];
                [self.selectedRecipientsList addObjectsFromArray:results];
            }
            
            if(model.assetURLS.count > 0) {
                [self loadAssetsFromLocalIdentifiers: model.assetURLS];
            }
            
            if([self showMessageAccordingToDefaults:@"restore_from_scheduled" numberOfTimesToShow:2]) {
                Popup *popup = [[Popup alloc] initWithTitle:NSLocalizedString(@"scheduled_messages",nil)
                                                   subTitle:NSLocalizedString(@"restore_from_scheduled",nil)
                 cancelTitle:nil
                successTitle:@"OK"];
                
                [popup setBackgroundColor:[self colorFromHex:LITE_COLOR]];
                [popup setBorderColor:[UIColor blackColor]];
                [popup setTitleColor:[UIColor whiteColor]];
                [popup setSubTitleColor:[UIColor whiteColor]];
                [popup setSuccessBtnColor:[self colorFromHex:PREMIUM_COLOR]];
                [popup setSuccessTitleColor:[UIColor whiteColor]];
                //[popup setBackgroundBlurType:PopupBackGroundBlurTypeLight];
                [popup setRoundedCorners:YES];
                [popup setTapBackgroundToDismiss:YES];
                
                [popup showPopup];
            }
            
            
        }
    }
}

//only show some warning messages like the first 2 times or so, otherwise they can get annoying for advanced users
-(BOOL) showMessageAccordingToDefaults:(NSString *) key numberOfTimesToShow:(NSUInteger) numTimes {
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:key]!=nil) {
        NSUInteger num = (NSUInteger)[defaults integerForKey:key];
        num++;
        [defaults setInteger:num forKey:key];
        if(num > numTimes) {
            return false;
        }
    } else {
       [defaults setInteger:1 forKey:key];
    }
    return true;
}

//before IOS 10
//TODO make generic for other type of notifications
-(void) scheduleNotification: (NSString *) type nameOfContact: name month: (NSInteger) month day: (NSInteger) day fireDelayInSeconds: (NSTimeInterval) delay{
    //Get all previous notifications..
    //NSLog(@"scheduled notifications: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
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
        
        //NSLog(@"birthday notification fire date: %@ ",[SetAlarmAt description]);
        
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
        
    });
}

-(void) scheduleNotificationAfterV10: (NSString *) message {
    //https://stackoverflow.com/questions/39941778/how-to-schedule-a-local-notification-in-ios-10-objective-c
    NSDate *now = [NSDate date];
    
    // NSLog(@"NSDate--before:%@",now);
    
    NSDate *futureDate = [now dateByAddingTimeInterval:60*60*24*3]; // 3 days later
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitTimeZone fromDate:futureDate];
    
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
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    
    if([self isDarkModeEnabled]) {
        self.tabBarController.tabBar.tintColor = [UIColor blackColor]; //[self colorFromHexString:@"#1c1c1e"];//1c1c1e
        self.view.backgroundColor =  [delegate defaultTableColor:true];
        self.labelAttach.textColor = [UIColor whiteColor];
        self.labelSaveArchive.textColor = [UIColor whiteColor];
        self.labelMessage.textColor = [UIColor whiteColor];
        self.labelSubject.textColor = [UIColor whiteColor];
        self.subjectView.backgroundColor = [delegate defaultTableColor:true];
        self.imagesCollection.backgroundColor = [delegate defaultTableColor:true];
        self.body.backgroundColor = [delegate defaultTableColor:true]; //[delegate colorFromHex:0x1c1c1e];
    } else {
        
        self.tabBarController.tabBar.tintColor =  [delegate colorFromHex:LITE_COLOR]; //normal lite color
        self.view.backgroundColor = [UIColor whiteColor];//[UIColor whiteColor];
        self.labelAttach.textColor = [UIColor blackColor];
        self.labelSaveArchive.textColor = [UIColor blackColor];
        self.labelMessage.textColor = [UIColor blackColor];
        self.labelSubject.textColor = [UIColor blackColor];
        self.subjectView.backgroundColor = [UIColor whiteColor];//[UIColor whiteColor];
        self.imagesCollection.backgroundColor = [UIColor whiteColor];// [UIColor whiteColor];
        self.body.backgroundColor = [UIColor whiteColor];//[UIColor whiteColor];
    }
    
    [self showHideSocialOnlyLabel];
    [self updateAttachmentsLabel];
    [self updatePremiumLabels];
    
    self.navigationController.navigationBar.backgroundColor =  [self colorFromHex:LITE_COLOR];
    //self.tabBarController.navigationController.navigationBar.backgroundColor =  [self colorFromHex:LITE_COLOR];
    
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
    NSInteger lengthBody = (textField.text == nil) ? 0 : textField.text.length;
    
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
                
                if([self checkIfShouldWarnAboutImessage]){
                    [self warnAboutImessage: ^(BOOL completion) {
                        if(completion) {
                            //do it anyway
                            
                            //proceeed normally only after dismiss the popup
                            if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                                
                                emailSentOK = NO;
                                
                                [self sendEmail:nil];//will send sms on dismiss email
                            }
                            else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                                
                                smsSentOK = NO;
                                self.messageRecipients = [self getPhoneNumbers];
                                if(self.messageRecipients.count > 0) {
                                    [self sendSMS:nil isRecursive:false];
                                }
                            }
                            
                            
                        } else {
                            //cancel
                            return; //do nothing
                        }
                    }];
                } else {
                    
                    //proceeed normally, no need to popup
                    if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                        
                        emailSentOK = NO;
                        
                        [self sendEmail:nil];//will send sms on dismiss email
                    }
                    else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                        
                        smsSentOK = NO;
                        self.messageRecipients = [self getPhoneNumbers];
                        if(self.messageRecipients.count > 0) {
                            [self sendSMS:nil isRecursive:false];
                        }
                    }
                }
                    
            } else {
                //proceed normally
                if(settingsController.selectSendOption == OPTION_ALWAYS_SEND_BOTH_ID || settingsController.selectSendOption == OPTION_SEND_EMAIL_ONLY_ID) {
                    
                    emailSentOK = NO;
                    
                    [self sendEmail:nil];//will send sms on dismiss email
                }
                else if(settingsController.selectSendOption == OPTION_SEND_SMS_ONLY_ID) {
                    
                    smsSentOK = NO;
                    self.messageRecipients = [self getPhoneNumbers];
                    if(self.messageRecipients.count > 0) {
                        [self sendSMS:nil isRecursive:false];
                    }
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
-(void) warnAboutImessage: (void (^)(BOOL finished))completion{
    
    Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                       subTitle:NSLocalizedString(@"imessage_warn",nil)
                                    cancelTitle:NSLocalizedString(@"Cancel",nil)
                                   successTitle:@"Ok"
                                    cancelBlock:^{
                                        //Custom code after cancel button was pressed
                                        completion(false);
                                    } successBlock:^{
                                        //Custom code after success button was pressed
                                        completion(true);
                                    }];
    
    [popup setBackgroundColor:[self colorFromHex:LITE_COLOR]];
    //https://github.com/miscavage/Popup
    [popup setBorderColor:[UIColor blackColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup setSuccessBtnColor:[self colorFromHex:PREMIUM_COLOR]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelBtnColor:[self colorFromHex:PREMIUM_COLOR]];
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
    if(numMessages == 10) {
        
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
    
    [popup setBackgroundColor:[self colorFromHex:LITE_COLOR]];
    //https://github.com/miscavage/Popup
    [popup setBorderColor:[UIColor blackColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup setSuccessBtnColor:[self colorFromHex:PREMIUM_COLOR]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelBtnColor:[self colorFromHex:PREMIUM_COLOR]];
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
        
        if([self linkedinID]!=nil) {
           [self sendToLinkedin:message withToken:token];
        } else {
            //send afterwards
            [self requestMeWithToken:token andMessage: message];
            //[self sendToLinkedin:message withToken:token];
        }
        
        
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
        
        //Check if the app just got opened from a push notification
        if([defaults objectForKey:APP_OPENED_FROM_PUSH]!=nil) {
            
            NSString *notificationIdentifier = [defaults objectForKey:APP_OPENED_FROM_PUSH];
            //get the data and prefill stuff
            [self checkForPrefilledScheduledMessage:notificationIdentifier];
            //we do not need it anymore, remove it

            if([ScheduledModel removeModel:notificationIdentifier]) {
                //next time that the view appears it will reload
                [defaults setBool:true forKey:@"reload_scheduled_model"];
            }
          
            [defaults removeObjectForKey:APP_OPENED_FROM_PUSH];
        }
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
        if(![cleanList containsObject:c] && c!=nil ) {
            [cleanList addObject:c];
        }
        else {
            duplicates++;
        }
    }
    
    NSLog(@"readed %ld contacts from core data models, but will only add %ld",(unsigned long)models.count, cleanList.count);
    
    if(cleanList!=nil && cleanList.count > 0) {
        [recipientsController.contactsList addObjectsFromArray:cleanList];
    }
    
    [recipientsController.selectedContactsList removeAllObjects];
    
    if(selectedRecipientsList!=nil && selectedRecipientsList.count > 0) {
      [recipientsController.selectedContactsList addObjectsFromArray:selectedRecipientsList];
    }
    
    NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
}

-(IBAction)loadContactsList:(id)sender {
    
    //need to allocate an instance
    CNContactStore * contactStore = [[CNContactStore alloc] init];
    
    //this request for permissions is executed on background thread
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        if(!granted) {
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                //make sure this is all done on main thread
                
                [self showPermissionsMessage];
                //clean contacts
                [recipientsController.contactsList removeAllObjects];
                //clean groups
                [recipientsController.groupsList removeAllObjects];
                [recipientsController.groupsNamesArray removeAllObjects];
                
                //still load these anyway, no need permissions
                [self loadContactsFromCoreDataOnly];
                
                //main thread
                //load also the groups
                [self loadGroupsFromCoredDataOnly];
                //refresh the phone book
                [recipientsController refreshPhonebook:nil];
                
            });
            
            
        }
        else {
            
            //always call this on the main thread
            dispatch_async(dispatch_get_main_queue(), ^(){
           
                [self showLoadingAnimation];
                
            });
         
     
              @try {
                  
                  //first we clean the lists
                  [recipientsController.contactsList removeAllObjects];
                  //clean contacts & groups
                  [recipientsController.groupsList removeAllObjects];
                  [recipientsController.groupsNamesArray removeAllObjects];
                  
                  //core data is read on main thread
                  //load contacts
                  [self loadContactsFromCoreDataOnly];
                  //load groups
                  [self loadGroupsFromCoredDataOnly];
                  
                  //load iCloud contacts
                  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                      
                      NSLog(@"---START IMPORT---");
                      
                      NSMutableArray *contacts = [self loadContactsFromAddressBook: contactStore];
                      
                      if(contacts!=nil && contacts.count > 0) {
                         [recipientsController.contactsList addObjectsFromArray:contacts];
                      }
                      
                      //load icloud groups
                      NSMutableArray *groupsFromICloud = [self loadGroupsFromAddressGroup:contactStore];
                      if(groupsFromICloud!=nil && groupsFromICloud.count > 0) {
                          [recipientsController.contactsList addObjectsFromArray:groupsFromICloud];
                      }
                      
                      NSLog(@"---FINISH IMPORT---");
                      
                      
                      dispatch_async(dispatch_get_main_queue(), ^(){
                          
                          //this must be done in main thread
                          NSLog(@"---REFRESH PHONEBOOK LIST---");
                          [self hideLoadingAnimation];
                          [recipientsController refreshPhonebook:nil];
                          
                      });
                       
                  });
              }@catch (NSException *err) {
                  
                  NSString *msg = [NSString stringWithFormat:@"Error loading contacts %@",err.description];
                  NSLog(@"Error loading contacts %@", err.description);
                  [self showAlertBox:msg];
                  
              }@finally {
                  
              }
           
        }
    }];
  
}

//load groups from icloud
-(NSMutableArray *) loadGroupsFromAddressGroup: (CNContactStore *) store {
    //load native groups, from icloud

    NSError *error;
    NSArray *groups = [store groupsMatchingPredicate:nil error:&error];
    
    NSMutableArray *groupsFromICloud = [[NSMutableArray alloc] init];
    
    if (error) {
        NSLog(@"error fetching groups %@", error);
    } else {
        
        NSLog(@"Loaded %lu groups from iCloud ", (unsigned long)groupsFromICloud.count);
        //LOOP THROUGH THE CONTACTS
        for (CNGroup *storeGroup in groups) {
            
            NSLog(@"LOADED GROUP NAMED %@", storeGroup.name);
            //create the group object
            Group *group = [[Group alloc] init];
            group.email=@"";
            group.name = storeGroup.name;
            group.lastName = storeGroup.name;
            group.person = nil;
            group.person_new = nil;
            
            group.isNative = true;
            group.isFavorite = false;
            
            
            NSMutableArray *members = [self loadContactsFromGroup:storeGroup store:store];
            
            group.contactsList = members;
            
            [groupsFromICloud addObject:group];

        }
    }

    return groupsFromICloud;
 
}

-(void) loadGroupsFromCoredDataOnly {
  //load also the groups
  NSMutableArray *groupsFromDB = [self fetchGroupRecords];
  
  if(groupsFromDB!=nil && groupsFromDB.count > 0) {
      [recipientsController.contactsList addObjectsFromArray:groupsFromDB];
  }
  
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
        
        group.isFavorite = model.favorite;
        
        for(ContactDataModel *contact in model.contacts) {
            
            Contact *c = [[Contact alloc] init];
            c.name = contact.name;
            c.phone = contact.phone;
            c.email = contact.email;
            c.lastName = contact.lastname;
            
            c.isFavorite = contact.favorite;
            
            if(contact.alternateEmails!=nil && contact.alternateEmails.length > 0) {
                c.alternateEmails = [[NSMutableArray alloc] init];
                [c.alternateEmails addObjectsFromArray:[contact.alternateEmails componentsSeparatedByString: @";"]];
            }
            
            if(c!=nil) {
              [group.contactsList addObject:c];
            }
            
        }
        //avoid duplicates
        if(![records containsObject:group] && group!=nil) {
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
                
                c.isFavorite = contact.favorite;
                
                if(contact.alternateEmails!=nil && contact.alternateEmails.length > 0) {
                    c.alternateEmails = [[NSMutableArray alloc] init];
                    [c.alternateEmails addObjectsFromArray:[contact.alternateEmails componentsSeparatedByString: @";"]];
                }
                
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
                if(c!=nil) {
                  [records addObject:c];
                }
                
            }
            
            
            
            
        }
    

    return records;
    
}

-(void) showLoadingAnimation {
    
    NSString *message = [NSString stringWithFormat:@"%@...\n\n", NSLocalizedString(@"please_wait_while_load", nil) ];
    pending = [UIAlertController alertControllerWithTitle:nil
                                                                   message: message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor blackColor];
    indicator.translatesAutoresizingMaskIntoConstraints=NO;
    [pending.view addSubview:indicator];
    NSDictionary * views = @{@"pending" : pending.view, @"indicator" : indicator};

    NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
    NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    
    [pending.view addConstraints:constraints];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];
    [self presentViewController:pending animated:YES completion:nil];
    
}

-(void) hideLoadingAnimation {
    if(pending!=nil) {
        [pending dismissViewControllerAnimated:YES completion:nil];
    }
  
}
//new approach to load teh address book
-(NSMutableArray *) loadContactsFromAddressBook : (CNContactStore * ) store{
    //https://gist.github.com/willthink/024f1394474e70904728
    
    
    //get current date
    NSDate * today = [NSDate date];
    //tomorrow
    NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate: today];
    
    //today date components
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today];
    //tomorrow date components
    NSDateComponents *componentsTomorrow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: tomorrow];

        
   //all contacts list
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
        
    //keys with fetching properties
    NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactImageDataKey, CNContactBirthdayKey];
    NSString *containerId = store.defaultContainerIdentifier;
    NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
    NSError *error;
    
    NSArray *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys error:&error];

        if (error) {
            NSLog(@"error fetching contacts %@", error);
            return contacts; //empty list
        } else {
            
            NSLog(@"Successfuly loaded %lu contacts" , (unsigned long)cnContacts.count);
            //LOOP THROUGH THE CONTACTS
            for (CNContact *storeContact in cnContacts) {
                //our custom class
                Contact *contact = [[Contact alloc] init];
                if(storeContact.givenName!=nil) {
                    contact.name = storeContact.givenName;
                }
                
                if(storeContact.familyName!=nil) {
                    contact.lastName = storeContact.familyName;
                }
                //check birth date and set reminder if any
                NSDateComponents *componentsBirthDate = storeContact.birthday;
                if(componentsBirthDate!=nil) {

                    //NSDateFormatter *f = [[NSDateFormatter alloc]init];
                    //[f setDateFormat:@"MMMM dd,yyyy"]
                    contact.birthday = componentsBirthDate.date;
                    
                 
                    //we have a birthday today
                    if(components.day == componentsBirthDate.day && components.month == componentsBirthDate.month) {
                        //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                        //so we need to clearly identify it
                        
                        [self scheduleNotification: @"birthday" nameOfContact: contact.name month: components.month day: components.day fireDelayInSeconds:60];
                        
                    }
                    //we have a birthday tomorrow
                    else if(componentsTomorrow.day == componentsBirthDate.day && componentsTomorrow.month == componentsBirthDate.month) {
                        
                        //TODO also send the email or other field... ate the end we need to prefill the message and pre-select the recipient
                        //so we need to clearly identify it
                        
                        [self scheduleNotification: @"birthday" nameOfContact: contact.name month: componentsTomorrow.month day: componentsTomorrow.day fireDelayInSeconds:(24*60*60)];
                        
                    } else {
                        
                        NSTimeInterval secondsBetween = [componentsBirthDate.date timeIntervalSinceDate:components.date];
                        
                        [self scheduleNotification: @"birthday" nameOfContact: contact.name month: componentsBirthDate.month day: componentsBirthDate.day fireDelayInSeconds: fabs(secondsBetween)];
                    }
                    
                }
                
                //save the reference for the CNContact
                contact.person_new = storeContact; //probably a really bad idea
                contact.isNative = true;
                contact.isFavorite = false;//false for native ones
                
                //read the email
                NSInteger countEmails = storeContact.emailAddresses.count;
                for (CNLabeledValue *label in storeContact.emailAddresses) {
                    NSString *email = [label.value isKindOfClass: NSString.class] ? label.value : [label.value stringValue];
                    if ([email length] > 0) {
                        //we just grab the first one on the list as the preferred one
                        if(contact.email == nil) {
                           contact.email  = email;
                        } else {
                            
                            //add the other alternatives
                            if(contact.alternateEmails == nil) {
                                //multiple emails
                                contact.alternateEmails = [[NSMutableArray alloc] initWithCapacity:countEmails-1];
                            }
                            //always add
                            [contact.alternateEmails addObject:email];
                            
                        }
                        //break; //just read 1 email field
                    }
                }
                
                //read the phone number
                NSInteger countPhones = storeContact.phoneNumbers.count;
                for (CNLabeledValue *label in storeContact.phoneNumbers) {
                    NSString *phone = [label.value isKindOfClass: NSString.class] ? label.value : [label.value stringValue];
                    if ([phone length] > 0) {
                        if(contact.phone == nil && [self isMobilePhone:phone]) {
                            
                           contact.phone = phone;
                        } else {
                            
                            if(contact.alternatePhones == nil) {
                                contact.alternatePhones = [[NSMutableArray alloc] initWithCapacity:countPhones-1];
                            }
                            [contact.alternatePhones addObject:phone];
                        }
                    }
                }
                //at the end check if i have one mobile at least
                if(contact.phone == nil && contact.alternatePhones!= nil && contact.alternatePhones.count > 0) {
                    //just grab the first
                    contact.phone = [contact.alternatePhones objectAtIndex:0];
                    [contact.alternatePhones removeObjectAtIndex:0];
                }
                
                //try to get the photo if available
                if(storeContact.imageData!=nil) {
                      contact.photo = [UIImage imageWithData:storeContact.imageData];
                }
                
                if(contact.phone!=nil || contact.email!=nil) {
                    
                    //check for blanks (only phone number for instance, no name
                    if(contact.name == nil || [[contact.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                        contact.name = (contact.phone!= nil ? contact.phone : contact.email);
                    }
                }
                //add it to the list
                [contacts addObject:contact];
                
                
            }//end for loop
            
           
            
            //DO THE HAVY WORK HERE!
            NSMutableArray *cleanList = [[NSMutableArray alloc] init];

            
            NSInteger duplicates = 0;
            //auxiliar list to check for duplicates (might slow down stuff)
            for(Contact *c in contacts) {
                c.isNative = true;
                if(![cleanList containsObject:c] && c!=nil) {
                    [cleanList addObject:c];
                }
                else {
                    duplicates++;
                }
            }
            
            NSLog(@"readed %ld contacts from local address book, but will only add %lu",(unsigned long)contacts.count, (unsigned long)cleanList.count);
            
            NSLog(@"Skipped %ld duplicated contacts",(long)duplicates);
            
            return cleanList;
               
        }
    
   
}
/**
 This is not accurate by any means
 */
-(BOOL) isMobilePhone:(NSString *) phoneToCheck {
    

    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *anError = nil;
    BOOL mobile = false;
    NBPhoneNumber *theNumber = [phoneUtil parse:phoneToCheck defaultRegion:nil error:&anError];
    if(anError == nil) {
        NBEPhoneNumberType type = [phoneUtil getNumberType:theNumber];
        if(type == NBEPhoneNumberTypeMOBILE || type == NBEPhoneNumberTypeVOIP) {
            mobile = true;
        }
    }

    return mobile;
}
/**
 Load contacts inside a group iCloud
 */
-(NSMutableArray *) loadContactsFromGroup: (CNGroup *) storeGroup store:(CNContactStore*) store{
    
    NSMutableArray *members = nil;
    //NSLog(@"GROUP IDENTIFIER %@", storeGroup.identifier);
    
    //CNContactStore* newStore = [[CNContactStore alloc] init];
    NSPredicate *predicateGroupMembers = [CNContact predicateForContactsInGroupWithIdentifier:storeGroup.identifier];
    NSArray *keysGroups = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactImageDataKey, CNContactBirthdayKey];
    // @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey];
    NSError *errorMembers;
    
    NSArray *cnContactsInGroup = [store unifiedContactsMatchingPredicate:predicateGroupMembers keysToFetch:keysGroups error:&errorMembers];
    if(errorMembers!=nil) {
     //parse the elements of the group
        NSLog(@"ERROR parse the elements of the group %@", errorMembers.description);
    }
    else {
        members = [[NSMutableArray alloc] initWithCapacity:cnContactsInGroup.count];
        //NSLog(@"GROUP NAMED %@ has %lu members ", storeGroup.name, (unsigned long)cnContactsInGroup.count);
        for (CNContact *storeContact in cnContactsInGroup) {
            //our custom class
            Contact *contact = [[Contact alloc] init];
            if(storeContact.givenName!=nil) {
                contact.name = storeContact.givenName;
            }
            
            if(storeContact.familyName!=nil) {
                contact.lastName = storeContact.familyName;
            }
            
            
            //save the reference for the CNContact
            contact.person_new = storeContact; //probably a really bad idea
            contact.isNative = true;
            contact.isFavorite = false;//false for native ones
            
            //read the email
            NSInteger countEmails = storeContact.emailAddresses.count;
            for (CNLabeledValue *label in storeContact.emailAddresses) {
                NSString *email = [label.value isKindOfClass: NSString.class] ? label.value : [label.value stringValue];
                if ([email length] > 0) {
                    //we just grab the first one on the list as the preferred one
                    if(contact.email == nil) {
                       contact.email  = email;
                    } else {
                        
                        //add the other alternatives
                        if(contact.alternateEmails == nil) {
                            //multiple emails
                            contact.alternateEmails = [[NSMutableArray alloc] initWithCapacity:countEmails-1];
                        }
                        //always add
                        [contact.alternateEmails addObject:email];
                        
                    }
                    //break; //just read 1 email field
                }
            }
            
            //read the phone number
            NSInteger countPhones = storeContact.phoneNumbers.count;
            for (CNLabeledValue *label in storeContact.phoneNumbers) {
                NSString *phone = [label.value isKindOfClass: NSString.class] ? label.value : [label.value stringValue];
                if ([phone length] > 0) {
                    if(contact.phone == nil) {
                       contact.phone = phone;
                    } else {
                        
                        if(contact.alternatePhones == nil) {
                            contact.alternatePhones = [[NSMutableArray alloc] initWithCapacity:countPhones-1];
                        }
                        [contact.alternatePhones addObject:phone];
                    }
                }
            }
            
            //try to get the photo if available
            if(storeContact.imageData!=nil) {
                  contact.photo = [UIImage imageWithData:storeContact.imageData];
            }
            
            if(contact.phone!=nil || contact.email!=nil) {
                
                //check for blanks (only phone number for instance, no name
                if(contact.name == nil || [[contact.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                    contact.name = (contact.phone!= nil ? contact.phone : contact.email);
                }
            }
            //add it to the list
            [members addObject:contact];
            
            
        }//end for loop
    }
    if(members == nil) {
        members = [[NSMutableArray alloc] init];//cannot be nil? TODO check
    }
    return members;
}


//load the groups from the address book
-(NSMutableArray *)loadGroups: (ABAddressBookRef) addressBook {
    
    NSMutableArray *groupsArray = [[NSMutableArray alloc] init];
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    if(groups) {
        CFIndex numGroups = CFArrayGetCount(groups);
        NSLog(@"Num groups is %ld",numGroups);
        for(CFIndex idx=0; idx<numGroups; ++idx) {
            
          @try {
            
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
            group.isFavorite = false;
            
            //always add
            if(![groupsArray containsObject:group] && group!=nil) {
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
                            //add the other alternatives
                            if(countPhones > 1) {
                                //multiple phones
                                c.alternatePhones = [[NSMutableArray alloc] initWithCapacity:countPhones-1];
                                NSMutableArray *alt = [self getAllPhonesButPreferred: phoneMulti preferredPhone:phone count:countPhones];
                                if(alt!=nil && alt.count > 0) {
                                    [c.alternatePhones addObjectsFromArray: alt];
                                }
                                
                            }
                        }
                        
                    }
                    //get email
                    NSString *email;
                    ABMultiValueRef emailMulti = ABRecordCopyValue(person, kABPersonEmailProperty);
                    int countEmails = ABMultiValueGetCount(emailMulti);
                    //do we have more than 1?
                    if(countEmails > 0) {
                        email = [self getPreferredEmail: emailMulti forLabel:kABHomeLabel count: countEmails];
                        if(email!=nil) {
                            c.email = email;
                            
                            //add the other alternatives
                            if(countEmails > 1) {
                                //multiple phones
                                c.alternateEmails = [[NSMutableArray alloc] initWithCapacity:countEmails-1];
                                NSMutableArray *alt = [self getAllEmailsButPreferred: emailMulti preferredEmail:email count:countEmails];
                                if(alt!=nil && alt.count > 0) {
                                    [c.alternateEmails addObjectsFromArray: alt];
                                }
                                
                            }
                        }
                    }
                    
                    //check for blanks (only phone number for instance, no name
                    if(c.name == nil || [[c.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
                        c.name = (phone!= nil ? phone : email);
                    }
                    
                    //NSLog(@"added person  %@ to the icloud group %@",name, groupName);
                    if(c!=nil) {
                        [group.contactsList addObject:c];
                    }
                   
                    
                }// end for
                CFRelease(members);
            }// end if members
              
          }@catch(NSException *error) {
             
          }@finally {
              ;//do nothing
           }
            
        }//end for
    }//end if groups
    
    
    return groupsArray;
}

//Load the contacts list from the address book
/**
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
        //make sure we have some people
        if(arrayOfPeople == nil || arrayOfPeople.count == 0) {
            return contacts;
        }
        
        for(int i = 0; i < arrayOfPeople.count; i++) {
            
            Contact *contact = [[Contact alloc] init];
            
            @try {
                
                
                ABRecordRef person = (__bridge ABRecordRef)[arrayOfPeople objectAtIndex:i];
                
                //get the first name
                NSString *name = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                if(name == nil) {
                    name = (__bridge NSString*)ABRecordCopyCompositeName(person);
                }
                NSString *lastName =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                //NSLog(@"LOADED NAME %@ AND LAST NAME %@",name,lastName);
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
                contact.isFavorite = false;//false for native ones
                
                NSString *email;
                
                //NSString *theName = (__bridge NSString*)ABRecordCopyCompositeName(person);
                
                
                ABMultiValueRef emailMulti = ABRecordCopyValue(person, kABPersonEmailProperty);
                
#pragma GET EMAIL ADDRESS
                
                
                int countEmails = ABMultiValueGetCount(emailMulti);
                
                //do we have more than 1?
                if(countEmails > 0) {
                    email = [self getPreferredEmail: emailMulti forLabel:kABHomeLabel count: countEmails];
                    
                }
                //else, we don´t have email
                
                //add it if we have it
                if(email!=nil) {
                    contact.email = email;
                    
                    //add the other alternatives
                    if(countEmails > 1) {
                        //multiple phones
                        contact.alternateEmails = [[NSMutableArray alloc] initWithCapacity:countEmails-1];
                        NSMutableArray *alt = [self getAllEmailsButPreferred: emailMulti preferredEmail:email count:countEmails];
                        if(alt!=nil && alt.count > 0) {
                            [contact.alternateEmails addObjectsFromArray: alt];
                        }
                        
                    }
                }
                
                
#pragma GET PHONE NUMBER
                
                NSString *phone;
                
                ABMultiValueRef phoneMulti = ABRecordCopyValue(person, kABPersonPhoneProperty);
                int countPhones = ABMultiValueGetCount(phoneMulti);
                
                if(countPhones>0) {
                    phone = [self getPreferredPhone: phoneMulti forLabel:kABPersonPhoneMobileLabel count: countPhones];
                    
                }
                
                //add the phone number
                if(phone!=nil) {
                    contact.phone = phone;
                    //add the other alternatives
                    if(countPhones > 1) {
                        //multiple phones
                        contact.alternatePhones = [[NSMutableArray alloc] initWithCapacity:countPhones-1];
                        NSMutableArray *alt = [self getAllPhonesButPreferred: phoneMulti preferredPhone:phone count:countPhones];
                        if(alt!=nil && alt.count > 0) {
                             [contact.alternatePhones addObjectsFromArray: alt];
                        }
                       
                    }
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
                        
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Unable to get contact photo, %@",[exception description]);
                    }
                    @finally {
                        ;//do nothing here
                    }
                    
                    
                }
                
            }// end try
            @catch (NSException *exception) {
                NSLog(@"Unable to get contact info, %@",[exception description]);
            }
            @finally {
                
                if(contact!=nil) {
                    [contacts addObject:contact];
                }
            }
            
        }//end for loop
        
        
    } //end if
    
    NSLog(@"DONE IMPORT");
    
    
    return contacts;
    
    
}*/

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

//add alternate phones
-(NSMutableArray *) getAllPhonesButPreferred: (ABMultiValueRef) properties preferredPhone:(NSString *) pref count: (NSInteger) size {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int k=0 ;k <size; k++)
    {
        NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        if(phone!=nil && ![phone isEqualToString:pref]) {
            [array addObject:phone];
        }
        
    }
    return array;
}
//add alternate emails
-(NSMutableArray *) getAllEmailsButPreferred: (ABMultiValueRef) properties preferredEmail:(NSString *) pref count: (NSInteger) size {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int k=0 ;k <size; k++)
    {
        NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(properties, k);
        if(email!=nil && ![email isEqualToString:pref]) {
            [array addObject:email];
        }
        
    }
    return array;
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
                self.messageRecipients = [self getPhoneNumbers];
                if(self.messageRecipients.count > 0) {
                    [self sendSMS:nil isRecursive:false];
                }
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
            self.messageRecipients = [self getPhoneNumbers];
            if(self.messageRecipients.count > 0) {
               [self sendSMS:nil isRecursive:false];
            }
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
            [self resetMessageFailuresCounter];
            break;
        case MFMailComposeResultFailed:
            msg = [NSString stringWithFormat:NSLocalizedString(@"message_mail_sent_failure_%@", @"Mail sent failure"),[error localizedDescription]];
            //if failed twice in a row offer some help
            if([self getNumberOfMessageFailures] >=3) {
                [self popupAboutMessageFailure:@"email"];
            }
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
        self.messageRecipients = [self getPhoneNumbers];
        if(self.messageRecipients.count > 0) {
            [self sendSMS:nil isRecursive:false];
        }
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
        {
            //just try to go to the next one
            //TODO CONTINUE
            if( [settingsController forceIndividualSMS] && [self stillHasRecipientsLeft] ) {
                
                //how many are left?
                //if more than 1 i can still remove the last one and go to next
                if(self.messageRecipients.count > 1) {
                    
                    NSUInteger indexToRemove = self.messageRecipients.count - 1;
                    [self.messageRecipients removeObjectAtIndex:indexToRemove];
                    msg = nil;
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    [self sendSMS:nil isRecursive:true];
                    
                } else {
                    //only 1 left, it was the one just sent
                    [self.messageRecipients removeAllObjects];
                    msg = NSLocalizedString(@"message_sms_sent",@"SMS sent");
                    smsSentOK = YES;
                    [self resetMessageFailuresCounter];
                    
                }
                
                break;
                
            } else {
                //IT FAILED!!!
                msg = NSLocalizedString(@"message_sms_unable_compose",@"Unable to compose SMS");
                
                //if failed twice in a row offer some help
                if([self getNumberOfMessageFailures] >=3) {
                    [self popupAboutMessageFailure:@"sms"];
                }
                
                break;
            }
        }
		case MessageComposeResultSent:
        {
            if( [settingsController forceIndividualSMS] && [self stillHasRecipientsLeft] ) {
                         
                         //how many are left?
                         //if more than 1 i can still remove the last one and go to next
                         if(self.messageRecipients.count > 1) {
                             
                             NSUInteger indexToRemove = self.messageRecipients.count - 1;
                             [self.messageRecipients removeObjectAtIndex:indexToRemove];
                             msg = nil;
                             //no completion yet
                             [self dismissViewControllerAnimated:YES completion:nil];
                             
                             [self sendSMS:nil isRecursive:true];
                             
                         } else {
                             
                             
                            //only 1 left, it was the one just sent
                             [self.messageRecipients removeAllObjects];
                             msg = NSLocalizedString(@"message_sms_sent",@"SMS sent");
                             smsSentOK = YES;
                             [self resetMessageFailuresCounter];
            
                         }
                         
                         break;
                         
                     } else {
                         
                         //all done!!!
                         msg = NSLocalizedString(@"message_sms_sent",@"SMS sent");
                         smsSentOK = YES;
                         [self resetMessageFailuresCounter];
                         
                         break;
                     }
        }
		default:
			break;
	}
    if(msg!=nil) {
        
        [self dismissViewControllerAnimated:YES completion:^{[self doSocialNetworksIfSelected];}];
               
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
        
    [str appendString:@"https://api.linkedin.com/v2/shares?oauth2_access_token="];
    [str appendString: token];
    NSString *postURL = [NSString stringWithString:str];
        
    //get the status message
    NSString *title = (subject.text!=nil && subject.text.length>0) ? subject.text : message;

    /***
     {
     "content": {
         "contentEntities": [
         {
            "entityLocation": "https://www.example.com/content.html",
            "thumbnails": [
                {
                    "resolvedUrl": "https://www.example.com/image.jpg"
                }
            ]
         }
         ],
         "title": "Test Share with Content"
     },
         "distribution": {
         "linkedInDistributionTarget": {}
         },
         "owner": "urn:li:person:324_kGGaLE",
         "subject": "Test Share Subject",
         "text": {
         "text": "Test Share!"
         }
     }
     https://artisansweb.net/share-post-on-linkedin-using-linkedin-api-and-php/
     **/
    
    @try {
        
    NSDictionary *resolvedUrl = [NSDictionary dictionaryWithObjectsAndKeys: @"https://is1-ssl.mzstatic.com/image/thumb/Purple/v4/ff/f7/ce/fff7ce0f-933f-6448-46d1-5945fef9783e/Icon-76@2x.png.png/75x9999bb.png",@"resolvedUrl", nil];
    
    NSArray *thumbnailslArray = [[ NSArray alloc] initWithObjects:resolvedUrl, nil];
    
    NSDictionary *thumbnails =  [NSDictionary dictionaryWithObjectsAndKeys:@"https://itunes.apple.com/app/id1448046358?mt=8", @"entityLocation", thumbnailslArray, @"thumbnails", nil];
    
    NSArray *contentEntitiesArray = [[ NSArray alloc] initWithObjects:thumbnails, nil];
    
   
    NSDictionary *textContainer =  [NSDictionary dictionaryWithObjectsAndKeys:message, @"text", nil];
    
    NSDictionary *content =  [NSDictionary dictionaryWithObjectsAndKeys:contentEntitiesArray, @"contentEntities", title, @"title", nil];
    
    NSDictionary *postData  = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",[self linkedinID], @"owner", textContainer,@"text", nil];
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* JSONBody = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postURL] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:20.0];
    // Specify that it will be a POST request
    [request setHTTPMethod: @"POST"];
    //with json body
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
    NSData *requestBodyData = [JSONBody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:requestBodyData];

        
    // Create url connection and fire request
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }
    @catch(NSException *err) {
        NSLog(@"Error: %@", err.description);
    }
    
}

//if the message mentions EasyMessage then is a regular share
-(BOOL) isEasyMessageShare: (NSString *) message {
    return [message rangeOfString:@"EasyMessage"].location !=NSNotFound ;
}

//so i know if i should keep repeating the call
-(BOOL) stillHasRecipientsLeft {
    return (self.messageRecipients!= nil && self.messageRecipients.count > 0);
}
//the isRecursive is TRUE if called from the message delegate (either success or fail for a recipient)
//otherwise is always FALSE
-(IBAction)sendSMS:(id)sender isRecursive:(BOOL) isRecursive {
    
 MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
 if([MFMessageComposeViewController canSendText]) {
    
    //check the setting TODO should be done only once no??
     BOOL sendOneByOne = [settingsController forceIndividualSMS];
     
    //how many left?
    NSUInteger count = (self.messageRecipients!= nil) ? self.messageRecipients.count : 0 ;
     
    //NSMutableArray *recipients = [self getPhoneNumbers];

    if(self.messageRecipients!=nil && self.messageRecipients.count>0) {
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        //start backwards, LIFO
        if(sendOneByOne) {
            //either failing or succedding, the last one is the one to remove
            [recipients addObject: [self.messageRecipients objectAtIndex:(count-1)] ];
        } else {
            //add them all and send them all at once
            [recipients addObjectsFromArray:self.messageRecipients];
        }
        
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
    
    
    
    if(saveMessage) {
        //TODO SAVE THE MESSAGE
        [self saveMessageInArchive];
    }
    
    [self clearInputFields];
    
    //the default action on beginning is also NOT save
    dispatch_async(dispatch_get_main_queue(), ^(){
        [saveMessageSwitch setOn:NO];
        [scheduleLaterSwitch setOn:NO];
        [recipientsController.tableView reloadData];
    });
    
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
    if(customMessagesController.messagesList!=nil && customMessagesController.messagesList.count > 0) {
      [fromList addObjectsFromArray:customMessagesController.messagesList];
    }
    
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
             [customMessagesController setForceReload:YES];
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
            NSString *emailAddress = [c getFavouriteEmail];// [self extractEmailAddress:c];
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
            NSString *phoneNumber = [c getFavouritePhone];//[self extractPhoneNumber:c];
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

//get the images back from the saved urls
-(void) loadAssetsFromLocalIdentifiers: (NSMutableArray *) identifiers {
    
    if(self.imagesArray==nil) {
        self.imagesArray = [[NSMutableArray alloc] init];
    } else {
        [self.imagesArray removeAllObjects];
    }
    
    PHImageManager *manager = [PHImageManager defaultManager];

    PHFetchResult *results = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    
    if(results!=nil && results.count > 0) {
        
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.networkAccessAllowed = true;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        // this one is key
        requestOptions.synchronous = YES;
        
        [self.attachments removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^(){
            for (PHAsset *asset in results) {
                // Do something with the asset
                
                [self.imagesArray addObject:asset];
                
                [manager requestImageForAsset:asset
                                   targetSize:PHImageManagerMaximumSize
                                  contentMode:PHImageContentModeDefault
                                      options:requestOptions
                                resultHandler:^void(UIImage *image, NSDictionary *info) {
                                    if(image!=nil) {
                                       // [self.attachments addObject:image];
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
    }

    
    
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

- (IBAction)switchScheduleMessageValueChanged:(id)sender {
   
    if(scheduleLaterSwitch.on) {
        
        //a block to restore the switch back to off
        void (^restoreSwitch)(void) = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [scheduleLaterSwitch setOn:false];
            });
        };
        
        if ([[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
            
            //do some preliminary checks first
            if(subject.text.length==0 && body.text.length==0) {
                
                [self showAlertBox: NSLocalizedString(@"alert_message_both_empty", @"Subject and message body cannot be empty!")];
                restoreSwitch();
                
                 
            }
            else if(body.text.length==0) {
                
                [self showAlertBox: NSLocalizedString(@"alert_message_body_empty",@"The message body cannot be empty!")];
                restoreSwitch();

            }
            else if(self.selectedRecipientsList.count == 0 && ( !sendToFacebook && !sendToTwitter && !sendToLinkedin) ) {
                [self showAlertBox: NSLocalizedString(@"alert_message_select_least_one",@"You need to select at least one recipient!")];
                restoreSwitch();
            }
            else {
                //all good, but still warn
                [self warnAboutScheduledmessage:^(BOOL accepted) {
                    if(accepted) {
                        [self ShowDatePicker];
                    } else {
                        //disable the switch again
                        restoreSwitch();
                    }
                }];
                
            }
            
        } else {
            //only for premium users!!!
           [self showUpgradeToPremiumMessage];
           restoreSwitch();
        }
        
    
    }
}

//shows a message to disable iMessage
-(void) warnAboutScheduledmessage: (void (^)(BOOL finished))completion{
    
    if([self showMessageAccordingToDefaults:@"scheduled_message_warn" numberOfTimesToShow:2]) {
        
        Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                           subTitle:NSLocalizedString(@"scheduled_message_warn",nil)
                                        cancelTitle:NSLocalizedString(@"cancel",nil)
                                       successTitle:@"OK"
                                        cancelBlock:^{
                                            //Custom code after cancel button was pressed
                                            completion(false);
                                         
                                        } successBlock:^{
                                            //Custom code after success button was pressed
                                            completion(true);
                                        }];
        
        [popup setBackgroundColor:[self colorFromHex:LITE_COLOR]];
        //https://github.com/miscavage/Popup
        [popup setBorderColor:[UIColor blackColor]];
        [popup setTitleColor:[UIColor whiteColor]];
        [popup setSubTitleColor:[UIColor whiteColor]];
        
        [popup setSuccessBtnColor:[self colorFromHex:PREMIUM_COLOR]];
        [popup setSuccessTitleColor:[UIColor whiteColor]];
        [popup setCancelBtnColor:[self colorFromHex:PREMIUM_COLOR]];
        [popup setCancelTitleColor:[UIColor whiteColor]];
        //[popup setBackgroundBlurType:PopupBackGroundBlurTypeLight];
        [popup setRoundedCorners:YES];
        [popup setTapBackgroundToDismiss:YES];
        [popup setDelegate:self];
        [popup showPopup];
    } else {
        completion(true);
    }
    
    //do not warn me again
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
            
            if([self linkedinID]!=nil) {
                [self sendToLinkedin:message withToken:accessToken];
            } else {
                //will send after
                [self requestMeWithToken:accessToken andMessage: message];
            }
            
        }   failure:^(NSError *error) {
            
            
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                     failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
    }];
}

//get personal info from linkedin
- (void)requestMeWithToken:(NSString *)accessToken andMessage: (NSString *) message {

    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v2/me?oauth2_access_token=%@", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        //{"localizedLastName":"Cristo","lastName":{"localized":{"en_US":"Cristo"},"preferredLocale":{"country":"US","language":"en"}},"firstName":{"localized":{"en_US":"Paulo"},"preferredLocale":{"country":"US","language":"en"}},"profilePicture":{"displayImage":"urn:li:digitalmediaAsset:C4E03AQH6BPC1_3Oqqw"},"id":"OQw3s_FY10","localizedFirstName":"Paulo"}
        
        NSString *identifier = [result objectForKey:@"id"];
        if(identifier!=nil) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithFormat:@"urn:li:person:%@", identifier] forKey:LINKEDIN_ME_KEY];
            //"owner": "urn:li:person:324_kGGaLE",
            
            [self sendToLinkedin:message withToken:accessToken];
        }
        
        
        NSLog(@"current user %@", result);
    }        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch current user %@", error);
    }];
}

- (LIALinkedInHttpClient *)client {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"https://crackedegggames.wixsite.com/easymessage"
                                                                                    clientId:@"[your client id]"
                                                                                clientSecret:@"[your client secret]"
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"w_member_social"]]; //@"r_liteprofile", //@"w_messages" w_member_social
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

- (NSString *)accessToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_TOKEN_KEY];
    return token;
    
}

- (NSString *)linkedinID {
    NSString *meId = [[NSUserDefaults standardUserDefaults] objectForKey:LINKEDIN_ME_KEY];
    return meId;
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
    //NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    NSString *msg;
    
    @try {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_responseData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        if([json objectForKey:@"id"]!=nil) {
            //post ok
            msg = NSLocalizedString(@"linkedin_post_ok", @"linkedin_post_ok");
        }else {
            //error
            msg = NSLocalizedString(@"linkedin_post_canceled", @"linkedin_post_canceled");
        }
        
    }@catch(NSException *err) {
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

-(BOOL) isDarkModeEnabled {
    if (@available(iOS 12.0, *)) {
        return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    } else {
        // Fallback on earlier versions
        return NO;
    }
}

//TODO
-(ContactDataModel *) prepareModelFromContact: (NSManagedObjectContext *) managedObjectContext: (Contact *)contact {
    
    ContactDataModel *contactModel = (ContactDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ContactDataModel" inManagedObjectContext:managedObjectContext];
    contactModel.name = contact.name;
    contactModel.phone = contact.phone;
    contactModel.email = contact.email;
    contactModel.birthday = contact.birthday;
    contactModel.lastname = contact.lastName;
    contactModel.group = nil;
    contactModel.favorite = contact.isFavorite;
    
    return contactModel;
}


-(GroupDataModel *) prepareModelFromGroup: (NSManagedObjectContext *) managedObjectContext: (Group *)group {
    
    GroupDataModel *groupModel = (GroupDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
    groupModel.name = group.name;

    return groupModel;
}

//show the date picker for the scheduled messages
-(void)ShowDatePicker {
    float height= [[UIScreen mainScreen] bounds].size.height;
    
    if(pickerBlockView == nil) {
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        
        pickerBlockView = [[UIView alloc]initWithFrame:CGRectMake(10, 2*(height/3), self.view.frame.size.width-20, height/3)];
        [pickerBlockView setBackgroundColor : [delegate colorFromHex:LITE_COLOR] ];//[self colorFromHex:0x4f6781] TODO PREMIUM COLOR 0x4f6781
        pickerBlockView.tag = 500;
        pickerBlockView.layer.cornerRadius = 20;
        pickerBlockView.layer.masksToBounds = YES;
        pickerBlockView.layer.borderWidth = 4;
        pickerBlockView.layer.borderColor = [[UIColor blackColor] CGColor];
        
        UIDatePicker *sortPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,  pickerBlockView.frame.size.height/6 , self.view.frame.size.width-20, pickerBlockView.frame.size.height-20)];
        sortPicker.tag = 888;
        NSDate *now = [NSDate date];
        sortPicker.date = now;
        sortPicker.minimumDate = now;
        
        sortPicker.backgroundColor =  [delegate colorFromHex:LITE_COLOR]; //normal lite color
        sortPicker.hidden = NO;
        //sortPicker.delegate = self;
        [pickerBlockView addSubview:sortPicker];

        UILabel *cancel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 30)];
        [cancel setTextColor:[UIColor whiteColor]];
        [cancel setBackgroundColor:[UIColor clearColor]];
        [cancel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
        [cancel setText:NSLocalizedString(@"cancel", nil)];
        [pickerBlockView addSubview:cancel];
        UITapGestureRecognizer* cancelGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelbtn:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [cancel setUserInteractionEnabled:YES];
        [cancel addGestureRecognizer:cancelGesture];

        UILabel *done = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, 5, 80, 30)];
        [done setTextColor:[UIColor whiteColor]];
        [done setBackgroundColor:[UIColor clearColor]];
        [done setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
        [done setText:NSLocalizedString(@"done_button", nil)];
        [pickerBlockView addSubview:done];

        UITapGestureRecognizer* doneGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(donebtn:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [done setUserInteractionEnabled:YES];
        [done addGestureRecognizer:doneGesture1];
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1.3;
    transition.type = kCATransitionFromBottom; //choose your animation
    [pickerBlockView.layer addAnimation:transition forKey:nil];

    [self.view addSubview:pickerBlockView];

}
#pragma date picker button handlers
-(void) cancelbtn: (UITapGestureRecognizer*) gesture {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0;
    transition.type = kCATransitionFade; //choose your animation
    [pickerBlockView.layer addAnimation:transition forKey:nil];
    
    [pickerBlockView removeFromSuperview];
    
}
-(void)donebtn: (UITapGestureRecognizer*) gesture  {
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0;
    transition.type = kCATransitionFade; //choose your animation
    [pickerBlockView.layer addAnimation:transition forKey:nil];
    
    BOOL sendToSocialMedia = (sendToTwitter || sendToFacebook || sendToLinkedin);
    if( (self.selectedRecipientsList.count > 0 || sendToSocialMedia) && self.body.text!=nil && [self.body.text length] > 0) {
        NSArray *views = [pickerBlockView subviews];
        if(views!=nil && views.count > 0) {
            for(UIView *view in views) {
                if([view isKindOfClass:UIDatePicker.class]) {
                    UIDatePicker *datePicker = (UIDatePicker *)view;
                    
                    [self checkIfPostToSocial];
                    
                    NSMutableArray *networks;
                    if(sendToSocialMedia) {
                        networks = [[NSMutableArray alloc] init];
                        if(sendToLinkedin) {
                            [networks addObject:@"linkedin"];
                        }
                        if(sendToFacebook) {
                            [networks addObject:@"facebook"];
                        }
                        if(sendToTwitter) {
                            [networks addObject:@"twitter"];
                        }
                    }
                    //TODO the social network options are not restored yet
                    NSMutableArray *recipients = [[NSMutableArray alloc] init];
                    for(Contact *contact in selectedRecipientsList) {
                        
                        if(contact!=nil) {
                            
                            SimpleContactModel *cModel = [[SimpleContactModel alloc] initWithName:contact.name phone:contact.phone andEmail:contact.email];
                            
                            [recipients addObject:cModel];
                            
                        }
                        
                    }
                    
                    
                    NSDate *date = datePicker.date;
                    NSString *msg = self.body.text;
                    NSString *subject = self.subject.text;
                    NSInteger sendOptions = settingsController.selectSendOption;
                    NSInteger preferedService = settingsController.selectPreferredService;
                    
                    
                    ScheduledModel *model = [[ScheduledModel alloc] initWithSubject:subject message:msg onDate:date withRecipients:recipients andSendOptions:sendOptions andPreferredService:preferedService andIncludeNetworks:networks saveAsTemplate:self.saveMessage];
                    
                    if(self.imagesArray.count > 0) {
                        NSMutableArray *urls = [[NSMutableArray alloc] init];
                        for(PHAsset *asset in self.imagesArray) {
                            [urls addObject:asset.localIdentifier];
                        }
                        [model setAssetURLS:urls];
                    }
                    
                    if([model persistModel]) {
                        [model scheduleNotification];
                        //force reload of the scheduled view
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setBool:true forKey:@"reload_scheduled_model"];
                        
                        NSString *txt =  [NSString stringWithFormat:@"%@!",NSLocalizedString(@"done_button", nil)];
                        [[[[iToast makeText: txt] setGravity:iToastGravityBottom] setDuration:1000] show];
                    } else {
                        [[[[iToast makeText:NSLocalizedString(@"generic_error", nil)]
                        setGravity:iToastGravityBottom] setDuration:1000] show];
                        
                    }
                    
                }
            }
        }
    } else {
        [[[[iToast makeText:NSLocalizedString(@"generic_error", nil)]
        setGravity:iToastGravityBottom] setDuration:1000] show];
    }
    
    
    
    
    [pickerBlockView removeFromSuperview];
}

//how many times failed in a row?
-(NSInteger) getNumberOfMessageFailures {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count;
    if([defaults objectForKey:FAILED_MESSAGE_COUNTER]!=nil) {
        count = [defaults integerForKey:FAILED_MESSAGE_COUNTER];
        count+=1;
    } else {
        count = 1;
    }
    [defaults setInteger:count forKey:FAILED_MESSAGE_COUNTER];
    return count;
}

//reset the key if it exists
-(void) resetMessageFailuresCounter {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //if the key exists just remove it and start from 0
    if([defaults objectForKey:FAILED_MESSAGE_COUNTER]!=nil) {
        [defaults removeObjectForKey:FAILED_MESSAGE_COUNTER];
    }
}
//if it fails 2 times in a row offer some help

-(void) popupAboutMessageFailure: (NSString *) service {
    
    Popup *popup = [[Popup alloc] initWithTitle:@"Easy Message"
                                       subTitle:NSLocalizedString(@"offer_help",nil)
                                    cancelTitle:NSLocalizedString(@"cancel",nil)
                                   successTitle:@"OK"
                                    cancelBlock:^{
                                        //Custom code after cancel button was pressed
                                        //completion(false);
                                        
                                    } successBlock:^{
                                        //Custom code after success button was pressed
                                        //completion(true);
                                        //if(self.isDeviceOnline) {
                                          PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
                                          UITabBarController *mainController = (UITabBarController*)delegate.window.rootViewController;
                                          //[[mainController tabBar] setBarTintColor:[self colorFromHex:LITE_COLOR]];
                                          [mainController setSelectedViewController: [mainController.viewControllers objectAtIndex:2]];
                                            if(settingsController!=nil) {
                                                [settingsController scrollToLastRowOfFAQSection];
                                            }
                                        //}
                                    }];
    
    [popup setBackgroundColor:[self colorFromHex:LITE_COLOR]];
    [popup setBorderColor:[UIColor blackColor]];
    [popup setTitleColor:[UIColor whiteColor]];
    [popup setSubTitleColor:[UIColor whiteColor]];
    [popup setSuccessBtnColor:[self colorFromHex:PREMIUM_COLOR]];
    [popup setSuccessTitleColor:[UIColor whiteColor]];
    [popup setCancelBtnColor:[self colorFromHex:PREMIUM_COLOR]];
    [popup setCancelTitleColor:[UIColor whiteColor]];
    [popup setDelegate: self];
    [popup setRoundedCorners:YES];
    [popup setTapBackgroundToDismiss:YES];
    
    [popup showPopup];
}

-(void) checkIfOnline {
    
    // Allocate a reachability object
    PCReachability* reach = [PCReachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(PCReachability*reach)
    {
        self.isDeviceOnline = true;
    };
    
    reach.unreachableBlock = ^(PCReachability*reach)
    {
        self.isDeviceOnline = false;
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
}
@end
