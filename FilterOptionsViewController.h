//
//  FilterOptionsViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 12/03/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Popup.h"
#import "PCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterOptionsViewController : UITableViewController<PopupDelegate>

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;


@end

NS_ASSUME_NONNULL_END
