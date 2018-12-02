//
//  SelectRecipientsViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/19/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SelectRecipientsViewController.h"
#import "PCViewController.h"
#import "EasyMessageIAPHelper.h"
#import "PCAppDelegate.h"
#import "GroupDataModel.h"
#import "ContactDataModel.h"
#import "GroupDetailsViewController.h"
#import "CoreDataUtils.h"


const NSString *MY_ALPHABET = @"ABCDEFGIJKLMNOPQRSTUVWXYZ";

@interface SelectRecipientsViewController ()

@end

@implementation SelectRecipientsViewController

@synthesize contactsList,selectedContactsList,rootViewController;
@synthesize initialSelectedContacts,contactsByLastNameInitial; //TODO PC ORDER BY last name, first name
@synthesize sortedKeys,groupLocked,databaseRecords;
@synthesize groupsNamesArray, groupsList, activityIndicator;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) showAddContactController {
    if(self.addNewContactController==nil) {
      self.addNewContactController = [[AddContactViewController alloc] initWithNibName:@"AddContactViewController" bundle:nil];
        self.addNewContactController.contactsList = self.contactsList;
    }
    [self presentViewController:self.addNewContactController animated:YES completion:^{
        self.reload = true;
    }];
}



//THIS IS THE METHOD THAT IS CALLED FROM APPDELEGATE
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
    
        self.contactsList = [[NSMutableArray alloc] init];
        self.groupsList = [[NSMutableArray alloc] init];
        
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.databaseRecords = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"select_all",@"select_all")
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectAllContacts:)];
        //initWithTitle:NSLocalizedString(@"select_all",nil)
        self.navigationItem.leftBarButtonItem = doneButton;
        
        
        //UIBarButtonItem *addToGroupButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_to_group",@"add_to_group")
                                                                      //       style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        //also used to create a new contact if nothing is selected
        UIBarButtonItem *addToGroupButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"new_contact",@"new_contact") style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        //[addToGroupButton setTintColor:[UIColor redColor]];
    
    //initWithTitle:NSLocalizedString(@"new_contact",@"new_contact")
      //                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        
        //[addToGroupButton setCustomView:[self setupGroupButton]];
        self.navigationItem.rightBarButtonItem = addToGroupButton;
        //[addToGroupButton setEnabled:NO];
        [addToGroupButton setEnabled:YES];
        groupLocked = NO;
        
 
        NSArray* toolbarItems = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(goBackAfterSelection:)],nil];
        
        
        self.toolbarItems = toolbarItems;
        self.navigationController.toolbarHidden = NO;
        self.tabBarItem.image = [UIImage imageNamed:@"phone-book"];
        self.title =  NSLocalizedString(@"recipients",nil);
        
        // Change the position according to your requirements
        //self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 70, 320, 44)];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        /*the search bar widht must be > 1, the height must be at least 44
         (the real size of the search bar)*/
        
        self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        /*contents controller is the UITableViewController, this let you to reuse
         the same TableViewController Delegate method used for the main table.*/
        
        self.searchDisplayController.delegate = self;
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsDelegate = self;
        //set the delegate = self. Previously declared in ViewController.h
        
        self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        
        self.searchData = [[NSMutableArray alloc] init];
        self.searchDataSelection = [[NSMutableArray alloc] init];
        
        self.reload = false;
        
    }
    return self;
}

//called from main to refresh the list
-(void) reloadContacts: (NSMutableArray *) contacts {
    [self.contactsList removeAllObjects];
    [self.contactsList addObjectsFromArray:contacts];
    NSLog(@"the new list has %ld",(unsigned long)contacts.count);
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts rootViewController: (PCViewController*) viewController{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] initWithArray:contacts];
        self.groupsList = [[NSMutableArray alloc] init];
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Recipients";
      
     
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        /*the search bar widht must be > 1, the height must be at least 44
         (the real size of the search bar)*/
        
        self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        /*contents controller is the UITableViewController, this let you to reuse
         the same TableViewController Delegate method used for the main table.*/
        
        self.searchDisplayController.delegate = self;
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsDelegate = self;
        //set the delegate = self. Previously declared in ViewController.h
        self.searchData = [[NSMutableArray alloc] init];
        self.searchDataSelection = [[NSMutableArray alloc] init];
        
        self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        
        self.reload = false;
        
    }
    return self;
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil contacts: (NSMutableArray *) contacts
         selectedOnes: (NSMutableArray *) selectedRecipients rootViewController: (PCViewController*) viewController {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.contactsList = [[NSMutableArray alloc] initWithArray:contacts];
        self.groupsList = [[NSMutableArray alloc] init];
        self.selectedContactsList = [[NSMutableArray alloc] initWithArray:selectedRecipients];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title = @"Recipients";
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        /*the search bar widht must be > 1, the height must be at least 44
         (the real size of the search bar)*/
        
        self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        /*contents controller is the UITableViewController, this let you to reuse
         the same TableViewController Delegate method used for the main table.*/
        
        self.searchDisplayController.delegate = self;
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsDelegate = self;
        //set the delegate = self. Previously declared in ViewController.h
        self.searchDataSelection = [[NSMutableArray alloc] init];
        self.searchData = [[NSMutableArray alloc] init];
        
        self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        
        self.reload = false;
        
        //TODO http://stackoverflow.com/questions/6947858/adding-uisearchbar-programmatically-to-uitableview
    }

    
    return self;
}

//add the existing groups to the list
-(void) checkForExistingGroups {
    
    if(self.groupsNamesArray == nil) {
        self.groupsNamesArray = [[NSMutableArray alloc] init];
    }
    
    for(id contact in contactsList) {
        if([contact isKindOfClass:Group.class]) {
            Group *gr = (Group *)contact;
            
            if(![self.groupsNamesArray containsObject:gr.name]) {
                [self.groupsList addObject:gr];
                [self.groupsNamesArray addObject:gr.name];
            }
        }
    }
    NSLog(@"NUM GROUPS %lu", (unsigned long)self.groupsList.count);
}

//get group by name
-(Group*) getGroupByName: (NSString *) name {
    for(Group *g in groupsList) {
        if([g.name isEqualToString:name]) {
            return g;
        }
    }
    return nil;
}
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    [self.searchData removeAllObjects];
    /*before starting the search is necessary to remove all elements from the
     array that will contain found items */
    
    //Contact *contact;
    
    /* in this loop I search through every element (group) (see the code on top) in
     the "originalData" array, if the string match, the element will be added in a
     new array called newGroup. Then, if newGroup has 1 or more elements, it will be
     added in the "searchData" array. shortly, I recreated the structure of the
     original array "originalData". */
    
    for(Contact *contact in contactsList) //take the n group (eg. group1, group2, group3)
        //in the original data
    {
        //NSMutableArray *newGroup = [[NSMutableArray alloc] init];
        NSString *name = contact.name;
        NSString *lastname = contact.lastName;
        if(name!=nil || lastname!=nil) {

            if(name!=nil) {
                NSRange range = [name rangeOfString:searchText
                                            options:NSCaseInsensitiveSearch];
                if (range.length > 0) { //if the substring match
                    [self.searchData addObject:contact]; //add the element
                }
            }
            else if(lastname!=nil) {
                NSRange range = [lastname rangeOfString:searchText
                                            options:NSCaseInsensitiveSearch];
                if (range.length > 0) { //if the substring match
                    [self.searchData addObject:contact]; //add the element
                }
            }
            
        }
        
    }
   // [self.searchDisplayController.searchResultsTableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
 
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.

    
    return YES;
}

/*-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}*/


-(IBAction)refreshPhonebook:(id)sender {
    contactsByLastNameInitial = [self loadInitialNamesDictionary];
    NSLog(@"number of contacts in list: %lu", (unsigned long)self.contactsList.count);
    
    [self checkForExistingGroups];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });
    
}

//will group the contacts by last name initial
- (NSMutableDictionary *) loadInitialNamesDictionary {
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.sortedKeys = [[NSMutableArray alloc] init];
    
    //either by first bname or last name
    NSString *selectedOrderBySaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
    NSLog(@"SORT BY: %@",selectedOrderBySaved);
    if(selectedOrderBySaved == nil) {
        selectedOrderBySaved = OPTION_ORDER_BY_LASTNAME_KEY;
    }
    for(Contact *contact in contactsList) {
        
        NSString *initial;
        
        if([contact isKindOfClass:Group.class]) {
            initial = [[contact.name substringToIndex:1] uppercaseString];
        }
        else {
            
            if([selectedOrderBySaved isEqualToString:OPTION_ORDER_BY_LASTNAME_KEY]) {
                //default, sort by last name
                if(contact.lastName!=nil && contact.lastName.length>0) {
                    initial = [[contact.lastName substringToIndex:1] uppercaseString];
                }
                else if(contact.name!=nil && contact.name.length>0) {
                    initial = [[contact.name substringToIndex:1] uppercaseString];
                }
                else if(contact.email!=nil && contact.email.length>0) {
                    initial = [[contact.email substringToIndex:1] uppercaseString];
                }
                else if(contact.phone!=nil && contact.phone.length>0) {
                    initial = [[contact.phone substringToIndex:1] uppercaseString];
                }
            }
            else {
             //sort by first name
                if(contact.name!=nil && contact.name.length>0) {
                    initial = [[contact.name substringToIndex:1] uppercaseString];
                }
                else if(contact.lastName!=nil && contact.lastName.length>0) {
                    initial = [[contact.lastName substringToIndex:1] uppercaseString];
                }
                else if(contact.email!=nil && contact.email.length>0) {
                    initial = [[contact.email substringToIndex:1] uppercaseString];
                }
                else if(contact.phone!=nil && contact.phone.length>0) {
                    initial = [[contact.phone substringToIndex:1] uppercaseString];
                }
            }
            
        }
        
        
        
        
        id listForThatInitial = [dic objectForKey:initial];
        if(listForThatInitial == nil) {
            //doesnt exist yet, create the array
            NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:contact, nil];
            [dic setObject:array forKey:initial];
            [sortedKeys addObject:initial];
        }
        else {
            //already exists cast it
            NSMutableArray *array = (NSMutableArray *) listForThatInitial;
            [array addObject:contact];
        }
           
        
        
    }

    if(self.sortedKeys.count > 0) {
        NSArray *other = [[NSArray alloc] initWithArray:self.sortedKeys];
        [self.sortedKeys removeAllObjects];
        [self.sortedKeys addObjectsFromArray: [other sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    }
    

    return dic;
}

#pragma PICKER VIEW DELEGATE

//TODO PC https://naveenios.wordpress.com/2015/11/26/pickerview-using-uialertcontroller/

#pragma END PICKER VIEW DELEGATE
- (void)viewDidLoad
{
    [super viewDidLoad];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    self.tableView.sectionHeaderHeight = 2.0;
    self.tableView.sectionFooterHeight = 2.0;
    [self refreshPhonebook:nil];

    //set the images
    //imageLock = [UIImage imageNamed:@"Lock32"];
    //imageUnlock = [UIImage imageNamed:@"Unlock32"];
    
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

#pragma  search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    //searchBar.hidden = YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField {
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    //if(searchField.text.length<3)//minimum 3 chars
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    if(searchField.text.length>3) {
        //try to find a match
        for(Contact *c in contactsList) {
            NSString * name = c.name;
            if([name rangeOfString:searchField.text].location!= NSNotFound ) {
                searchField.text = name;
                return;
            }
        }
    }
        
}

//delete a group
-(void) deleteGroup:(Group *)group{
    
    BOOL deleted = [CoreDataUtils deleteGroupDataModelByName:group.name];
    if(deleted) {
        NSLog(@"deleted on db, group: %@",group.name);
        [group.contactsList removeAllObjects];
        [contactsList removeObject:group];
        
        [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
           setGravity:iToastGravityBottom] setDuration:2000] show];
        
        [self refreshPhonebook:nil];
    }

    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //s[searchBar resignFirstResponder];
    //move the keyboard out of the way
    
    
    
    [searchBar resignFirstResponder];
    //[self checkIfNavigateToSection:searchBar];
}

-(void) checkIfNavigateToSection: (UISearchBar *) searchBar {
    UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    NSString *contactFullName = searchField.text;
    NSInteger section = -1;
    NSInteger row = -1;
    
    if(contactFullName!=nil) {
        
        for(Contact *contact in contactsList) {
            NSString * name = contact.name;
            if([name isEqualToString:contactFullName]) {
                //We found the contact we want
                NSString *initial; //get the key on dictionary
                if(contact.lastName!=nil) {
                    
                    initial = [[contact.lastName substringToIndex:1] uppercaseString];
                }
                else if(contact.name!=nil) {
                    initial = [[contact.name substringToIndex:1] uppercaseString];
                }
                
                
                if(initial!=nil) {
                    
                    
                    int i = 0;
                    for(id key in contactsByLastNameInitial.keyEnumerator) {
                        NSString *keyString = (NSString*)key;
                        if([keyString isEqualToString:initial]) {
                            section = i;
                            break;
                            //we have the section already, exit;
                        }
                        i++;
                    }
                    
                    
                    
                    NSMutableArray *cList = [contactsByLastNameInitial objectForKey:initial];
                    
                    int x = 0;
                    for(Contact *theContact in cList) {
                        if([theContact.name isEqualToString: contactFullName]) {
                            row = x;
                            break;
                            //and now we have the row too
                        }
                        x++;
                    }
                    
                }//end if initial!=nil
            }//end if name is equal fullName
        }//end outer foor loop
    }//end if
    
    
   // [theTable reloadData];
    if(row>-1 && section>-1) {
        NSLog(@"will scroll to section %ld and row %ld",(long)section,(long)row);
       NSIndexPath *scrollToPath = [NSIndexPath indexPathForRow:row inSection:section];
       [self.tableView scrollToRowAtIndexPath:scrollToPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    
    
    
    
}

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  //  return YES;
//}
//-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //GET THE TEXT
    //UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    //if(searchField.text.length<3)//minimum 3 chars
//}

#pragma navigation stuff
-(IBAction)goBackAfterSelection:(id)sender {
    //[rootViewController.selectedRecipientsList addObjectsFromArray:selectedContactsList];
    [self.tabBarController setSelectedIndex:0];// popToRootViewControllerAnimated:YES];
}

-(IBAction)selectAllContacts:(id)sender {
    
    //if we have all selected, remove selection
    if(selectedContactsList.count > 0) {
        
        [activityIndicator startAnimating];
        
        rootViewController.recipientsLabel.text = @"";
        [selectedContactsList removeAllObjects];
        
        [activityIndicator stopAnimating];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all",@"select_all");
           //self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all", @"seleccionar tudo");
            //[self.navigationItem.rightBarButtonItem setEnabled:NO];
            //can add a contact
            //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact", @"new_contact");
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact",@"new_contact");
            
            self.groupLocked = true;

            
        });
        
    }
    else {
        
        [activityIndicator startAnimating];
        
        for (NSInteger s = 0; s < self.tableView.numberOfSections; s++) {
            for (NSInteger r = 0; r < [self.tableView numberOfRowsInSection:s]; r++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
                
                
                NSInteger section = indexPath.section;
                //NSInteger row = indexPath.row;
                
                
                NSString *key = [sortedKeys objectAtIndex:section];
                
                NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
                for(Contact *contact in array) {
                    if(![selectedContactsList containsObject:contact]) {
                        [selectedContactsList addObject:contact];
                    }
                }
                
            }
        }
        
        [activityIndicator stopAnimating];
        
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
        rootViewController.recipientsLabel.text = msg;
       
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"unselect_all",@"unselect_all");
            //title = NSLocalizedString(@"unselect_all", @"remover selecção");
            //can add them to the group
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"create_group", @"create_group");
            self.groupLocked = false;
        });
        
        
    }
        
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });

}

-(void) viewDidAppear:(BOOL)animated {
    
    initialSelectedContacts = selectedContactsList.count;
    groupLocked = false;
    
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    if(selectedContactsList.count>1) {
        //can add a new group
        groupLocked = false;
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"create_group",@"create_group")];
    }
    else {
        //cannot add a group only a contact
        groupLocked = true;
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"new_contact",@"new_contact")];
    }
    
    //from adding new contact
    if(self.reload) {
        [self refreshPhonebook:nil];
    }
     
}

-(UIButton *)setupGroupButton {
    
    UIButton *group = [UIButton buttonWithType:UIButtonTypeCustom];
    //[group setBackgroundImage:(groupLocked ? imageLock : imageUnlock) forState:UIControlStateNormal];
    [group setTitle:@"Add to group" forState:UIControlStateNormal];
    group.frame = (CGRect) {
        .size.width = 100,
        .size.height = 30,
    };
    
    return group;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    //if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
    //}
   
    [self dismissAndPrefillContactList];
    
    
   
}

-(void) dismissAndPrefillContactList {
    [rootViewController.selectedRecipientsList removeAllObjects];
    [rootViewController.selectedRecipientsList addObjectsFromArray:selectedContactsList];
    
    if(selectedContactsList.count>0 && initialSelectedContacts!=selectedContactsList.count) {
        
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
    }
}

//selects users with birthday in this date
-(void) searchForBirthdayIn:(NSInteger)day month:(NSInteger)month {
    
    if(self.contactsList == nil) {
        self.contactsList = [[NSMutableArray alloc] init];
    }
    
    if(self.selectedContactsList == nil) {
        self.selectedContactsList = [[NSMutableArray alloc] init];
    }
    else {
        [self.selectedContactsList removeAllObjects];
    }
    for(Contact *contact in self.contactsList) {
        if(contact.birthday !=nil) {
            NSDate *data = contact.birthday;
            NSDateComponents *componentsContact = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate: data];
            
            NSLog(@"USER: %@ --> comparing day %ld with calendar day %ld and month %ld with contact month %ld",contact.name,day, componentsContact.day,month,componentsContact.month);
            if(day == componentsContact.day && month == componentsContact.month) {
                //this is one of the targets
                NSLog(@"adding %@ to the list",contact.name);
                [self.selectedContactsList addObject:contact];
            }
        }
    }
    
    NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
    
    if(selectedContactsList.count > 0 ) {
        
        
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:2000] show];
        
        [rootViewController.selectedRecipientsList removeAllObjects];
        [rootViewController.selectedRecipientsList addObjectsFromArray:selectedContactsList];
    }
    
    rootViewController.recipientsLabel.text = msg;
}

#pragma groups stuff

/**
 *checks if the group with this name exists
 */
-(BOOL) checkIfGroupExists: (NSString *) name {
    
    
    for(id contact in contactsList) {
        if([contact isKindOfClass:Group.class]) {
            Group *gr = (Group *)contact;
            if([gr.name isEqualToString:name]) {
                return YES;
            }
        }
    }
    return NO;
}








#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return contactsByLastNameInitial.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSMutableArray *array = contactsByLastNameInitial ob
    //int count = contactsByLastNameInitial.count;
    
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchData count];
    } else {
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
        return array.count;
    }
    
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
   
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    
    NSString *key = [sortedKeys objectAtIndex:section];
    NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
    
    BOOL isGroup = NO;
    
    
    Contact *contact;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        contact = [self.searchData objectAtIndex:indexPath.row];
        
    } else {
        contact = [array objectAtIndex:row];
    }
    
    
    if([contact isKindOfClass:Group.class]) {
        Group *thisOne = (Group *) contact;
        cell.detailTextLabel.text = [NSString stringWithFormat: @"Group (%lu members)",(unsigned long)thisOne.contactsList.count ];
        isGroup = YES;
        cell.textLabel.text = contact.name;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:(16.0)];
    }
    else {
        
        if(contact.name!=nil) {
            cell.textLabel.text = contact.name;
            if(contact.lastName!=nil) {//append also last name
                
                //get the selected options for order by
                /*NSString *selectedOrderBySaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
                NSLog(@"CELL SORT BY: %@",selectedOrderBySaved);
                if(selectedOrderBySaved == nil) {
                    selectedOrderBySaved = OPTION_ORDER_BY_LASTNAME_KEY;
                }*/
                
                
                //check if last name is already include in name
                NSRange range = [contact.name rangeOfString:contact.lastName
                                            options:NSCaseInsensitiveSearch];
                if (range.length == 0) { //if the substring did not match
                    //append also lastname
                    //if([selectedOrderBySaved isEqualToString: OPTION_ORDER_BY_LASTNAME_KEY]) {
                    //   cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.lastName, contact.name];
                    //}
                    //else {
                       cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.name,contact.lastName];
                    //}
                    
                }
                
                
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
        
        BOOL hasPhone = contact.phone!=nil && contact.phone.length > 0;
        BOOL hasEmail = contact.email!=nil && contact.email.length > 0;
        
        if(hasEmail && hasPhone) {
            cell.detailTextLabel.text =  [NSString stringWithFormat:@"Email + %@", NSLocalizedString(@"phone_label",@"Phone") ];
        }
        else if(hasEmail) {
            cell.detailTextLabel.text = @"Email";
        }
        else {
            //only phone
            cell.detailTextLabel.text = NSLocalizedString(@"phone_label",@"Phone");
        }
    }
    
    
    if([selectedContactsList containsObject:contact]) {
    
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        if(isGroup) {
            //and not selected
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
  
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = [sortedKeys objectAtIndex:indexPath.section];
    NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
    
    Contact *c = [array objectAtIndex:indexPath.row];
    if([c isKindOfClass:Group.class]) {
       Group *group = (Group*)c;
       
        GroupDetailsViewController *detailViewController = [[GroupDetailsViewController alloc] initWithNibName:@"GroupDetailsViewController" bundle:nil group:group];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    
}


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
   
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    Contact *contact;
    
    /***************************/
    if (self.searchDisplayController.active) {
        
        //self.searchBar.showsCancelButton = false;
        //self.searchBar.showsSearchResultsButton = true;
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        contact = [self.searchData objectAtIndex:indexPath.row];
        
        Contact *contactOnRealTable;
        //get the corresponding cell on the real table
        NSString *lastName = contact.lastName;
        if(lastName!=nil) {
            NSString *key = [NSString stringWithFormat:@"%c", [lastName characterAtIndex:0]];
            NSInteger indexOfKey = 0;
            for(NSString *str in sortedKeys) {
                if([str isEqualToString:key]) {
                    //section on real table
                    section = indexOfKey;
                    break;
                }
                else {
                    indexOfKey++;
                }
            }
            
            NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
            NSInteger i =0;
            for(i=0; i < array.count; i++) {
                Contact *c = [array objectAtIndex:i];
                if([c isEqual:contact]) {
                    row = i;
                    break;
                }
            }
            
            /*if(![self.selectedContactsList containsObject:contact]) {
                [self.contactsList addObject:contact];
            }
            else {
                [self.selectedContactsList removeObject:contactsList];
            }*/
            
            if(![self.searchDataSelection containsObject:contact]) {
                [self.searchDataSelection addObject:contact];
            }
            else {
                [self.searchDataSelection removeObject:contact];
            }

            NSIndexPath *path =  [NSIndexPath indexPathForRow:row inSection:section];
            [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            //[[[[iToast makeText:[NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(self.contactsList.count)]]
              // setGravity:iToastGravityBottom] setDuration:1000] show];
            // Return the number of sections.
            
            
            
            [self.searchDisplayController setActive:false];
            
            
        }
        
    } else {
        
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
        contact = [array objectAtIndex:row];
  
    }
    /***************************/
    
    
    
    
   if(![selectedContactsList containsObject:contact]) {
        [selectedContactsList addObject:contact];
   }
   else {
     //already contains, remove it
     [selectedContactsList removeObject:contact];
   }
    
    if(selectedContactsList.count>0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"unselect_all",@"unselect_all");
            //NSLocalizedString(@"unselect_all", @"remover selecção");
            
            if(selectedContactsList.count>1) {
                self.groupLocked = false;
                self.navigationItem.rightBarButtonItem.title  = NSLocalizedString(@"new_group",@"new_group");
            }
            else {
                //only 1 selected, cannot create a group
                //TODO PC if i have groups show the option to add to an existing group
                self.groupLocked = true;
                
                if(self.groupsList.count > 0) {
                    self.navigationItem.rightBarButtonItem.title  = NSLocalizedString(@"add_to_group",@"add_to_group");
                }
        
                //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact",@"new_contact");
            }
            
        });
        
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
        
         rootViewController.recipientsLabel.text = msg;
        
    }
    else {
         rootViewController.recipientsLabel.text = @"";
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all",@"select_all");
            //NSLocalizedString(@"select_all", @"seleccionar tudo");
            
            self.groupLocked = true;
            self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact",@"new_contact");;
            //NSLocalizedString(@"new_contact", @"new_contact");
            
        });
    }

    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    
    //[self.navigationItem.rightBarButtonItem setEnabled: ( (selectedContactsList.count>1) && !groupLocked ) ];
    

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });

}

//ADDED these 2 methods bellow for the alphabet stuff
#pragma alhpabet scroll view stuff
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return [sortedKeys indexOfObject:title];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *indices =
    [NSMutableArray arrayWithCapacity:[sortedKeys count]+1];
    
    [indices addObject:UITableViewIndexSearch];
    
    for (NSString *item in sortedKeys)
        [indices addObject:[item substringToIndex:1]];
    
    
    return indices;
}
//###############################


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    if(tableView==self.searchDisplayController.searchResultsTableView) {
        return @"";
    }
   
    NSString *key = [sortedKeys objectAtIndex:section];
    return key;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(tableView==self.searchDisplayController.searchResultsTableView)
        return 0;
    
    if(section == 0)
    {
        return UITableViewAutomaticDimension;
    }
    return 32;
}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == contactsByLastNameInitial.count-1) { //if is the last section
        return [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
    }
    return @"";//
}
//TODO PC fetch the group model, the contact model and chage on CORE DATA + reflect changes on local lists
-(void) addContactToGroup: (NSString *) groupName contact: (Contact *) contact {
    
    //NSLog(@"addContactToGroup..... %@ : %@", groupName, contact.name);
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", groupName];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    //The array results contains all the managed objects contained within the sqlite file. If you want to grab a specific object (or more objects) you need to use a predicate with that request. For example:
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Some Title"];
    //[request setPredicate:predicate];
    
    if(results.count > 0) {
        //
        for(GroupDataModel *groupModel in results) {
            if([groupModel.name isEqualToString:groupName]) {
                //OK found the group
                NSLog(@"OK FOUND THE GROUP");
                //find the equivalent group, on local group list
                Group *group = [self getGroupByName:groupName];
                if(group !=nil) {
                    for( Contact *c in [group contactsList]) {
                        //contact already exists on group
                        if([c isEqual:contact]) {
                            NSLog(@"ignore contact exists");
                            [[[[iToast makeText:NSLocalizedString(@"contact_already_exists",@"contact_already_exists")]
                               setGravity:iToastGravityBottom] setDuration:2000] show];
                            return;
                        }
                    }
                }

                //------------------
                // get all the contacts by this name and find the best match
                NSMutableArray *array = [CoreDataUtils fetchAllContactsDataModelByName: contact.name];
                NSLog(@"FETCH RESULTS FOR NAME %@",contact.name);
                if(array !=nil) {
                    NSLog(@"GOT CONTACTS RESULTS COUNT %lu ",(unsigned long)array.count);
                    ContactDataModel *contactModel = nil;
                    if(array.count == 1) {
                        contactModel = [array objectAtIndex:0];
                    }
                    else {
                        for(ContactDataModel *res in array) {
                            if(res.lastname !=nil && contact.lastName!=nil && [res.lastname isEqualToString:contact.lastName]) {
                                contactModel = res;
                                break;
                            }
                            else if(res.email !=nil && contact.email!=nil && [res.email isEqualToString:contact.email]) {
                                contactModel = res;
                                break;
                            }
                            else if(res.phone !=nil && contact.phone!=nil && [res.phone isEqualToString:contact.phone]) {
                                contactModel = res;
                                break;
                            }
                        }
                    }
                    
                    //TODO PC ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :contact];
                    //check again, if the contact is not on CORE DDATA it return nothing (need to create the core data model but then it
                    //gets duplicated, how to fix??
                    //DUPLICATE ON CORE DATA and hide it from the list if already exists
                    if(contactModel !=nil) {
                        NSLog(@"GOT CONTACT MATCH %@ ",contactModel.name);
                        //add the contact to the group
                        [groupModel addContactsObject:contactModel];
                        //assign the group to teh contact to the
                        [contactModel addGroupObject:groupModel];
                        
                        // not needed [group.contactsList addObject:contact];
                        
                        BOOL OK = NO;
                        NSError *error;
                        
                        if(![managedObjectContext save:&error]){
                            NSLog(@"Unable to save object, error is: %@",error.description);
                            //This is a serious error saying the record
                            //could not be saved. Advise the user to
                            //try again or restart the application.
                        }
                        else {
                            OK = YES;
                            [[[[iToast makeText:NSLocalizedString(@"added",@"added")]
                               setGravity:iToastGravityBottom] setDuration:2000] show];
                        }
                        
                        if(OK) {
                            
                            //if just added a group i clear the selection
                            [selectedContactsList removeAllObjects];
                            
                            for(Contact *cont in contactsList) {
                                if([contact isKindOfClass:Group.class] && [cont.name isEqualToString: groupName]) {
                                    Group *gr = (Group *) contact;
                                    [gr.contactsList addObject:contact];
                                }
                            }
                            for(Group *group in groupsList) {
                                if([group.name isEqualToString:groupName]) {
                                    [group.contactsList addObject:contact];
                                }
                            }
                            //refresh the view
                            [self refreshPhonebook:nil];
                            //will also add to the list of groups
                            return;
                        }
                        //------------------
                    }else NSLog(@"IS NULLLLLL");
                }else NSLog(@"ARRY IS NILLLLLL");
                
            }
        }
            
    }
    
}
//show the input new group dialog
- (IBAction)addGroupClicked:(id)sender{

    UIAlertView * alert;
    //adding a contact
    if(self.groupLocked) {
        if(self.selectedContactsList.count == 1) {
            [PickerView showPickerWithOptions:self.groupsNamesArray title:@"Select a group" selectionBlock:^(NSString *selectedOption) {
                    //TODO
                    Contact *c = [self.selectedContactsList objectAtIndex:0];
                    [self addContactToGroup: selectedOption contact:c];
                }];
            
            
        }
        else {
            [self showAddContactController];
        }
    }
    else {
        //adding a group allowed
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"new_group",@"new_group") message:NSLocalizedString(@"enter_group_name",@"enter_group_name") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"save",@"save"),nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    
    
    [alert show];
}


//the delegate for the new Group
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save
        NSString *groupName = [alertView textFieldAtIndex:0].text;
        
        if(groupName.length==0) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_name",@"invalid_name") message:NSLocalizedString(@"invalid_name",@"invalid_name") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
        else {
            if([self checkIfGroupExists:groupName]==NO) {
                
                //name OK, save it!
                [self saveGroup: groupName];
                
            }
            else {
                //group name already exists
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_name",@"invalid_name") message:NSLocalizedString(@"group_already_exists",@"group_already_exists") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        
        
        
    }
    
}

//save the location record
-(void)saveGroup:(NSString*)name {
    
  
        
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        GroupDataModel *groupModel = (GroupDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
        
        
        groupModel.name = name;
        
        Group *group = [[Group alloc]init];
        group.name = name;
        
        for(Contact *selected in selectedContactsList) {
            
            //add group to group
            if([selected isKindOfClass:Group.class]) {
                
                //cast contact to group
                Group *theSelected = (Group *) selected;
                
                //now get the real contacts on this group
                for(Contact *contact in theSelected.contactsList) {
                    
                    //add to core data
                    ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :contact];
                    
                    [groupModel addContactsObject:contactModel];
                    [contactModel addGroupObject:groupModel];
                    
                    [group.contactsList addObject:contact];
                }
                
            }
            else {
                //add single contact to group
                ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :selected];
                
                [groupModel addContactsObject:contactModel];
                [contactModel addGroupObject:groupModel];
                
                [group.contactsList addObject:selected];
            }
            
            
            
        }
        BOOL OK = NO;
        NSError *error;
        
            if(![managedObjectContext save:&error]){
                NSLog(@"Unable to save object, error is: %@",error.description);
                //This is a serious error saying the record
                //could not be saved. Advise the user to
                //try again or restart the application.
            }
            else {
                OK = YES;
                [[[[iToast makeText:NSLocalizedString(@"group_created",@"group_created")]
                   setGravity:iToastGravityBottom] setDuration:2000] show];
            }
        
        if(OK) {
            [contactsList addObject:group];
            //if just added a group i clear the selection
            [selectedContactsList removeAllObjects];
            //refresh the view
            [self refreshPhonebook:nil];
            //will also add to the list of groups
    
        }
    //}
    //else {
    //    NSLog(@"Need at least 2 contacts in group");
    //}
    
    
    
}
//set the data needed
-(ContactDataModel *) prepareModelFromContact: (NSManagedObjectContext *) managedObjectContext: (Contact *)contact {
    
    ContactDataModel *contactModel = (ContactDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"ContactDataModel" inManagedObjectContext:managedObjectContext];
    contactModel.name = contact.name;
    contactModel.phone = contact.phone;
    contactModel.email = contact.email;
    contactModel.lastname = contact.lastName;
    
    return contactModel;
}

@end
