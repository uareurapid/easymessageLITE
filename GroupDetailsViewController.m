//
//  GroupDetailsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/12/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "GroupDetailsViewController.h"
#import "SelectRecipientsViewController.h"

@interface GroupDetailsViewController ()

@end

@implementation GroupDetailsViewController

@synthesize group;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //TODO check the assign
        group = [[Group alloc] init];
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil group: (Group*) groupToShow {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        group = groupToShow;
        self.title = group.name;
        //cannot delete native groups
        if(!group.isNative) {
            UIBarButtonItem *deteleGroupButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                                                  style:UIBarButtonItemStyleDone target:self action:@selector(deleteGroupClicked:)];
            deteleGroupButton.tintColor = UIColor.whiteColor;
            self.navigationItem.rightBarButtonItem = deteleGroupButton;
        }
        self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return group.contactsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    if(row < group.contactsList.count) {
        
        Contact *contact = [group.contactsList objectAtIndex:row];
        // Configure the cell...
        BOOL hasPhone = contact.phone!=nil;
        BOOL hasEmail = contact.email!=nil;
        
        if(contact.name!=nil) {
            if(contact.lastName!=nil) {
                
                NSRange range = [contact.name rangeOfString:contact.lastName
                                                    options:NSCaseInsensitiveSearch];
                if (range.length == 0) { //if the substring did not match
                    //append also lastname
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.name, contact.lastName ];//use both
                }
                else {
                    //append just the name, since the last name is already included (happens on native contacts, not core data models)
                    cell.textLabel.text = contact.name;
                }
            }
            else {
                // just the name, since last name is null
                cell.textLabel.text = contact.name;
            }
        }
        else if(contact.lastName!=nil) {
            cell.textLabel.text = contact.lastName;
        }
        else if(contact.email!=nil) {
            cell.textLabel.text = contact.email;
        }
        else if(contact.phone!=nil) {
            cell.textLabel.text = contact.phone;
        }
        
        if(hasEmail && hasPhone) {
            //has both
            cell.detailTextLabel.text =  [NSString stringWithFormat:@"Email + %@", NSLocalizedString(@"phone_label",@"Phone") ];
        }
        else if(hasEmail) {
            //only email
            cell.detailTextLabel.text = @"Email";
        }
        else {
            //only phone
            cell.detailTextLabel.text = NSLocalizedString(@"phone_label",@"Phone");
        }
        
    }
    
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return group.name;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        if(indexPath.row < group.contactsList.count) {
            
            
            SelectRecipientsViewController *root;
            for(UIViewController *controller in self.navigationController.viewControllers) {
                
                if([controller isKindOfClass: SelectRecipientsViewController.class]) {
                    root = (SelectRecipientsViewController*)controller;
                    break;
                }
            }
            if(root!=nil) {
                
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                                 message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                                delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                self.root = root;
                alert.tag = indexPath.row;
                [alert show];
            }
        }
       
    }
}

//delete the group and update the previous table
//it needs to be deleted from table and also from core data database
-(IBAction) deleteGroupClicked:(id)sender {
    
    //@property(nonatomic, copy) NSArray *viewControllers
    
//Discussion: The root view controller is at index 0 in the array, the back view controller is at index n-2, and the top controller is at index n-1, where n is the number of items in the array.
    
    SelectRecipientsViewController *root;
    for(UIViewController *controller in self.navigationController.viewControllers) {
        
        if([controller isKindOfClass: SelectRecipientsViewController.class]) {
            root = (SelectRecipientsViewController*)controller;
            break;
        }
    }
    if(root!=nil) {
        
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
                                                         message:NSLocalizedString(@"confirm_delete",@"confirm_delete")
                                                        delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.tag = -1;
        [alert show];
        
        self.root = root;
    }
    else {
       [self.navigationController popToRootViewControllerAnimated:YES]; //normal dismiss
    }
    //-[NSManagedObjectContext deleteObject:]
}
#pragma uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1 && self.root!=nil) {
        
        if(alertView.tag == -1) {
            
            // OK delete group
            [ (SelectRecipientsViewController *)self.root deleteGroup:group];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if(alertView.tag > -1 && alertView.tag < group.contactsList.count) {
            
            //remove a contact from a group instead
            Contact *toRemove = [group.contactsList objectAtIndex:alertView.tag];
            [group.contactsList removeObjectAtIndex:alertView.tag];
            [ (SelectRecipientsViewController *)self.root removeContactFromGroup: group.name contact: toRemove];
            //TODO show removed from group message!!
            [self.tableView reloadData];
        }
        
       
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
    
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
