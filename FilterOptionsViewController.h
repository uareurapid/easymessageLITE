//
//  FilterOptionsViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 12/03/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterOptionsViewController : UITableViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous;
@property (strong,nonatomic) UIViewController *previousController;

@end

NS_ASSUME_NONNULL_END
