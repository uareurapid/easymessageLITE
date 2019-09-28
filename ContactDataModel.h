//
//  ContactDataModel.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/11/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupDataModel;

@interface ContactDataModel : NSManagedObject

@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSSet *group;
@property (nonatomic, retain) NSDate *birthday;
@property (nonatomic, retain) NSString * alternatePhones;
@property (nonatomic, retain) NSString * alternateEmails;
@end

@interface ContactDataModel (CoreDataGeneratedAccessors)
//TODO PC check if i can have a contact in several groups
- (void)addGroupObject:(GroupDataModel *)value;
- (void)removeGroupObject:(GroupDataModel *)value;
- (void)addGroup:(NSSet *)values;
- (void)removeGroup:(NSSet *)values;

@end
