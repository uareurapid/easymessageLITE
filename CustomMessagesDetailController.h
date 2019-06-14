//
//  CustomMessagesDetailController.h
//  EasyMessage
//
//  Created by PC Dreams on 04/06/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomMessagesDetailController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *message;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) message:(NSString *) text;

@end

NS_ASSUME_NONNULL_END
