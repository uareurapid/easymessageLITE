//
//  MessageDataModel.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/13/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MessageDataModel : NSManagedObject

@property (nonatomic, retain) NSString *msg;
@property (strong,nonatomic) NSDate *creationDate;
@property (nonatomic, retain) NSNumber *isDefault;

@end
