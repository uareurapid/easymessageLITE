//
//  SimpleContactModel.m
//  EasyMessage
//
//  Created by PC Dreams on 26/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "SimpleContactModel.h"

@implementation SimpleContactModel


-(id) initWithName: (NSString *) name phone:(NSString *) phone andEmail: (NSString *) email {
    
    self = [super init];
    
    self.name = name != nil ? name : @"NA";
    self.email = email !=nil ? email : @"NA";
    self.phone = phone!=nil ? phone : @"NA";
    return self;
}

@end
