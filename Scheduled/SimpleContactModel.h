//
//  SimpleContactModel.h
//  EasyMessage
//
//  Created by PC Dreams on 26/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface SimpleContactModel : JSONModel

@property NSString *name;
@property NSString *phone;
@property NSString *email;

-(id) initWithName: (NSString *) name phone:(NSString *) phone andEmail: (NSString *) email;

@end

NS_ASSUME_NONNULL_END
