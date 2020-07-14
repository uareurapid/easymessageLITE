//
//  ScheduledModel.m
//  EasyMessage
//
//  Created by PC Dreams on 25/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "ScheduledModel.h"
#import <UserNotifications/UserNotifications.h>
#import "PCAppDelegate.h"

@implementation ScheduledModel

#pragma mark - NSCoding

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (id)initWithSubject: (NSString *)subject message:(NSString *) message onDate:(NSDate *) date withRecipients: (NSMutableArray*) recipients andSendOptions:(NSInteger) sendOptions andPreferredService: (NSInteger) preferredService andIncludeNetworks:(NSMutableArray *) socialMedia saveAsTemplate: (BOOL) saveAsTemplate {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.subject = subject;
    self.message = message;
    self.when = date;
    self.preferredService = preferredService;
    self.sendOptions = sendOptions;
    
    self.assetURLS = [[NSMutableArray alloc] init];

    self.recipients = [[NSMutableArray <SimpleContactModel> alloc] init];
    if(recipients!=nil && recipients.count > 0) {
      [self.recipients addObjectsFromArray:recipients];
    }
    self.socialNetworks = [[NSMutableArray alloc] init];
    if(socialMedia!=nil && socialMedia.count > 0) {
        [self.socialNetworks addObjectsFromArray:socialMedia];
    }
    self.saveAsTemplate = saveAsTemplate;
    self.identifier = [NSString stringWithFormat: @"%f",self.when.timeIntervalSince1970];
    
    return self;
}

-(BOOL) persistModel{
    
    NSString *json = [self toJSONString];
    //NSLog(@"JSON string %@", json);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayModels = [defaults objectForKey:@"scheduled_models"];
    if(!arrayModels) {
        arrayModels = [[NSMutableArray alloc] init];
    } else {
        NSMutableArray *newOne = [[NSMutableArray alloc] initWithArray:arrayModels];
        arrayModels = newOne; //since defaults cannot mutate
    }
    //save the model identifier
    [arrayModels addObject:self.identifier];
    [defaults setObject:arrayModels forKey:@"scheduled_models"];
    
    //save this model
    [defaults setObject:json forKey:self.identifier];
    
    return true;
}

-(BOOL) decodeModel {
    NSString *json = [self toJSONString];
    NSError *err;
    
    ScheduledModel *decode = [[ScheduledModel alloc] initWithString:json error:&err];
    if (!err)
    {
        for (SimpleContactModel *contact in decode.recipients) {

            NSLog(@"Contact %@", contact.description);
        }

        for (NSString *network in decode.socialNetworks) {

            NSLog(@"Network %@", network);
        }
        
        for (NSString *asset in decode.assetURLS) {

            NSLog(@"Asset url %@", asset);
        }
        
        NSLog(@"Subject %@", decode.subject);
        
        NSLog(@"Message %@", decode.message);
        
        NSLog(@"Send options %d", decode.sendOptions);
        
        NSLog(@"Preferred service %d", decode.preferredService);
        
        NSLog(@"Save as template %d", decode.saveAsTemplate);
        
       // return true;
    } else {
        NSLog(@"FUCK %@", err.description);
    }
    
    NSLog(@"read from defaults %@", [[NSUserDefaults standardUserDefaults] objectForKey:self.identifier]);
    
    return false;
}

//call this before persist, not included in constructor because is already big
-(void) addAssetURLS:(NSMutableArray <NSString*> *)urls {
    if(self.assetURLS == nil) {
        self.assetURLS = [[NSMutableArray alloc] initWithArray:urls];
    }
    else {
       [self.assetURLS addObjectsFromArray:urls];
    }
    
}

+(ScheduledModel *) getModelFromIndentifier:(NSString *) identifier {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:identifier];
    if(json!=nil) {
        NSError *err;
        
        ScheduledModel *decode = [[ScheduledModel alloc] initWithString:json error:&err];
        if (!err)
        {
            return decode;
        }
    }
    
    return nil;

}
//removes the JSON model from defauls
+(BOOL) removeModelFromIdentifier:(NSString *) identifier {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:identifier]!=nil) {
        [defaults removeObjectForKey:identifier];
        return true;
    }
    return false;
}

-(void) scheduleNotification {
    
    
    if (@available(iOS 10.0, *)) {
        
       NSDate *futureDate = self.when;
       
       NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
       
       [calendar setTimeZone:[NSTimeZone localTimeZone]];
       
       NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitTimeZone fromDate:futureDate];
       
       UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
       objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"Schedule message!" arguments:nil];
       objNotificationContent.body = [NSString localizedUserNotificationStringForKey:self.message
                                                                           arguments:nil];
       objNotificationContent.sound = [UNNotificationSound defaultSound];
        
       objNotificationContent.userInfo =  @{@"alarmID":self.identifier,@"type":NOTIFICATION_TYPE_SCHEDULED_MESSAGE,@"identifier" : self.identifier};
       
       /// 4. update application icon badge number
       objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
       
       
       UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
       
       
       UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:self.identifier
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
    } else {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        localNotification.fireDate = self.when;
        
        NSLog(@"birthday notification fire date: %@ ",[localNotification.fireDate description]);
            
        //aniversary_of
        localNotification.alertTitle = @"Schedule message!";
        localNotification.alertBody = self.message;// [NSString stringWithFormat:@"Its the Aniversary of %@", name];

        //add to user defaults to avoid schedule it again
        NSString *alarmID = self.identifier;
            
        localNotification.userInfo = @{@"alarmID":alarmID,@"type":NOTIFICATION_TYPE_SCHEDULED_MESSAGE,@"identifier" : self.identifier};
        
        localNotification.repeatInterval=0;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    
}

+(void) cancelNotification:(NSString *) notifIdentifier{
    
    if(notifIdentifier!=nil) {
        if (@available(iOS 10.0, *)) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removePendingNotificationRequestsWithIdentifiers: [[NSArray alloc] initWithObjects:notifIdentifier, nil]];
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray <UILocalNotification*> *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
                for(UILocalNotification *notif in notifications) {
                    if(notif!=nil && notif.userInfo!=nil) {
                        NSString *identifier = [[notif userInfo] objectForKey:@"alarmID"];
                        if(identifier!=nil && [identifier isEqualToString:notifIdentifier]) {
                            [[UIApplication sharedApplication] cancelLocalNotification:notif];
                        }
                    }
                }
            });
            
        }
        
        
    }
 
}

-(NSString *) getReadableDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Convert to new Date Format
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDate = [dateFormatter stringFromDate:self.when];
    return newDate;
}


//remove the model given the model identifier
+(BOOL) removeModel:(NSString *) modelIdentifier {
    
    if(modelIdentifier!=nil) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arrayModels = [defaults objectForKey:@"scheduled_models"];
        NSString *toRemove = nil;
        if(arrayModels !=nil && arrayModels.count > 0) {
            
            //need to have a working array that i can mutate
            NSMutableArray *workBase = [[NSMutableArray alloc] initWithArray:arrayModels];
            
            for(NSString *identif in arrayModels) {
                if([identif isEqualToString: modelIdentifier]) {
                    toRemove = identif;
                    break;
                }
            }
            
            if(toRemove!=nil) {
                //update the array of models
                [workBase removeObject:toRemove];
                //remove the identifier from the array of model identifiers
                [defaults setObject:workBase forKey:@"scheduled_models"];
                
                //remove the json for this identifier too
                [ScheduledModel removeModelFromIdentifier:toRemove];
                
                //remove the notification
                [ScheduledModel cancelNotification:toRemove];
                
                return true;

            }
        }
    }
    return false;
    
}

@end

