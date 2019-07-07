//
//  Message.m
//  EasyMessage
//
//  Created by PC Dreams on 05/07/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize msg,isDefault, creationDate;

-(id) initWithText: (NSString *) text defaultMessage: (NSNumber *) def date: (NSDate *) creationDate{
    self = [super init];
    if(self) {
        
        self.msg = text;
        self.isDefault = def;
        self.creationDate = creationDate;
    }
    return self;
}
-(BOOL) isEqual:(id)object {
    if(![object isKindOfClass:Message.class]) {
        return false;
    }
    
    Message *other = (Message*) object;
    return other.msg!= nil && self.msg!=nil && [other.msg isEqualToString:self.msg] && (other.isDefault.boolValue == self.isDefault.boolValue);
    
}
@end
