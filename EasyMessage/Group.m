//
//  Group.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/5/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize contactsList;

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


@end
