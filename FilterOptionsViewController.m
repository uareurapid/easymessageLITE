//
//  FilterOptionsViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 11/03/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "FilterOptionsViewController.h"
#import "PCViewController.h"

@interface FilterOptionsViewController ()

@end

@implementation FilterOptionsViewController

@synthesize previousController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.previousController = previousController;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"done_button", @"done_button") style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
    
    doneButton.tintColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
    
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    //saves the options when this appears
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentOption = [defaults objectForKey:SETTINGS_FILTER_OPTIONS];
    [defaults setObject:currentOption forKey:SETTINGS_FILTER_PREVIOUS_OPTIONS];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 3;
}

-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];// popToViewController:previousController animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(section == 0) {
        if(row == 0) {
            cell.textLabel.text = NSLocalizedString(@"show_contacts_only", @"");
            if([[defaults objectForKey:SETTINGS_FILTER_OPTIONS] isEqualToString:OPTION_FILTER_CONTACTS_ONLY_KEY]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else if(row == 1) {
            cell.textLabel.text = NSLocalizedString(@"show_groups_only", @"");
            if([[defaults objectForKey:SETTINGS_FILTER_OPTIONS] isEqualToString:OPTION_FILTER_GROUPS_ONLY_KEY]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"show_all", @"");
            if([[defaults objectForKey:SETTINGS_FILTER_OPTIONS] isEqualToString:OPTION_FILTER_SHOW_ALL_KEY]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
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
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger section = indexPath.section;
    if(section == 0) {
        NSInteger row = indexPath.row;
        if(row == 0) {
            [defaults setObject:OPTION_FILTER_CONTACTS_ONLY_KEY forKey:SETTINGS_FILTER_OPTIONS];
        }
        else if(row == 1) {
            [defaults setObject:OPTION_FILTER_GROUPS_ONLY_KEY forKey:SETTINGS_FILTER_OPTIONS];
        }
        else {
            [defaults setObject:OPTION_FILTER_SHOW_ALL_KEY forKey:SETTINGS_FILTER_OPTIONS];
        }
        
        [defaults synchronize];
        
        [tableView reloadData];
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

