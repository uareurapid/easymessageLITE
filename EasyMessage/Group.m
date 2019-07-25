//
//  Group.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/5/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize contactsList,isNative;

-(id) init {
    self = [super init];
    if(self ) {
        contactsList = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithContacts: (NSArray * ) contacts{
    self = [super init];
    if(self ) {
        contactsList = [[NSMutableArray alloc] initWithArray:contacts];
    }
    return self;
}

- (NSString *)description {
    return self.name;
}

-(BOOL) isEqual:(id)object {
    
    if(!object || ![object isKindOfClass: [self class]]) {
        return NO;
    }
    
    if(object==self) {
        return YES;
    }
    
    Group *other = (Group *) object;
    if(other != nil && other.contactsList!=nil && self.contactsList!=nil) {
        return [self.name isEqualToString: other.name] && self.contactsList.count == other.contactsList.count;
    }
    else if([other.name isEqualToString:self.name]) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isNativeGroup {
    return self.isNative;
}

@end
