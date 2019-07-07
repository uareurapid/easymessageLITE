//
//  Message.h
//  EasyMessage
//
//  Created by PC Dreams on 05/07/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject

@property (strong,nonatomic) NSString *msg;
@property (strong,nonatomic) NSDate *creationDate;
@property (assign,nonatomic) NSNumber *isDefault;

-(id) initWithText: (NSString *) text defaultMessage: (NSNumber *) def date: (NSDate *) creationDate;
@end

NS_ASSUME_NONNULL_END
