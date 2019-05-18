//
//  ContactDetailsViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 16/12/2018.
//  Copyright © 2018 Paulo Cristo. All rights reserved.
//

#import "ContactDetailsViewController.h"
#import "SelectRecipientsViewController.h"
#import <Contacts/Contacts.h>
#import "PCAppDelegate.h"
#import "AddContactViewController.h"
@interface ContactDetailsViewController ()
{
 Contact *contact;
}
@end

@implementation ContactDetailsViewController

@synthesize contactModel;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        contact = [[Contact alloc] init];
        contactModel = nil;
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

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        contact = contactToShow;
        self.title = contact.name;
        //UIBarButtonItem *deteleContactButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"delete",@"delete")
          //                                                                style:UIBarButtonItemStyleDone target:self action:@selector(deleteContactClicked:)];
    
        //deteleContactButton.tintColor = UIColor.whiteColor;
        //elf.navigationItem.rightBarButtonItem = deteleContactButton;
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        self.navigationItem.rightBarButtonItem = optionsButton;
        self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contact: (Contact*) contactToShow andModel: (NSObject *) model {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        contact = contactToShow;
        contactModel = model;
        self.title = contact.name;

        
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        self.navigationItem.rightBarButtonItem = optionsButton;
        self.navigationItem.backBarButtonItem.tintColor = UIColor.whiteColor;
        
    }
    return self;
}

-(BOOL) isNativeContact {
    return (contactModel!= nil && [contactModel isKindOfClass:CNMutableContact.class] ) || (contact!=nil && [contact isNativeContact ]);
}

- (void)optionsClicked:(id)sender event:(UIEvent *)event{
    [self showMenu:sender withEvent: event];
}

-(void) closeNativeContactController:(id) sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
}

- (void) showMenu:(id)sender withEvent: (UIEvent *)event
{
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor whiteColor];
    configuration.menuWidth = 200;
    
    PCAppDelegate *delegate = (PCAppDelegate *) [[UIApplication sharedApplication] delegate];
    configuration.separatorColor = [delegate colorFromHex:0xfb922b];
    
    //no selection
    [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"edit",@"edit"),NSLocalizedString(@"delete",@"delete")]
                      imageArray:@[@"edit40",@"delete"]
                   configuration:configuration
                       doneBlock:^(NSInteger selectedIndex) {
                           NSLog(@"selected %ld", (long)selectedIndex);
                           if(selectedIndex == 0) {
                               //edit
                               //TODO
                               [self showAddContactController];
                           }
                           else {
                               //delete
                               [self deleteContactClicked: sender];
                           }
                       } dismissBlock:^{
                           
                       }];
}

//edit contact
-(void) showAddContactController {
    
    if([self isNativeContact]) {
        
        CNContactViewController *controller = [CNContactViewController viewControllerForContact:(CNMutableContact *) self.contactModel];
        [controller setAllowsEditing:true];
        
        controller.delegate = self;
        
        
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: controller];
        
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        controller.navigationController.navigationBar.hidden = false;
        controller.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
        
        controller.navigationController.navigationBar.hidden = false;
        
        
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"done_button", nil)  style:UIBarButtonItemStyleDone target:self action:@selector(closeNativeContactController:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        controller.navigationItem.leftBarButtonItem = optionsButton;
        
        controller.navigationController.navigationBar.backgroundColor = [delegate colorFromHex:0xfb922b];
        controller.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        [self showViewController:navigationController sender:self];
        
        
    } else {
        
        AddContactViewController *addNewContactController = [[AddContactViewController alloc] initWithNibName:@"AddContactViewController" bundle:nil];
        addNewContactController.editMode = true;
        addNewContactController.contactsList = [[NSMutableArray alloc] init]; //empty list
        addNewContactController.contactModel = contactModel; //same object
        addNewContactController.contact = contact;//our contact class (we need to show this info, and maybe edit the other)
        
        
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        //we present it modally on a navigation controller to get a status bar
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController: addNewContactController];
        navigationController.navigationBar.barTintColor = [delegate colorFromHex:0xfb922b];
        
        [self presentViewController:navigationController animated:YES completion:^{
            //((SelectRecipientsViewController *) self.presentationController).reload = true;
        }];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(contact.phone!=nil && contact.email!=nil ){
        return 3;
    }
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    if(contact!=nil) {
        
        // Configure the cell...
        BOOL hasPhone = contact.phone!=nil;
        BOOL hasEmail = contact.email!=nil;
        
        if(row==0){
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
            //also add detail info
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
            //cell.editing = true;
            //cell.editingStyle = UITableViewCellStyleE
        }
        else if(row==1){
            //either phone or email
            if(contact.email!=nil) {
                cell.textLabel.text = [NSString stringWithFormat:@"Email: %@", contact.email];
            }
            else if(contact.phone!=nil) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"phone_label",@"Phone"),contact.phone ];
            }
        }
        else{
            if(contact.phone!=nil) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"phone_label",@"Phone"),contact.phone ];
            }
            else if(contact.email!=nil) {
                cell.textLabel.text =  [NSString stringWithFormat:@"Email: %@", contact.email];
            }
        }
       
        
        /*
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
        }*/
    }
    
    return cell;
}

-(IBAction) deleteContactClicked:(id)sender {
    
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
        self.root = root;
        [alert show];
        
        
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES]; //normal dismiss
    }
    //-[NSManagedObjectContext deleteObject:]
}

#pragma uialertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1 && self.root!=nil) {
        // OK
        [ (SelectRecipientsViewController *)self.root deleteContact:contact];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
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
