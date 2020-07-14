//
//  PCAppDelegate.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "PCAppDelegate.h"

#import "PCViewController.h"
#import "SettingsViewController.h"
#import "ScheduledViewController.h"
#import "SelectRecipientsViewController.h"
#import "CustomMessagesController.h"
#import "EasyMessageIAPHelper.h"
#import "IAPMasterViewController.h"
//  AppDelegate.m
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Appirater.h>

#import <Batch/Batch.h>


@implementation PCAppDelegate

@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //CHECK WICH VIEWS TO LOAD
    //self.viewController = [[ViewController alloc] initWithNibName:IS_IPAD?@"ViewController~iPad":@"ViewController" bundle:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![defaults objectForKey:SETTINGS_PREF_ORDER_BY_KEY]) {
        [defaults setObject:OPTION_ORDER_BY_FIRSTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY];
    }
    if(![defaults objectForKey:SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS]) {
        [defaults setObject:OPTION_ORDER_BY_FIRSTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS];
    }
    
    if(![defaults objectForKey:SETTINGS_FILTER_OPTIONS]) {
        [defaults setObject:OPTION_FILTER_SHOW_ALL_KEY forKey:SETTINGS_FILTER_OPTIONS];
    }
    if(![defaults objectForKey:SETTINGS_FILTER_PREVIOUS_OPTIONS]) {
        [defaults setObject:OPTION_FILTER_SHOW_ALL_KEY forKey:SETTINGS_FILTER_PREVIOUS_OPTIONS];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PCViewController alloc] initWithNibName:@"PCViewController" bundle:nil];
    
    self.settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    self.viewController.settingsController = self.settingsController;
    
    //scheduled models
    self.scheduleModelsController = [[ScheduledViewController alloc] initWithNibName:@"ScheduledViewController" bundle:nil];
    
    
    self.recipientsController = [[SelectRecipientsViewController alloc] initWithNibName:@"SelectRecipientsViewController" bundle:nil rootViewController:self.viewController];
    
    self.customMessagesController = [[CustomMessagesController alloc] initWithNibName:@"CustomMessagesController" bundle:nil rootViewController:self.viewController ];
    
    self.inAppPurchasesController = [[IAPMasterViewController alloc] initWithNibName:@"IAPMasterViewController" bundle:nil ];
    
    self.settingsController.purchasesController = self.inAppPurchasesController;
    
    self.viewController.recipientsController = self.recipientsController;
    
    self.viewController.customMessagesController = self.customMessagesController;
    
    UINavigationController *easyMessageController = [[UINavigationController alloc] init];
    [easyMessageController setViewControllers: [[NSArray alloc]  initWithObjects:self.viewController, nil]];
    
    easyMessageController.navigationBar.barTintColor = [self colorFromHex:0xfb922b];
    
    UINavigationController *navControllerSettings = [[UINavigationController alloc] init];
    [navControllerSettings setViewControllers: [[NSArray alloc]  initWithObjects:self.settingsController, nil]];
    
    navControllerSettings.navigationBar.barTintColor = [self colorFromHex:0xfb922b];
    
    UINavigationController *navControllerRecipients = [[UINavigationController alloc] init];
    [navControllerRecipients setViewControllers: [[NSArray alloc]  initWithObjects:self.recipientsController, nil]];
    
    navControllerRecipients.navigationBar.barTintColor = [self colorFromHex:0xfb922b];
    
    UINavigationController *customMessagesControllerNav = [[UINavigationController alloc] init];
    [customMessagesControllerNav setViewControllers: [[NSArray alloc]  initWithObjects:self.customMessagesController, nil]];
    
    customMessagesControllerNav.navigationBar.barTintColor = [self colorFromHex:0xfb922b];
   
    UINavigationController *scheduledControllerSettings = [[UINavigationController alloc] init];
    [scheduledControllerSettings setViewControllers: [[NSArray alloc]  initWithObjects:self.scheduleModelsController, nil]];
    
    scheduledControllerSettings.navigationBar.barTintColor = [self colorFromHex:0xfb922b];
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    [tabController setViewControllers: [NSArray arrayWithObjects:easyMessageController,navControllerRecipients,navControllerSettings,customMessagesControllerNav, scheduledControllerSettings, nil] ];
   
    //[tabController setSelectedIndex:0];
    
    [EasyMessageIAPHelper sharedInstance];
    
    self.window.rootViewController = tabController;//navController;
    [self.window makeKeyAndVisible];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    // Add any custom logic here.
    [[Twitter sharedInstance] startWithConsumerKey:@"aDp4mgi28vaaLhpRztoX53c16" consumerSecret:@"JrVYSaJPbAZsfELXtladWxpIunu3aLYxfBBrjcoTJrY8OQkG0R"];
    
    [Appirater setAppId:@"1448046358"];
    [Appirater setDaysUntilPrompt:2];
    [Appirater setUsesUntilPrompt:1];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater appLaunched:YES];
    [Appirater setDebug:NO];
    
    [self registerForRemoteNotifications];
    
    // Start Batch.
    // TODO : switch to live api key before store release
    //[Batch startWithAPIKey:@"DEV5C6281062D7458A1A5011A11309"]; // dev
    [Batch startWithAPIKey:@"5C6281062D31F00273C12635993BA6"]; // live
    
    // Ask for the permission to display notifications
    // The push token will automatically be fetched by the SDK
    [BatchPush requestNotificationAuthorization];
    
    // Alternatively, you can call requestNotificationAuthorization later
    // But, you should always refresh your token on each application start
    // This will make sure that even if your user's token changes, you still get notifications
    // [BatchPush refreshToken];
    
    // Launched from push notification ??
    if (launchOptions != nil && [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]!=nil) {
        
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        
        if(notification!=nil && notification.userInfo!=nil) {
            
            //Get notification type
                      
                   NSString *notificationType = [notification.userInfo valueForKey:@"type"];
                   if(notificationType!=nil && [notificationType isEqualToString:NOTIFICATION_TYPE_SCHEDULED_MESSAGE])
                   {

                      NSString *notificationIdentifier = [notification.userInfo valueForKey:@"identifier"];
                       //NOTE WE CANNOT DO THIS HERE YET BECAUSE THE CONTACTS LIST IS NOT LOADED YET
                       //SAVE THE IDENTIFIER AND DO IT AS SOON AS WE LOAD THE CONTACTS, THEN CLEAR THE DICTIONARY KEY
                      /*
                      if(notificationIdentifier!=nil) {
                        //get the data and prefill stuff
                        [self.viewController checkForPrefilledScheduledMessage:notificationIdentifier];
                        //we do not need it anymore, remove it
                        [self.scheduleModelsController removeModel:notificationIdentifier];
                      }*/
                          
                      NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
                      [defaults setObject:notificationIdentifier forKey:APP_OPENED_FROM_PUSH];
                          
                  }
        }
        else {
            //no notif present but key exists? delete it
            if([defaults objectForKey:APP_OPENED_FROM_PUSH]!=nil) {
                [defaults removeObjectForKey:APP_OPENED_FROM_PUSH];
            }
       }

    } else {
        //if not but key exists, just remove it too
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if([defaults objectForKey:APP_OPENED_FROM_PUSH]!=nil) {
            [defaults removeObjectForKey:APP_OPENED_FROM_PUSH];
        }
    }
    
    return YES;
}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
    else {
        // Code for old versions
        if ([[UIApplication sharedApplication]  respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            // for iOS 8
            [[UIApplication sharedApplication]  registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSString * deviceTokenString = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""]   stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"the generated device token string is : %@",deviceTokenString);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //[super application:application didReceiveLocalNotification:notification]; // In most case, you don't need this line
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //Get notification type
    NSString *notificationType = [notification.userInfo valueForKey:@"type"];
    //notificationType as: message, friend Request, video call, Audio call.
    //NSLog(@"notification type %@",notificationType);
    
    if ([notificationType isEqualToString:NOTIFICATION_TYPE_BIRTHDAY]) {
        
        //NSLog(@"prefill load message aniversary...");
        
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        
        NSString *day = [notification.userInfo valueForKey:@"day"];
        NSString *month = [notification.userInfo valueForKey:@"month"];
        //name of the contact
        //NSString *name = [notification.userInfo valueForKey:@"name"];
        
        [defaults setObject:NSLocalizedString(@"custom_msg_birthday",@"Happy Birthday") forKey:@"prefillMessage"];
        [defaults setObject:@"birthday" forKey:@"prefillMessageType"];
        [defaults setObject:month forKey:@"month"];
        [defaults setObject:day forKey:@"day"];
        
        [defaults synchronize];
        
        [self.viewController checkForPrefilledMessage];
    } else if ([notificationType isEqualToString:NOTIFICATION_TYPE_SCHEDULED_MESSAGE]) {
        
        //NSLog(@"prefill scheduled message..");
        
        //NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        
        NSString *notificationIdentifier = [notification.userInfo valueForKey:@"identifier"];
        
        if(notificationIdentifier!=nil) {
          //get the data and prefill stuff
          [self.viewController checkForPrefilledScheduledMessage:notificationIdentifier];
          //we do not need it anymore, remove it
          [self.scheduleModelsController removeModel:notificationIdentifier];
        }
        
        
    }
}

//duplicated in PCViewController
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
    
    if([type isEqualToString:NOTIFICATION_TYPE_BIRTHDAY]) {
        
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
                                       @"type":type,
                                       @"day" : [NSString stringWithFormat:@"%ld", (long)day ],
                                       @"month" : [NSString stringWithFormat:@"%ld", (long)month ],
                                       @"name" : name
                                       };
        localNotification.repeatInterval=0; //[NSCalendar currentCalendar];
    }//else do other cases on other releases
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
    });
}

/**
 TO add a facebook login button
 // Add this to the header of your file, e.g. in ViewController.m
 // after #import "ViewController.h"
 #import <FBSDKCoreKit/FBSDKCoreKit.h>
 #import <FBSDKLoginKit/FBSDKLoginKit.h>
 
 // Add this to the body
 @implementation ViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
 // Optional: Place the button in the center of your view.
 loginButton.center = self.view.center;
 [self.view addSubview:loginButton];
 }
 
 @end
 */

#pragma CORE DATA instance methods

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store
 coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in
 application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self loadApplicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"easymessage.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                  initWithManagedObjectModel:[self managedObjectModel]];
    
    //tell core data that we want to support lightweight migrations
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};

    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should
         not use this function in a shipping application, although it may be useful during
         development. If it is not possible to recover from the error, display an alert panel that
         instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object
         model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        //TODO instruct the user to quit the application by pressing the Home button.
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:NSLocalizedString(@"persistence_store_error",@"persistence_store_error")
                                                        delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        //abort();
    }
    
    return persistentStoreCoordinator;
}

//load the application documents path
-(NSString*) loadApplicationDocumentsDirectory {
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return documentPath;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}*/

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// Objective C
#pragma TwitterDelegate + FacebookDelegate
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    //twitter
    BOOL handled = [[Twitter sharedInstance] application:app openURL:url options:options];
    //facebook
    BOOL handledFB = [[FBSDKApplicationDelegate sharedInstance] application:app
                                                                    openURL:url
                                                          sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                 annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    
    // Add any custom logic here.
    return handled || handledFB;
}

- (UIColor *)colorFromHex:(unsigned long)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:1.0];
}

//[delegate colorFromHex:0x1c1c1e];
-(UIColor *) defaultTableColor: (BOOL) isDarkMode {
    //return [UIColor systemGray6Color];
    if(isDarkMode) {
        return [UIColor colorWithRed:28/255.0f green:28/255.0f blue:30/255.0f alpha:1.0f];//default color
    }
    return [UIColor colorWithRed:242/255.0f green:242/255.0f blue:247/255.0f alpha:1.0f];
    
    //light - [UIColor colorWithRed:242/255.0f green:242/255.0f blue:247/255.0f alpha:1.0f];
    //dark [UIColor colorWithRed:28/255.0f green:28/255.0f blue:30/255.0f alpha:1.0f];
    //https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/#system-colors
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
                                
                                        //REALLY BAD CODE AHEAD BUT DOES THE JOB FOR NOW!!
                                        UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
                                        if(tabController!=nil) {
                                             UINavigationController *mainViewController = (UINavigationController*)[tabController.viewControllers objectAtIndex:0];
                                            if(mainViewController!=nil) {
                                                PCViewController *pc = [mainViewController.viewControllers objectAtIndex:0];
                                                if(pc!=nil) {
                                                    [pc buyProductWithidentifier:PRODUCT_PREMIUM_UPGRADE];
                                                }
                                               
                                            }
                                            
                                        }
                                        
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

@end
