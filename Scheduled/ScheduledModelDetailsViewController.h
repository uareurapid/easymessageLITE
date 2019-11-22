//
//  ScheduledModelDetailsViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 27/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScheduledModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduledModelDetailsViewController : UITableViewController<UIAlertViewDelegate>

@property (strong, nonatomic) ScheduledModel *model;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel: (ScheduledModel *) model;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@end

NS_ASSUME_NONNULL_END
