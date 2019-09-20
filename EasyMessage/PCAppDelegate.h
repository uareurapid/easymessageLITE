//
//  PCAppDelegate.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/18/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import <UserNotifications/UserNotifications.h>

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending) 

@class PCViewController;
@class SettingsViewController;
@class SelectRecipientsViewController;
@class CustomMessagesController;
@class IAPMasterViewController;

@interface PCAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

-(void) scheduleNotification: (NSString *) type nameOfContact: name month: (NSInteger) month day: (NSInteger) day fireDelayInSeconds: (NSTimeInterval) delay;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) PCViewController *viewController;
@property (strong, nonatomic) SettingsViewController *settingsController;
@property (strong, nonatomic) SelectRecipientsViewController *recipientsController;
@property (strong, nonatomic) CustomMessagesController *customMessagesController;
@property (strong, nonatomic) IAPMasterViewController *inAppPurchasesController;

//CORE DATA
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (UIColor *)colorFromHex:(unsigned long)hex;
-(UIColor *) defaultTableColor: (BOOL) isDarkMode;

@end
