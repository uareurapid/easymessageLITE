//
//  CustomMessagesDetailController.m
//  EasyMessage
//
//  Created by PC Dreams on 04/06/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "CustomMessagesDetailController.h"

@interface CustomMessagesDetailController ()

@end

@implementation CustomMessagesDetailController
@synthesize message, textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) message:(NSString *) text {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.textView.text = text;
    self.message = text;
    return self;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
