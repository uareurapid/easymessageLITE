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
#import "SelectRecipientsViewController.h"
#import "CustomMessagesController.h"
#import "EasyMessageIAPHelper.h"
#import "IAPMasterViewController.h"
//  AppDelegate.m
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <TwitterKit/TwitterKit.h>
#import <Appirater.h>




@implementation PCAppDelegate

@synthesize managedObjectContext,managedObjectModel,persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //CHECK WICH VIEWS TO LOAD
    //self.viewController = [[ViewController alloc] initWithNibName:IS_IPAD?@"ViewController~iPad":@"ViewController" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[PCViewController alloc] initWithNibName:@"PCViewController" bundle:nil];
    
    self.settingsController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    self.viewController.settingsController = self.settingsController;
    
    self.recipientsController = [[SelectRecipientsViewController alloc] initWithNibName:@"SelectRecipientsViewController" bundle:nil rootViewController:self.viewController];
    
    self.customMessagesController = [[CustomMessagesController alloc] initWithNibName:@"CustomMessagesController" bundle:nil rootViewController:self.viewController ];
    
    self.inAppPurchasesController = [[IAPMasterViewController alloc] initWithNibName:@"IAPMasterViewController" bundle:nil ];
    
    
    self.viewController.recipientsController = self.recipientsController;
    
    UINavigationController *easyMessageController = [[UINavigationController alloc] init];
    [easyMessageController setViewControllers: [[NSArray alloc]  initWithObjects:self.viewController, nil]];
    
    UINavigationController *navControllerSettings = [[UINavigationController alloc] init];
    [navControllerSettings setViewControllers: [[NSArray alloc]  initWithObjects:self.settingsController, nil]];
    
    UINavigationController *navControllerRecipients = [[UINavigationController alloc] init];
    [navControllerRecipients setViewControllers: [[NSArray alloc]  initWithObjects:self.recipientsController, nil]];
    
    UINavigationController *customMessagesControllerNav = [[UINavigationController alloc] init];
    [customMessagesControllerNav setViewControllers: [[NSArray alloc]  initWithObjects:self.customMessagesController, nil]];
    
   // UINavigationController *inAppPurchasesControllerNav = [[UINavigationController alloc] init];
   // [inAppPurchasesControllerNav setViewControllers: [[NSArray alloc]  initWithObjects:self.inAppPurchasesController, nil]];
    
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    [tabController setViewControllers: [NSArray arrayWithObjects:easyMessageController,navControllerRecipients,navControllerSettings,customMessagesControllerNav, /*inAppPurchasesControllerNav*/ nil] ];
   
    //[tabController setSelectedIndex:0];
    
    [EasyMessageIAPHelper sharedInstance];
    
    self.window.rootViewController = tabController;//navController;
    [self.window makeKeyAndVisible];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    // Add any custom logic here.
    [[Twitter sharedInstance] startWithConsumerKey:@"SfrtbFrUq0IjXVaCHi8784rUN" consumerSecret:@"uMGMGTXzUaJFifZgdpel7Z5hA5MMovDn6vCKxQbvWDk7MOJJGC"];
    
    [Appirater setAppId:@"668776671"];
    [Appirater setDaysUntilPrompt:0];
    [Appirater setUsesUntilPrompt:1];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater appLaunched:YES];
    [Appirater setDebug:NO];
    
    [self registerForRemoteNotifications];
    
    return YES;
}

- (void)registerForRemoteNotifications {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        // Code for old versions
        if ([[UIApplication sharedApplication]  respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
        {
            // for iOS 8
            [[UIApplication sharedApplication]  registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication]  registerForRemoteNotifications];
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
    NSString *notificationType = [notification.userInfo valueForKey:@"Type"];
    //notificationType as: message, friend Request, video call, Audio call.
    NSLog(@"notification type %@",notificationType);
    
    if ([notificationType isEqualToString:@"birthday"]) {
        
        NSLog(@"prefill load message aniversary...");
        
        NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
        
        NSString *day = [notification.userInfo valueForKey:@"day"];
        NSString *month = [notification.userInfo valueForKey:@"month"];
        //name of the contact
        NSString *name = [notification.userInfo valueForKey:@"name"];
        
        [defaults setObject:NSLocalizedString(@"custom_msg_birthday",@"Happy Birthday") forKey:@"prefillMessage"];
        [defaults setObject:@"birthday" forKey:@"prefillMessageType"];
        [defaults setObject:month forKey:@"month"];
        [defaults setObject:day forKey:@"day"];
        
        [defaults synchronize];
        
        [self.viewController checkForPrefilledMessage];
    }
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
        abort();
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
// Objective C
#pragma TwitterDelegate
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}

@end
