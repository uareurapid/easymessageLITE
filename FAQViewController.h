//
//  FAQViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 08/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FAQViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *faqView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

NS_ASSUME_NONNULL_END
