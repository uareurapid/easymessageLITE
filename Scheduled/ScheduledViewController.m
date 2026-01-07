//
//  ScheduledViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 25/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "PCAppDelegate.h"
#import "ScheduledViewController.h"

@interface ScheduledViewController ()

@end

@implementation ScheduledViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ];
    if(self) {
        self.tabBarItem.image = [UIImage imageNamed:@"clock30"];
        self.title = @"Scheduled";
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.models = [[NSMutableArray alloc] init];
    [self readModels];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) readModels {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayModels = [defaults objectForKey:@"scheduled_models"];
    if(arrayModels !=nil) {
        for(NSString *model in arrayModels) {
            [self.models addObject:model];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated {
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    self.navigationController.navigationBar.backgroundColor =  [delegate colorFromHex:0xfb922b];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:@"reload_scheduled_model"]) {
        [self.models removeAllObjects];
        [self readModels];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.tableView reloadData];
        });
        
        [defaults setBool:false forKey:@"reload_scheduled_model"];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.models.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [NSString stringWithFormat:@"%@: %lu",NSLocalizedString(@"scheduled_messages",nil),(unsigned long)self.models.count ]; //TODO
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"scheduledCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    
    NSString *identifier = [self.models objectAtIndex:indexPath.row];
    if(identifier!=nil) {
        ScheduledModel *model = [ScheduledModel getModelFromIndentifier:identifier];
        if(model!=nil) {
            cell.textLabel.text = [model getReadableDate];
        } else {
            cell.textLabel.text = identifier;
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if(indexPath.row < self.models.count) {
            
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                                 message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                                delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
             alert.tag = indexPath.row;
             [alert show];
        }
        
       
    }
}


#pragma uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1 && alertView.tag < self.models.count) {
        // OK
        NSString *identifier = [self.models objectAtIndex:alertView.tag];
        [self removeModel:identifier];
        [self.models removeObject:identifier];
         dispatch_async(dispatch_get_main_queue(), ^(){
             [self.tableView reloadData];
         });
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
//remove the model given the model identifier
-(void) removeModel:(NSString *) modelIdentifier {
    
    if(modelIdentifier!=nil) {
        
        if([ScheduledModel removeModel:modelIdentifier]) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //next time that the view appears it will reload
            [defaults setBool:true forKey:@"reload_scheduled_model"];
        }
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    if(indexPath.row < self.models.count) {
        
        NSString *identifier = [self.models objectAtIndex:indexPath.row];
        ScheduledModel *model = [ScheduledModel getModelFromIndentifier:identifier];
        if(model!=nil) {
            if(self.detailsController==nil) {
                 self.detailsController = [[ScheduledModelDetailsViewController alloc] initWithNibName:@"ScheduledModelDetailsViewController" bundle:nil andModel:model];
            }
            else {
                 self.detailsController.model = model;
                [self.detailsController.tableView reloadData];
            }
        }
        
         
         // Pass the selected object to the new view controller.
         
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        // Push the view controller.
        [self.navigationController pushViewController:self.detailsController animated:YES];
    }
    
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
