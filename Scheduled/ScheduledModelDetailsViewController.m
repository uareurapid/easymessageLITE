//
//  ScheduledModelDetailsViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 27/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "ScheduledModelDetailsViewController.h"
#import "FTPopOverMenu.h"
#import "PCAppDelegate.h"

@interface ScheduledModelDetailsViewController ()

@end

@implementation ScheduledModelDetailsViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andModel: (ScheduledModel *) model {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.model = model;
    UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
    
    optionsButton.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = optionsButton;
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)optionsClicked:(id)sender event:(UIEvent *)event{
    [self showMenu:sender withEvent: event];
}

- (void) showMenu:(id)sender withEvent: (UIEvent *)event
{
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor whiteColor];
    configuration.menuWidth = 200;
    
    PCAppDelegate *delegate = (PCAppDelegate *) [[UIApplication sharedApplication] delegate];
    configuration.separatorColor = [delegate colorFromHex:0x4f6781];
    
    [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"delete", nil)]
       imageArray:@[@"delete"]
    configuration:configuration
        doneBlock:^(NSInteger selectedIndex) {
            if(selectedIndex == 0) {
                //todo delete
               UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                                message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                               delegate:self cancelButtonTitle: NSLocalizedString(@"cancel",nil) otherButtonTitles:@"OK", nil];
               [alert show];
            }
        } dismissBlock:^{
            
        }];
}
#pragma uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1 && self.model!=nil) {
        // OK
        NSString *identifier = self.model.identifier;
        [self removeModel:identifier];
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
//TODO put this duplicate code on ScheduleModel as public method
-(void) removeModel:(NSString *) modelIdentifier {
    
    if(modelIdentifier!=nil) {
        
        if([ScheduledModel removeModel:modelIdentifier]) {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //next time that the view appears it will reload
            [defaults setBool:true forKey:@"reload_scheduled_model"];
        }
    }
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 38;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return NSLocalizedString(@"message", nil);
    }
    else if(section == 1) {
        return NSLocalizedString(@"recipients", nil);
    }
    else if(section == 2) {
        return NSLocalizedString(@"archive_message", nil);
    }
    else if(section == 3) {
        //TODOreturn NSLocalizedString(@"archive_message", nil);
        return @"When";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"scheduledDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    
    
    NSInteger section = indexPath.section;
    
    if(self.model!=nil) {
        
        if(section == 0) {
           cell.textLabel.text = self.model.message;
        }
        else if(section == 1) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"selected_%@_recipients", nil), @(self.model.recipients.count)];
        }
        else if(section == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.model.saveAsTemplate ? @"true" : @"false"];//TODO
        }
        else if(section == 3) {
            cell.textLabel.text = [self.model getReadableDate];
        }
    }
    
    
    return cell;
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
