//
//  Contact.h
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface Contact : NSObject // <NSCoding>



//@property (assign,nonatomic) ABRecordRef person;
@property (copy,nonatomic) NSString *email;
@property (copy,nonatomic) NSString *phone;
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSString *lastName;
@property (copy,nonatomic) NSDate *birthday;
@property (strong,nonatomic) UIImage *photo;

-(BOOL) isEqual:(id)object;

@property ABRecordRef person;//ref to the person

@property (assign,nonatomic) BOOL isNative;

-(BOOL) isNativeContact;

@end
