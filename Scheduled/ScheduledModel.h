//
//  ScheduledModel.h
//  EasyMessage
//
//  Created by PC Dreams on 25/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "SimpleContactModel.h"

NS_ASSUME_NONNULL_BEGIN

//#define OPTION_ALWAYS_SEND_BOTH_ID      0
//#define OPTION_SEND_EMAIL_ONLY_ID       1
//#define OPTION_SEND_SMS_ONLY_ID         2
//#define OPTION_INCLUDE_SOCIAL_SERVICES_ID       3

//#define OPTION_PREF_SERVICE_ALL_ID    0
//#define OPTION_PREF_SERVICE_EMAIL_ID  1
//#define OPTION_PREF_SERVICE_SMS_ID    2

@protocol SimpleContactModel;

@interface ScheduledModel : JSONModel

@property NSString *subject;
@property NSString *message;
@property NSUInteger sendOptions; //0 send both, 1 email only, 2 sms only
@property NSUInteger preferredService; //0 send both, 1 email only, 2 sms only
@property NSMutableArray<SimpleContactModel> *recipients;
@property NSMutableArray<NSString*> *socialNetworks;
@property NSMutableArray<NSString*> *assetURLS;//for the images
@property NSDate *when;
@property NSString *identifier;
@property BOOL saveAsTemplate;


- (id)initWithSubject: (NSString *)subject message:(NSString *) message onDate:(NSDate *) date withRecipients: (NSMutableArray*) recipients andSendOptions:(NSInteger) sendOptions andPreferredService: (NSInteger) preferredService andIncludeNetworks:(NSMutableArray *) socialMedia saveAsTemplate: (BOOL) saveAsTemplate;

-(BOOL) persistModel;
-(BOOL) decodeModel;
-(void) scheduleNotification;
-(NSString *) getReadableDate;
-(void) addAssetURLS:(NSMutableArray <NSString*> *)urls;
+(ScheduledModel *) getModelFromIndentifier:(NSString *) identifier;
+(void) cancelNotification:(NSString *) notifIdentifier;
+(BOOL) removeModelFromIdentifier:(NSString *) identifier;
+(BOOL) removeModel:(NSString *) modelIdentifier;
@end

NS_ASSUME_NONNULL_END
