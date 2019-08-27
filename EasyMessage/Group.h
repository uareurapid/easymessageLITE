//
//  Group.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/5/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Group : Contact
-(id) initWithContacts: (NSArray * ) contacts;

@property (strong,nonatomic) NSMutableArray *contactsList;
@property (assign,nonatomic) BOOL isNative;
-(BOOL)isNativeGroup;
@end
