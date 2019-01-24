//
//  EasyMessageIAPHelper.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/7/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "EasyMessageIAPHelper.h"

@interface EasyMessageIAPHelper ()

@end

@implementation EasyMessageIAPHelper

//The sharedInstance method implements the Singleton pattern in Objective-C to return a single,
//global instance of the RageIAPHelper class. It calls the superclasses initializer to pass in all
//the product identifiers that you created with iTunes Connect.

+ (EasyMessageIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static EasyMessageIAPHelper * sharedInstance;
    
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      //PRODUCT_COMMON_MESSAGES,
                                      //PRODUCT_GROUP_SUPPORT,
                                      //PRODUCT_ADS_FREE,
                                      PRODUCT_PREMIUM_UPGRADE,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end
