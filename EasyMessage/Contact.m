//
//  Contact.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "Contact.h"

@implementation Contact

@synthesize phone,email,name,lastName,photo,person,birthday,isFavorite,alternatePhones,alternateEmails;

//we just consider the name
-(BOOL) isEqual:(id)object {
    if(!object || ![object isKindOfClass: [self class]]) {
        return NO;
    }
   
    if(object==self) {
        return YES;
    }
    
    Contact *otherContact = (Contact *)object;
    
    if([self isNameEqual:otherContact]) {
        
        //same name, what about last name?
        if([self isLastNameEqual:otherContact]) {
            //same last name
            //what about email?
            if([self isEmailEqual:otherContact]) {
                //same email
                //what about phone?
                if([self isPhoneEqual:otherContact]) {
                    return YES;
                }//phone is different
                else {
                    return NO;
                }
            }//email is different
            else {
                return NO;
            }
        }//last name is different
        else {
            return NO;
        }
    }
    
    if([self.description isEqualToString:otherContact.description]) {
        return YES;
    }
    
    //if one has null name, they are not the same for sure
    
    return NO;
}

#pragma auxiliar comparing methods

-(BOOL) isLastNameEqual: (Contact *) otherContact {
    if(lastName!=nil && otherContact.lastName!=nil) {
        if([lastName isEqualToString:otherContact.lastName]) {
            return YES;
        }
    } else if(lastName == nil && otherContact.lastName == nil) {
        return YES;
    }
    return NO;
}

-(BOOL) isNameEqual: (Contact *) otherContact {
    if(name!=nil && otherContact.name!=nil) {
        
        if([name isEqualToString:otherContact.name]) {
            //ok name is equal, check lastname
            return YES;
        }
    } else if(name == nil && otherContact.name == nil) {
        return YES;
    }
    return NO;
}

-(BOOL) isPhoneEqual: (Contact *) otherContact {
    if(phone!=nil && otherContact.phone!=nil) {
        if([phone isEqualToString:otherContact.phone]) {
            return YES;
        }
    } else if(phone == nil && otherContact.phone == nil) {
        return YES;
    }
    
    
    return NO;
}

-(BOOL) isEmailEqual: (Contact *) otherContact {
    
    if(email!=nil && otherContact.email!=nil) {
        if([email isEqualToString:otherContact.email]) {
            return YES;
        }
    } else if(email == nil && otherContact.email == nil) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isNativeContact {
    return person!=nil || self.isNative == true;
}

-(NSString *) description {
    
    NSString *name = self.name;
    NSString *lastname = self.lastName != nil ? self.lastName : @"";
    NSString *phone = self.phone !=nil ? self.phone : @"";
    NSString *email = self.email !=nil ? self.email: @"";
    
    return [NSString stringWithFormat:@"%@ %@ %@ %@", name, lastname, phone, email];
    
}
/*
-(Contact*) copyWithZone {
    Contact *newOne = [[Contact alloc] init];
    newOne.name = self.name;
    newOne.lastName = self.lastName;
    newOne.phone = self.phone;
    newOne.email = self.email;
    newOne.photo = self.photo;
    return newOne;
}*/

/*
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
     [aCoder encodeObject:self.name forKey:@"name"];
     [aCoder encodeObject:self.lastName forKey:@"lastaName"];
     [aCoder encodeObject:self.phone forKey:@"phone"];
     [aCoder encodeObject:self.email forKey:@"email"];
     [aCoder encodeObject:self.phone forKey:@"name"];
     [aCoder encodeObject:self.name forKey:@"name"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    <#code#>
}*/

-(BOOL) hasAlternateEmails {
    return (self.alternateEmails!=nil && self.alternateEmails.count > 0);
}
-(BOOL) hasAlternatePhones {
    return (self.alternatePhones!=nil && self.alternatePhones.count > 0);
}

-(BOOL) hasAlternatePhonesAndEmails {
    return [self hasAlternateEmails] && [self hasAlternatePhones];
}
@end
