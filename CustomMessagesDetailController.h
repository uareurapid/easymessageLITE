//
//  CustomMessagesDetailController.h
//  EasyMessage
//
//  Created by PC Dreams on 04/06/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDataModel.h"
#import "CustomMessagesController.h"
#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface CustomMessagesDetailController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) MessageDataModel *model;
@property (assign, nonatomic) CustomMessagesController *messagesController;

- (IBAction)saveClicked:(id)sender;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) parent message:(Message *) message;

@end

NS_ASSUME_NONNULL_END

