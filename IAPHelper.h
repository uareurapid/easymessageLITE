//
//  IAPHelper.h
//  EasyMessage
//
//  Created by Paulo Cristo on 9/7/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

#define PRODUCT_COMMON_MESSAGES @"com.pt.pcristo.common.messages"
#define PRODUCT_GROUP_SUPPORT @"com.pt.pcristo.groups.support"
#define PRODUCT_ADS_FREE @"com.pt.pcristo.ads.free"
#define PRODUCT_PREMIUM_UPGRADE @"easy_message_premium_upgrade"

// Add two new method declarations
- (void)buyProduct:(SKProduct *)product;
//buy the product
- (BOOL)productPurchased:(NSString *)productIdentifier;
//restore purchases on other devices
- (void)restoreCompletedTransactions;
@end
