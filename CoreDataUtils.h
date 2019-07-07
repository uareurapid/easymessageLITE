//
//  CoreDataUtils.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupDataModel.h"
#import "ContactDataModel.h"
#import "MessageDataModel.h"
#import "PCAppDelegate.h"
#import "Contact.h"
#import "Message.h"

@interface CoreDataUtils : NSObject

+ (NSMutableArray *)fetchGroupRecordsFromDatabase;
+ (NSMutableArray *)fetchMessageRecordsFromDatabase;
+ (NSMutableArray *)fetchContactModelRecordsFromDatabase;
+(ContactDataModel *) fetchContactDataModelByName: (NSString *) message;
+(NSMutableArray *) fetchAllContactsDataModelByName: (NSString *) contactName;
+(GroupDataModel *) fetchGroupDataModelByName: (NSString *) groupName;
+(BOOL) deleteGroupDataModelByName: (NSString *) groupName;
+(BOOL) deleteContactDataModelByName: (Contact *) contact;
+(BOOL) deleteMessageDataModelByMsg: (Message *) msg;
+(BOOL) deleteContactsList;
+(BOOL) deleteGroupsList;
@end
