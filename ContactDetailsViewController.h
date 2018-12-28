//
//  ContactDetailsViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 16/12/2018.
//  Copyright © 2018 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactDetailsViewController : UITableViewController

@property (assign, nonatomic) UIViewController *root;
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow;


@end

NS_ASSUME_NONNULL_END
