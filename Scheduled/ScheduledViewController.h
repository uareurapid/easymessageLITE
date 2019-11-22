//
//  ScheduledViewController.h
//  EasyMessage
//
//  Created by PC Dreams on 25/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduledModel.h"
#import "ScheduledModelDetailsViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface ScheduledViewController : UITableViewController

@property(strong, nonatomic) NSMutableArray *models;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@property (strong, nonatomic) ScheduledModelDetailsViewController *detailsController;
-(void) removeModel:(NSString *) modelIdentifier; //called also from delegate

@end

NS_ASSUME_NONNULL_END
