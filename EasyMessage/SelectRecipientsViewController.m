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
#import "GroupDetailsViewController.h"
#import "ContactDetailsViewController.h"
#import "CoreDataUtils.h"

const NSString *MY_ALPHABET = @"ABCDEFGIJKLMNOPQRSTUVWXYZ";

@interface SelectRecipientsViewController ()

@end

@implementation SelectRecipientsViewController

@synthesize contactsList,selectedContactsList,rootViewController, filteredContactsList;
@synthesize initialSelectedContacts,contactsByLastNameInitial; //TODO PC ORDER BY last name, first name
@synthesize sortedKeys,groupLocked,databaseRecords;
@synthesize groupsNamesArray, groupsList, activityIndicator, tooltipView,isShowingTooltip;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) showMenu:(id)sender withEvent: (UIEvent *)event
{
    
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.textColor = [UIColor blackColor];
    configuration.backgroundColor = [UIColor whiteColor];
    configuration.menuWidth = 200;
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    configuration.separatorColor = [delegate colorFromHex:0xfb922b];
    
    //no selection
    if(self.selectedContactsList.count == 0) {
        //OPTIONS:
        // Create Contact
        // Create Group
        [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"new_contact", nil),NSLocalizedString(@"new_group", nil)]
                          imageArray:@[@"add",@"add"]
                       configuration:configuration
                           doneBlock:^(NSInteger selectedIndex) {
                               NSLog(@"selected %ld", (long)selectedIndex);
                               if(selectedIndex == 0) {
                                   [self showAddContactController];
                               }
                               else {
                                   [self showCreateGroupAlert];
                               }
                           } dismissBlock:^{
                               
                           }];
    }
    else {
        //more than one selected
        
        //OPTIONS:
        // Create Contact
        // Create Group
        
        if(self.groupsList.count > 0) {
            //can add to group to
            //OPTIONS:
            // Add to group
            [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"new_contact", nil),NSLocalizedString(@"new_group", nil), NSLocalizedString(@"add_to_group",nil)]
                              imageArray:@[@"add",@"add",@"group"]
                           configuration:configuration
                               doneBlock:^(NSInteger selectedIndex) {
                                   NSLog(@"selected %ld", (long)selectedIndex);
                                   
                                   if(selectedIndex == 0) {
                                       [self showAddContactController];
                                   }
                                   else if(selectedIndex == 1) {
                                       [self showCreateGroupAlert];
                                   }
                                   else {
                                       [self addContactsToExistingGroup: sender];
                                   }
                               } dismissBlock:^{
                                   
                               }];
        }
        else {
            
            //same as above, just 2 options
            //OPTIONS:
            // Create Contact
            // Create Group
            [FTPopOverMenu showFromEvent:event withMenuArray:@[NSLocalizedString(@"new_contact", nil),NSLocalizedString(@"new_group", nil)]
                              imageArray:@[@"add",@"add"]
                           configuration:configuration
                               doneBlock:^(NSInteger selectedIndex) {
                                   NSLog(@"selected %ld", (long)selectedIndex);
                                   if(selectedIndex == 0) {
                                       [self showAddContactController];
                                   }
                                   else {
                                       [self showCreateGroupAlert];
                                   }
                               } dismissBlock:^{
                                   
                               }];
        }
        
    }
    
    
    
    
}

-(void) showAddContactController {
    if(self.addNewContactController==nil) {
      self.addNewContactController = [[AddContactViewController alloc] initWithNibName:@"AddContactViewController" bundle:nil];
        self.addNewContactController.contactsList = self.contactsList;
    }
    self.addNewContactController.editMode = false;
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    //we present it modally on a navigation controller to get a status bar
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.addNewContactController];
    navigationController.navigationBar.barTintColor = [delegate colorFromHex:0xfb922b];
    
    [self presentViewController:navigationController animated:YES completion:^{
        self.reload = true;
    }];
}

//THIS IS THE METHOD THAT IS CALLED FROM APPDELEGATE
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController*) viewController{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
    
        self.contactsList = [[NSMutableArray alloc] init];
        self.groupsList = [[NSMutableArray alloc] init];
        self.filteredContactsList = [[NSMutableArray alloc] init];
        
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.databaseRecords = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"select_all",@"select_all")
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(selectAllContacts:)];
        doneButton.tintColor = UIColor.whiteColor;
        //initWithTitle:NSLocalizedString(@"select_all",nil)
        self.navigationItem.leftBarButtonItem = doneButton;
        
        
        //UIBarButtonItem *addToGroupButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"add_to_group",@"add_to_group")
                                                                      //       style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        //also used to create a new contact if nothing is selected
        //WAS OK UIBarButtonItem *addToGroupButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"new_contact",@"new_contact") style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        UIBarButtonItem *optionsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"list"] style:UIBarButtonItemStyleDone target:self action:@selector(optionsClicked:event:)];
        
        optionsButton.tintColor = UIColor.whiteColor;
        
        //[addToGroupButton setTintColor:[UIColor redColor]];
    
    //initWithTitle:NSLocalizedString(@"new_contact",@"new_contact")
      //                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(addGroupClicked:)];
        
        //[addToGroupButton setCustomView:[self setupGroupButton]];
        self.navigationItem.rightBarButtonItem = optionsButton;
        //[addToGroupButton setEnabled:NO];
        [optionsButton setEnabled:YES];
        groupLocked = NO;
        
 
        NSArray* toolbarItems = [NSArray arrayWithObjects:
                                 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                               target:self
                                                                               action:@selector(goBackAfterSelection:)],nil];
        
        
        self.toolbarItems = toolbarItems;
        self.navigationController.toolbarHidden = NO;
        self.tabBarItem.image = [UIImage imageNamed:@"phone-book"];
        self.title =  NSLocalizedString(@"recipients",nil);
        
        self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        
        self.searchController.searchBar.scopeButtonTitles = [[NSArray alloc]initWithObjects:NSLocalizedString(@"contact_name",nil), NSLocalizedString(@"contact_email",nil), NSLocalizedString(@"phone_label",nil), nil];
        self.searchController.searchBar.delegate = self;
        self.searchController.searchResultsUpdater = self;
        [self.searchController.searchBar sizeToFit];
        
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.definesPresentationContext = YES;
        
        /*contents controller is the UITableViewController, this let you to reuse
         the same TableViewController Delegate method used for the main table.*/
        
        //deprecated self.searchDisplayController.delegate = self;
        //deprecated self.searchDisplayController.searchResultsDataSource = self;
        //deprecated self.searchDisplayController.searchResultsDelegate = self;
        //set the delegate = self. Previously declared in ViewController.h
        
        //deprecated self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        self.tableView.tableHeaderView = self.searchController.searchBar;
        
        self.searchData = [[NSMutableArray alloc] init];
        self.searchDataSelection = [[NSMutableArray alloc] init];
        
        self.reload = false;
        
    }
    return self;
}

-(UIImage*) drawText:(NSString*) text inImage:(UIImage*) image atPoint:(CGPoint) point {
  
 UIFont *font = [UIFont boldSystemFontOfSize:22];
 UIGraphicsBeginImageContext(image.size);
 [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
 CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
 [[UIColor grayColor] set];
 [text drawInRect:CGRectIntegral(rect) withFont:font];
 UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return newImage;
    
}

//called from main to refresh the list
-(void) reloadContacts: (NSMutableArray *) contacts {
    [self.contactsList removeAllObjects];
    [self.filteredContactsList removeAllObjects];
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
        self.filteredContactsList = [[NSMutableArray alloc] init];
        self.groupsList = [[NSMutableArray alloc] init];
        self.selectedContactsList = [[NSMutableArray alloc] init];
        self.rootViewController = viewController;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        self.navigationItem.rightBarButtonItem = doneButton;
        self.title =  NSLocalizedString(@"recipients",nil);
      
     
        self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        
        self.searchController.searchBar.scopeButtonTitles = [[NSArray alloc]initWithObjects:NSLocalizedString(@"contact_name",nil), NSLocalizedString(@"contact_email",nil), NSLocalizedString(@"phone_label",nil), nil];
        
        self.searchController.searchBar.delegate = self;
        self.searchController.searchResultsUpdater = self;
        [self.searchController.searchBar sizeToFit];
        
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.definesPresentationContext = YES;
        
        //deprecated self.searchDisplayController.delegate = self;
        //deprecated self.searchDisplayController.searchResultsDataSource = self;
        //deprecated self.searchDisplayController.searchResultsDelegate = self;
        //set the delegate = self. Previously declared in ViewController.h
        self.searchData = [[NSMutableArray alloc] init];
        self.searchDataSelection = [[NSMutableArray alloc] init];
        
        //deprecated self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        self.tableView.tableHeaderView = self.searchController.searchBar;
        
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
        self.title =  NSLocalizedString(@"recipients",nil);
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        /*the search bar widht must be > 1, the height must be at least 44
         (the real size of the search bar)*/
        
        self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
        
        self.searchController.searchBar.scopeButtonTitles = [[NSArray alloc]initWithObjects:NSLocalizedString(@"contact_name",nil), NSLocalizedString(@"contact_email",nil), NSLocalizedString(@"phone_label",nil), nil];
        
        self.searchController.searchBar.delegate = self;
        self.searchController.searchResultsUpdater = self;
        [self.searchController.searchBar sizeToFit];
        
        self.searchController.dimsBackgroundDuringPresentation = NO;
        self.definesPresentationContext = YES;
        
        self.searchDataSelection = [[NSMutableArray alloc] init];
        self.searchData = [[NSMutableArray alloc] init];
        
        //deprecated self.tableView.tableHeaderView = self.searchBar; //this line add the searchBar
        self.tableView.tableHeaderView = self.searchController.searchBar; //this line add the searchBar
        
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
    else if(self.groupsNamesArray.count > 0){
       [self.groupsNamesArray removeAllObjects];
    }
    
    if(self.groupsList.count > 0) {
        [self.groupsList removeAllObjects];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filterOption = [defaults objectForKey:SETTINGS_FILTER_OPTIONS];
    BOOL showAll = [filterOption isEqualToString:OPTION_FILTER_SHOW_ALL_KEY];
    BOOL groupsOnly = [filterOption isEqualToString:OPTION_FILTER_GROUPS_ONLY_KEY];
    //fav only?
    BOOL favoritesOnly = [filterOption isEqualToString:OPTION_FILTER_FAVORITES_ONLY_KEY];
    
    //TODO clear the groupsNamesArray ??
    NSMutableArray *workingContactsList;
    if(self.isFiltered) {
       workingContactsList = self.filteredContactsList;
    }
    else {
      workingContactsList = self.contactsList;
    }
    
    for(id contact in workingContactsList) {
        if([contact isKindOfClass:Group.class]) {
            
            Group *gr = (Group *)contact;
            
            if( gr!=nil && ( (showAll || groupsOnly ) || (favoritesOnly && gr.isFavorite) ) ) {
                
                if(![self.groupsNamesArray containsObject:gr.name]) {
                    [self.groupsList addObject:gr];
                    [self.groupsNamesArray addObject:gr.name];
                }
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
    
    if(searchText ==nil || searchText.length == 0)  {
        //nothing typed add them all
        [self.searchData addObjectsFromArray:contactsList];
    } else {
        
        for(Contact *contact in contactsList) //take the n group (eg. group1, group2, group3)
            //in the original data
        {
            //NSMutableArray *newGroup = [[NSMutableArray alloc] init];
            NSString *name = contact.name;
            NSString *lastname = contact.lastName;
            NSString *email = contact.email;
            NSString *phone = contact.phone;
            
            //name search
            if( (name!=nil || lastname!=nil) && [scope isEqualToString:@"name"]) {
                
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
                
                //email search
            }else if([scope isEqualToString:@"email"] && email!=nil) {
                
                NSRange range = [email rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (range.length > 0) { //if the substring match
                    [self.searchData addObject:contact]; //add the element
                }
                
                //phone search
            }else if([scope isEqualToString:@"phone"] && phone!=nil) {
                NSRange range = [phone rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (range.length > 0) { //if the substring match
                    [self.searchData addObject:contact]; //add the element
                }
            }
            
        }
    }
    
    // [self.searchDisplayController.searchResultsTableView reloadData];
}
/*
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
 
    
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.

    
    return YES;
}*/

/*-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}*/

//copies only the filtered contacts to the list
-(void) createFilteredList: (NSString *) filterOption {
    
    BOOL groupsOnly = [filterOption isEqualToString:OPTION_FILTER_GROUPS_ONLY_KEY];
    BOOL contactsOnly = [filterOption isEqualToString:OPTION_FILTER_CONTACTS_ONLY_KEY];
    //only fav?
    BOOL favoritesOnly = [filterOption isEqualToString:OPTION_FILTER_FAVORITES_ONLY_KEY];
    //clear first
    if(self.filteredContactsList.count > 0) {
       [self.filteredContactsList removeAllObjects];
    }
    
    for(id contact in self.contactsList) {
        BOOL isGroup = [contact isKindOfClass:Group.class];
        
        if(groupsOnly && isGroup) {
            [self.filteredContactsList addObject:contact];
        }
        else if(contactsOnly && !isGroup) {
            [self.filteredContactsList addObject:contact];
        } else if(favoritesOnly) {
            //is a group contact
            if(isGroup) {
                Group *gr = (Group *) contact;
                if(gr!=nil && gr.isFavorite) {
                    [self.filteredContactsList addObject:contact];
                }
            } else {
                //normal contact
                Contact *c = (Contact *) contact;
                if(c!=nil && c.isFavorite) {
                   [self.filteredContactsList addObject:contact];
                }
            }
        }
    }
    NSLog(@"creating filtered list with %lu elements", (unsigned long)self.filteredContactsList.count);
}

-(IBAction)refreshPhonebook:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *filterOption = [defaults objectForKey:SETTINGS_FILTER_OPTIONS];
    
    self.isFiltered = (filterOption != nil && ![filterOption isEqualToString:OPTION_FILTER_SHOW_ALL_KEY]);
    if(self.isFiltered) {
       [self createFilteredList:filterOption];
    }
    //clear first
    if ( contactsByLastNameInitial.count > 0) {
       [contactsByLastNameInitial removeAllObjects];
    }
    
    contactsByLastNameInitial = [self loadInitialNamesDictionary];

    [self checkForExistingGroups];
    
    [self.tableView reloadData];
        

}

//will group the contacts by last name initial
- (NSMutableDictionary *) loadInitialNamesDictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    self.sortedKeys = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //either by first bname or last name
    NSString *selectedOrderBySaved = [defaults objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
    if(selectedOrderBySaved == nil) {
        selectedOrderBySaved = OPTION_ORDER_BY_LASTNAME_KEY;
    }
    
    NSString *filterOption = [defaults objectForKey:SETTINGS_FILTER_OPTIONS];
    
    BOOL showAll = [filterOption isEqualToString:OPTION_FILTER_SHOW_ALL_KEY];
    BOOL groupsOnly = [filterOption isEqualToString:OPTION_FILTER_GROUPS_ONLY_KEY];
    BOOL contactsOnly = [filterOption isEqualToString:OPTION_FILTER_CONTACTS_ONLY_KEY];
    //fav only?
    BOOL favoritesOnly = [filterOption isEqualToString:OPTION_FILTER_FAVORITES_ONLY_KEY];
    
    NSLog(@"filter option %@ show all -> %d  groups only -> %d contacts only --> %d", filterOption, showAll, groupsOnly, contactsOnly);
    
    NSMutableArray *workingContactsList;
    
    if(self.isFiltered) {
        workingContactsList = self.filteredContactsList;
    }
    else {
        workingContactsList = self.contactsList;
    }
    
    for(Contact *contact in workingContactsList) {
        
        BOOL isGroup = [contact isKindOfClass:Group.class];
        NSString *initial;
        
        if(isGroup && (showAll || groupsOnly)) {
            //group
            initial = [[contact.name substringToIndex:1] uppercaseString];
        }
        else if( !isGroup && (showAll || contactsOnly) ) {
            //contact
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
        
        //make sure we have an initial
        if(initial!=nil ) {
            
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

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
 
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
    
    /*UITextField *searchField = [searchBar valueForKey:@"_searchField"];
    
    if(searchField.text.length>3) {
        //try to find a match
        for(Contact *c in contactsList) {
            NSString * name = c.name;
            if([name rangeOfString:searchField.text].location!= NSNotFound ) {
                searchField.text = name;
                return;
            }
        }
    }*/
        
}

//delete a group
-(void) deleteGroup:(Group *)group{
    
    if(group!=nil && group.name!=nil) {
        
        NSString *groupName = group.name;
        BOOL deleted = [CoreDataUtils deleteGroupDataModelByName:groupName];
        if(deleted) {
            //NSLog(@"deleted on db, group: %@",groupName);
            [group.contactsList removeAllObjects];
            [contactsList removeObject:group];
            
            [groupsList removeObject:group];
            
            for(NSString *name in groupsNamesArray) {
                if(name!=nil && groupName!=nil && [name isEqualToString:groupName]) {
                    [groupsNamesArray removeObject:name];
                }
            }
            
            
            [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
            
            [self refreshPhonebook:nil];
            
        }
    }
    
}

//delete a contact
-(void) deleteContact:(Contact *)contact{
    
    if(contact!=nil) {
        if([self isNativeContact:contact]) {
          [self searchAndDeleteContactInContactsList: contact];
        }
        else {
            
            BOOL deleted = [CoreDataUtils deleteContactDataModelByName: contact];
            if(deleted) {
                //NSLog(@"deleted on db, contact: %@",contact.name);
                [contactsList removeObject:contact];
                [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
                    setGravity:iToastGravityBottom] setDuration:2000] show];
                    
                [self refreshPhonebook:nil];
            }
        }
    }
    
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    //s[searchBar resignFirstResponder];
    //move the keyboard out of the way
    
    
    
    [searchBar resignFirstResponder];
    //[self checkIfNavigateToSection:searchBar];
}

-(void) checkIfNavigateToSection: (UISearchBar *) searchBar {
    NSString *contactFullName;
    //cannot use KVC valueForKey on native apis , from IOS 13
    if (@available(iOS 13.0, *)) {
        contactFullName = searchBar.text;
    } else {
        UITextField *searchField = [searchBar valueForKey:@"_searchField"];
        contactFullName = searchField.text;
    }
    
    
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

-(void) clearRecipients {
    //[activityIndicator startAnimating];
    rootViewController.recipientsLabel.text = @"";
    [selectedContactsList removeAllObjects];
    //[activityIndicator stopAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all",@"select_all");
        self.groupLocked = true;
        [[self tableView] reloadData];
    });
}

-(IBAction)selectAllContacts:(id)sender {
    
    //if we have all selected, remove selection
    if(selectedContactsList.count > 0) {
        
        //[activityIndicator startAnimating];
        
        rootViewController.recipientsLabel.text = @"";
        [selectedContactsList removeAllObjects];
        
        //[activityIndicator stopAnimating];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all",@"select_all");
           //self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"select_all", @"seleccionar tudo");
            //[self.navigationItem.rightBarButtonItem setEnabled:NO];
            //can add a contact
            //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact", @"new_contact");
            //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact",@"new_contact");
            
        });
        
        self.groupLocked = true;
        
    }
    else {
        
        //[activityIndicator startAnimating];
        
        [selectedContactsList removeAllObjects];
        
        for(Contact *contact in contactsList) {
            if(contact!=nil) {
                [selectedContactsList addObject:contact];
            }
            
        }
        
        //[activityIndicator stopAnimating];
        
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"selected_%@_recipients", @"num of recipients"),@(selectedContactsList.count)];
        [[[[iToast makeText:msg]
           setGravity:iToastGravityBottom] setDuration:1000] show];
        rootViewController.recipientsLabel.text = msg;
       
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"unselect_all",@"unselect_all");
            //title = NSLocalizedString(@"unselect_all", @"remover selecção");
            //can add them to the group
            //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"create_group", @"create_group");
            
        });
        self.groupLocked = false;
        
    }
        
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.tableView reloadData];
    });

}
//handle tooltips on view appear and disapear
-(void) viewDidDisappear:(BOOL)animated {
    if(self.isShowingTooltip && self.tooltipView!=nil) {
        self.isShowingTooltip = false;
        [self.tooltipView dismissAnimated:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:SHOW_HELP_TOOLTIP_RECIPIENTS]) {
        //shows help tooltip
        self.tooltipView = [[CMPopTipView alloc] initWithMessage:NSLocalizedString(@"tooltip_groups_management",nil)];
        self.tooltipView.delegate = self;
        //self.tooltipView.title = NSLocalizedString(@"message_recipients",nil);
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        self.tooltipView.backgroundColor =  [delegate colorFromHex:PREMIUM_COLOR]; //normal lite color
        [self.tooltipView  presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        self.isShowingTooltip = true;
        [defaults setBool:YES forKey:SHOW_HELP_TOOLTIP_RECIPIENTS];
    }
    
    
}

// CMPopTipViewDelegate method
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // any code, dismissed by user
    self.isShowingTooltip = false;
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentFilterSetting = [defaults objectForKey:SETTINGS_FILTER_OPTIONS];
    self.isFiltered = (currentFilterSetting != nil && ![currentFilterSetting isEqualToString:OPTION_FILTER_SHOW_ALL_KEY]);
    //always check this
    NSString *selectedOrderBySaved = [defaults objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
    if(selectedOrderBySaved == nil) {
        [defaults setObject:OPTION_ORDER_BY_LASTNAME_KEY forKey:SETTINGS_PREF_ORDER_BY_KEY];
    }
    
    //[self checkAppearance];
    
    initialSelectedContacts = selectedContactsList.count;
    groupLocked = false;
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    if(selectedContactsList.count>1) {
        //can add a new group
        groupLocked = false;
        //[self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"create_group",@"create_group")];
    }
    else {
        //cannot add a group only a contact
        groupLocked = true;
        //[self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"new_contact",@"new_contact")];
    }
    
    BOOL isForceReloadSet = [defaults boolForKey: @"force_reload"];
    //from adding new contact, updating favorites
    if(self.reload || isForceReloadSet) {
        //avoid refresh again
        if(isForceReloadSet) {
             [defaults setBool:false forKey: @"force_reload"];
        }
        //refresh
        [self refreshPhonebook:nil];
        
    }
    else {
        //check if the setting changed or something
        
        BOOL forceReload = [defaults boolForKey:SETTINGS_PREF_ORDER_BY_KEY_FORCE_RELOAD];
        
        
        NSString *previousFilterSetting = [defaults objectForKey:SETTINGS_FILTER_PREVIOUS_OPTIONS];
        NSLog(@"previous filter -> %@ , current filter -> %@",previousFilterSetting, currentFilterSetting);
        BOOL filterChanged = false;
        if(![currentFilterSetting isEqualToString:previousFilterSetting]) {
            filterChanged = true;
        }
        //sorting option changed
        if(forceReload) {
            
            NSString *current = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
            NSString *other = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY_PREVIOUS_SETTINGS];
            
            NSLog(@"other %@ current %@", other, current);
            //if they are different then force it too
            if(current!=nil && other!=nil && ![current isEqualToString:other]){
                NSLog(@"different force it");
                [self refreshPhonebook:nil];
            }
        }//maybe filter changed?
        else if(filterChanged) {
            [self refreshPhonebook:nil];
        }
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
    
    if([self.groupsNamesArray containsObject:name]) {
        return YES;
    }
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
    
    if (self.searchController!=nil && self.searchController.active) {
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
    if (self.searchController!=nil && self.searchController.active) {
        return self.searchData.count;
    } else {
        if(sortedKeys.count == 0 || section >= sortedKeys.count) {
            return 0;
        }
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
        return array.count;
    }
    
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) { //UITableViewCellStyleSubtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    } else {
        //reuse cell clear views
        // Prepare cell for reuse

        // Remove subviews from cell's contentView
        for (UIView *view in cell.contentView.subviews)
        {
            // Remove only the appropriate views
            if ([view isKindOfClass:[UIImageView class]])
            {
                [view removeFromSuperview];
            }
        }
    }
    
    PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
    
    if([self isDarkModeEnabled]) {
        
        cell.contentView.backgroundColor = [delegate defaultTableColor: true ];//1c1c1e
    } else {
        cell.contentView.backgroundColor  = [UIColor clearColor ];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    //avoid crash if list is empty
    if( (sortedKeys.count == 0 || section >= sortedKeys.count) && (self.searchController!=nil && self.searchController.active) ) {//because of
        return cell;
    }
    
    NSString *key = nil;
    NSMutableArray *array = nil;
    
    BOOL isGroup = NO;
    
    
    Contact *contact;
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    
    //deprecated if (tableView == self.searchDisplayController.searchResultsTableView) {
    
    if (self.searchController!=nil && self.searchController.active && row < self.searchData.count) {
        
        contact = [self.searchData objectAtIndex:row];
        
    } else {
        key = [sortedKeys objectAtIndex:section];
        array = [contactsByLastNameInitial objectForKey:key];
        contact = [array objectAtIndex:row];
    }
    
    if([contact isKindOfClass:Group.class]) {
        Group *thisOne = (Group *) contact;
        cell.detailTextLabel.text = [NSString stringWithFormat: @"Group (%lu %@)",(unsigned long)thisOne.contactsList.count, NSLocalizedString(@"members", nil)  ];
        isGroup = YES;
        cell.textLabel.text = contact.name;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:(16.0)];
        
        if(thisOne.isFavorite) {
           cell.textLabel.text = [NSString stringWithFormat:@"%@ \U0001F9E1", cell.textLabel.text];
        }
        
        NSString *text = thisOne.name;
        text = [[text substringToIndex:1] uppercaseString];
        UIImage  *img = [UIImage imageNamed:@"user"];
        img = [self drawText:text inImage:img atPoint:CGPointMake(24, 16)];
        cell.imageView.image = img;
        cell.imageView.layer.cornerRadius = 20.0;
        cell.imageView.layer.masksToBounds = true;
        
    }
    else {
        
        BOOL hasBoth = (contact.lastName!=nil && contact.name!=nil);
        
        NSString *selectedOrderBySaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
        if(selectedOrderBySaved == nil) {
            selectedOrderBySaved = OPTION_ORDER_BY_LASTNAME_KEY;
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:(16.0)];
        
        //has both
        if(hasBoth) {
            
            //check if last name is already include in name
            NSRange range = [contact.name rangeOfString:contact.lastName
                                                options:NSCaseInsensitiveSearch];
            if (range.length == 0) { //if the substring did not match
                if([selectedOrderBySaved isEqualToString: OPTION_ORDER_BY_LASTNAME_KEY]) {
                    //last name first name
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.lastName,contact.name];
                }
                else {
                    // first name last name
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contact.name,contact.lastName];
                }
                
            }
            else {
                //just the first name
                cell.textLabel.text = contact.name;
            }
            
            
            
        }
        else if(contact.name!=nil) {
            cell.textLabel.text = contact.name;
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
        
        if(contact.isFavorite) {
           cell.textLabel.text = [NSString stringWithFormat:@"%@ \U0001F9E1", cell.textLabel.text];
        }
        
        //add a rounded photo
        if(contact.photo!=nil) {
            
            cell.imageView.layer.cornerRadius = 20;
            cell.imageView.layer.masksToBounds = true;
            cell.imageView.clipsToBounds = true;
            
            if( [self isNotSquaredPhoto:contact.photo] && ( (contact.photo.size.width >= 300.0 ) && (contact.photo.size.height >= 300.0 ) )  ) {
                
                cell.imageView.image = [self imageByCroppingImage:contact.photo toSize:CGSizeMake(300, 300)];
                //portrait image
                if(contact.photo.size.height > contact.photo.size.width) {
                    cell.imageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                } else {
                    cell.imageView.transform = CGAffineTransformMakeRotation(0);
                }
            } else {
                cell.imageView.image = contact.photo;
                cell.imageView.transform = CGAffineTransformMakeRotation(0);
            }
              
        }
        else {
            cell.imageView.transform = CGAffineTransformMakeRotation(0);
            UIImage  *img = [UIImage imageNamed:@"user"];
            
            //ordered by last name (default) ?
            NSString *text = @"";
            
            if([selectedOrderBySaved isEqualToString: OPTION_ORDER_BY_LASTNAME_KEY] ) {
                text =  [self getInitialsFromContact:contact.lastName andLastString:contact.name];
            }
            else {
                text =  [self getInitialsFromContact:contact.name andLastString:contact.lastName];
            }
            
            if(hasBoth && contact.name.length > 0 && contact.lastName.length > 0 ) {
                img = [self drawText:text inImage:img atPoint:CGPointMake(12, 16)];
            }
            else {
                img = [self drawText:text inImage:img atPoint:CGPointMake(24, 16)];
            }
            
            cell.imageView.image = img;
            cell.imageView.layer.cornerRadius = 20.0;
            cell.imageView.layer.masksToBounds = true;
            
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
        //if(isGroup) {
        //and not selected
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        //}
        //else {
        //    cell.accessoryType = UITableViewCellAccessoryNone;
        //}
        
    }
    
    
    if([self isDarkModeEnabled]) {
        
        cell.accessoryView.backgroundColor = [delegate defaultTableColor: true ];// [delegate colorFromHex:0x1c1c1e];
    } else {
        cell.accessoryView.backgroundColor  = [UIColor clearColor ];
    }
    
    
    return cell;
}

-(NSString *) getInitialsFromContact: (NSString *) firstString andLastString: (NSString *) lastString {
    
    if(firstString != nil && firstString.length > 0) {
        if(lastString != nil && lastString.length > 0) {
            
            //return both
            return [[NSString stringWithFormat:@"%@ %@", [firstString substringToIndex:1] , [lastString substringToIndex:1] ] uppercaseString];
        }
        else {
            //just the first
            return [[firstString substringToIndex:1] uppercaseString];
        }
    }
    else {
        //first is nil
        if(lastString != nil && lastString.length > 0) {
            //just the 2nd then
            return [[lastString substringToIndex:1] uppercaseString];
        }
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    Contact *contact = nil;
    //it was crashing before
    if (self.searchController!=nil && self.searchController.active) {
        
        contact = [self.searchData objectAtIndex:indexPath.row];
    }
    else {
        
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
        contact = [array objectAtIndex:row];
    }
    //show it now
    
    if(contact!=nil && [contact isKindOfClass:Group.class]) {
        Group *group = (Group*)contact;
        
        //get the groupModel
        GroupDataModel *groupModel = [CoreDataUtils fetchGroupDataModelByName: group.name];
        
        GroupDetailsViewController *detailViewController = [[GroupDetailsViewController alloc] initWithNibName:@"GroupDetailsViewController" bundle:nil group:group andModel:groupModel];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else {
        
        ContactDetailsViewController *detailViewController = nil;
        
        ContactDataModel *theModel = [CoreDataUtils fetchContactDataModelByName: contact.name];
        if(theModel == nil) {
            //try native search
            CNMutableContact *modelNative = [self searchContactOnNativeAddressBook:contact];
            if(modelNative!=nil) {
                contact.isNative = true;
                detailViewController = [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetailsViewController" bundle:nil contact:contact andModel: modelNative];
            } else {
                contact.isNative = false;
                detailViewController = [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetailsViewController" bundle:nil contact:contact andModel:nil];
            }
        }
        else {
            contact.isNative = false;
            detailViewController = [[ContactDetailsViewController alloc] initWithNibName:@"ContactDetailsViewController" bundle:nil contact:contact andModel:theModel];
        }
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        // ...
        // Pass the selected object to the new view controller.
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
    
}

-(BOOL) isNativeContact:(Contact *) contact {
    return (contact!=nil && [contact isNativeContact ]);
}

#pragma mark - Table view delegate

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *header;
    NSInteger height = 32;
    if(self.searchController!=nil && self.searchController.active) {
        height =  44;
    }
    else if(section == 0)
    {
        height = UITableViewAutomaticDimension ;
    }
    
    header = [[UITableViewHeaderFooterView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, height)];
    
    header.contentView.backgroundColor = self.tableView.backgroundColor;
    
    return header;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UITableViewHeaderFooterView *footer = [[UITableViewHeaderFooterView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width, UITableViewAutomaticDimension)];
    
    footer.contentView.backgroundColor  = self.tableView.backgroundColor;
    
    return footer;
}

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
    if (self.searchController!=nil && self.searchController.active) {
        
        //self.searchBar.showsCancelButton = false;
        //self.searchBar.showsSearchResultsButton = true;
        contact = [self.searchData objectAtIndex:indexPath.row];
        
        //Contact *contactOnRealTable;
        //get the corresponding cell on the real table
        
        //default is last name
        NSString *sortByNameOrLastName = contact.lastName;
        //but check the setting in place
        NSString *selectedOrderBySaved = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PREF_ORDER_BY_KEY];
        //maybe was name after all?
        if([selectedOrderBySaved isEqualToString: OPTION_ORDER_BY_FIRSTNAME_KEY]) {
            sortByNameOrLastName = contact.name;
        }
        
        //NSString *lastName = contact.lastName;
        if(sortByNameOrLastName!=nil && sortByNameOrLastName.length > 0) {
            NSString *key = [NSString stringWithFormat:@"%c", [sortByNameOrLastName characterAtIndex:0]];
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
            
            
            
            [self.searchController setActive:false];
            
            
        }
        
    } else {
        
        NSString *key = [sortedKeys objectAtIndex:section];
        NSMutableArray *array = (NSMutableArray *) [contactsByLastNameInitial objectForKey:key];
        contact = [array objectAtIndex:row];
  
    }
    /***************************/
    
    
    
    
   if(![selectedContactsList containsObject:contact]) {
       
       if(self.selectedContactsList.count >= 10 &&  ![[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
           [self showAlertBox:NSLocalizedString(@"lite_only_10_recipients", nil)];
       }
       else {
          [selectedContactsList addObject:contact];
       }
       
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
                //self.navigationItem.rightBarButtonItem.title  = NSLocalizedString(@"new_group",@"new_group");
            }
            else {
                //only 1 selected, cannot create a group
                //TODO PC if i have groups show the option to add to an existing group
                self.groupLocked = true;
                
                //if(self.groupsList.count > 0) {
                //    self.navigationItem.rightBarButtonItem.title  = NSLocalizedString(@"add_to_group",@"add_to_group");
                //}
        
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
            //self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"new_contact",@"new_contact");;
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
    
    
    if(self.searchController!=nil && self.searchController.active) {
        return @"";
    }

    if(sortedKeys.count > 0 && section < sortedKeys.count) {
        NSString *key = [sortedKeys objectAtIndex:section];
        return key;
    }
    return @"";
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(self.searchController!=nil && self.searchController.active)
        return 44;
    
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

/**
 //add group to another group
 if([selected isKindOfClass:Group.class]) {
 
 //TODO PC CHECK
 
 //cast contact to group
 Group *theSelected = (Group *) selected;
 
 
 //now get the real contacts on this group
 for(Contact *contact in theSelected.contactsList) {
 
 ContactDataModel *contactModelToAdd = nil;
 bool found = false;
 // get all the contacts by this name and find the best match
 NSMutableArray *array = [CoreDataUtils fetchAllContactsDataModelByName: contact.name];
 for(ContactDataModel *contactModel in array) {
 
 if ([self isSameContact:contactModel contact:contact]) {
 contactModelToAdd = contactModel;
 //found the core data match for this selected contact in this group
 //add to core data
 [groupModel addContactsObject:contactModelToAdd];
 [contactModelToAdd addGroupObject:groupModel];
 [group.contactsList addObject:contact];
 found = true;
 NSLog(@"FOUND A MATCH ASSIGNING THIS ONE %@",contactModelToAdd.name);
 break; //break the inner for loop
 }
 }
 if(!found || contactModelToAdd==nil) {
 NSLog(@"DID NOT FOUND A MATCH, creating a new contact on core data for %@",contactModelToAdd.name);
 //not on core data, maybe internal address book one
 contactModelToAdd = [self prepareModelFromContact: managedObjectContext :contact];
 
 [groupModel addContactsObject:contactModelToAdd];
 [contactModelToAdd addGroupObject:groupModel];
 
 [group.contactsList addObject:contact];
 }
 
 }
 
 }
 */

-(void) removeContactFromGroup: (NSString *) groupName contact: (Contact *) contact {
    
 
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //we assume groups should all have different names!!!! TODO maybe warn the user is already exists? i think we do that already!!
    [request setEntity:[NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", groupName];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
    
    //The array results contains all the managed objects contained within the sqlite file. If you want to grab a specific object (or more objects) you need to use a predicate with that request. For example:
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", @"Some Title"];
    //[request setPredicate:predicate];
    
    if(error!=nil) {
        NSLog(@"Error: %@", error.description);
        return;
    }
    
    for(Group *group in groupsList) {
        if([group.name isEqualToString:groupName] && !group.isNative) {
            //do not remove from native icloud groups
            [group.contactsList removeObject:contact];
        }
    }
    
    if(results.count > 0 && contact!=nil) {
        //
        GroupDataModel *groupModel = [results objectAtIndex:0];
        //OK found the group (just get the first anyway
        
        if(groupModel!=nil && groupModel.contacts!=nil) {
            
            ContactDataModel *cModelToRemove = nil;
            
            for( ContactDataModel *cModel in groupModel.contacts) {
                //contact already exists on group
                if( cModel!=nil &&  [self isContactModel:cModel sameAsContact:contact]) {
                    
                    cModelToRemove = cModel;
                    break; //break the loop cause i cannot remove while iterating it
                }
            }
            
            if(cModelToRemove!=nil) {
                //only remove it now, outside for loop
                [groupModel.contacts removeObject:cModelToRemove];
                [cModelToRemove removeGroupObject:groupModel];
                
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
                    [[[[iToast makeText:NSLocalizedString(@"removed",@"removed")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                }
                [self refreshPhonebook:nil];
            }
            
        }//end groupModel!=nil
        
        
    }//end results.count > 0 && contact!=nil
    

}
//check if we are talking about the same contact
-(BOOL) isContactModel: (ContactDataModel *) model sameAsContact: (Contact *)contact {
 
    if(model == nil && contact == nil) {
        return false;
    }
    if([model.name isEqualToString:contact.name]) {
        //could be
        if(model.lastname!=nil && contact.lastName!=nil) {
            if([model.lastname isEqualToString:contact.lastName]) {
                return true;
            }
            else {
                return false;
            }
        }
        if(model.email!=nil && contact.email!=nil) {
            if([model.email isEqualToString:contact.email]) {
                return true;
            }
            else {
                return false;
            }
        }
        
        if(model.phone!=nil && contact.phone!=nil) {
            if([model.phone isEqualToString:contact.phone]) {
                return true;
            }
            else {
                return false;
            }
        }
        //ok assum the same if they have the same name only
        return true;
    }
           
   return false;
}

//do i only have native groups on the list of groups?
-(BOOL) onlyHasNativeiCloudGroups {
    //remove any native groups from the list
    NSUInteger num = groupsList.count;
    NSUInteger countNative = 0;
    for(Group *group in groupsList) {
        if(group.name!=nil && group.isNative) {
            countNative++;
        }
    }
    return countNative > 0 && countNative == num;
}

-(void) refreshAfterContactToGroupAssignment {
    //if just added a group i clear the selection
    [selectedContactsList removeAllObjects];
    //refresh the view
    [self refreshPhonebook:nil];
    //will also add to the list of groups
}

//add multiple contacts to a group
-(void) addMultipleContactsToGroup: (NSString *) groupName {
    
    for(int i = 0; i < self.selectedContactsList.count; i++) {
        Contact *c = [self.selectedContactsList objectAtIndex:i];
        [self addContactToGroup: groupName contact:c isSingleInsert:false];
    }
    //clears the list and refreshes the phone book
    [self refreshAfterContactToGroupAssignment];
}

//TODO PC fetch the group model, the contact model and chage on CORE DATA + reflect changes on local lists
-(void) addContactToGroup: (NSString *) groupName contact: (Contact *) contact isSingleInsert: (BOOL) single {
    
    NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext]];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", groupName];
    //[request setPredicate:predicate];
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
                //NSLog(@"OK FOUND THE GROUP");
                //find the equivalent group, on local group list
                Group *group = [self getGroupByName:groupName];
                if(group !=nil) {
                    for( Contact *c in [group contactsList]) {
                        //contact already exists on group
                        if([c isEqual:contact]) {
                            //NSLog(@"ignore contact exists");
                            //TODO hide this message
                            [[[[iToast makeText:NSLocalizedString(@"contact_already_exists",@"contact_already_exists")]
                               setGravity:iToastGravityBottom] setDuration:2000] show];
                            return;
                        }
                    }
                }
                //Adding a group here, so we will add all the contacts inside that group instead
                if(group != nil && [contact isKindOfClass:Group.class]) {
                    //TODO above
                    //NSLog(@"The other model to add to group %@ is another group named %@",groupName,contact.name);
                    for(GroupDataModel *theOtherModel in results) {
                        //also make sure we do not add to the same group
                        //NSLog(@"found group named: %@", theOtherModel.name);
                        if([theOtherModel.name isEqualToString:contact.name]) {
                            //NSLog(@"OK, found the contact that is a group ( %@) gonna fetch all its contacts", contact.name);
                            
                            if(![theOtherModel.name isEqualToString:groupName]) {
                                //found the contact group to add, add all his contacts to the groupModel
                                //NSLog(@"the other group size of contacts is: %lu", theOtherModel.contacts.count);
                                for(ContactDataModel *cModel in theOtherModel.contacts){
                                    //NSLog(@"ADDING CONTACT %@ to group %@ ", cModel.name, groupName );
                                    [self performContactToGroupAssignment:managedObjectContext contactModel: cModel groupModel:groupModel groupName:groupName contact: [self getContactFromContactModel:cModel]];
                                }
                                return;
                            }
                            else {
                                //NSLog(@"SKIP ADDING contacts from %@ on group %@", theOtherModel.name,groupName);
                            }
                            
                            
                        }
                    }
                    if(single) {
                        [self refreshAfterContactToGroupAssignment];
                    }
                    return;
                }
                
                //------------------
                // get all the contacts by this name and find the best match
                NSMutableArray *array = [CoreDataUtils fetchAllContactsDataModelByName: contact.name];
                //NSLog(@"FETCH RESULTS FOR NAME %@",contact.name);
                BOOL foundMatch = false;
                if(array !=nil) {
                    //NSLog(@"GOT CONTACTS RESULTS COUNT %lu ",(unsigned long)array.count);
                    ContactDataModel *contactModel = nil;
                    //find the correct contact and add it to the group (no need to create a new one o core data)
                    if(array.count == 1) {
                        contactModel = [array objectAtIndex:0];
                        foundMatch = true;
                    }
                    else {
                        for(ContactDataModel *res in array) {
                            if(res.lastname !=nil && contact.lastName!=nil && [res.lastname isEqualToString:contact.lastName]) {
                                contactModel = res;
                                foundMatch = true;
                                break;
                            }
                            else if(res.email !=nil && contact.email!=nil && [res.email isEqualToString:contact.email]) {
                                contactModel = res;
                                foundMatch = true;
                                break;
                            }
                            else if(res.phone !=nil && contact.phone!=nil && [res.phone isEqualToString:contact.phone]) {
                                contactModel = res;
                                foundMatch = true;
                                break;
                            }
                        }
                    }
                    
                    //TODO PC ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :contact];
                    //check again, if the contact is not on CORE DDATA it return nothing (need to create the core data model but then it
                    //gets duplicated, how to fix??
                    //DUPLICATE ON CORE DATA and hide it from the list if already exists
                    if(contactModel !=nil) {
                        [self performContactToGroupAssignment:managedObjectContext contactModel: contactModel groupModel:groupModel groupName:groupName contact:contact];
                        if(single) {
                            [self refreshAfterContactToGroupAssignment];
                        }
                        //------------------
                    }//else NSLog(@"IS NULLLLLL MAYBE IS NATIVE");
                    else {
                        // native contact? ok insert it anyway
                        ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :contact];
                        [self performContactToGroupAssignment:managedObjectContext contactModel:(ContactDataModel *)contactModel groupModel:groupModel groupName:groupName contact:contact];
                        if(single) {
                            [self refreshAfterContactToGroupAssignment];
                        }
                    }
                }
                else {
                    //no contacts on core data? insert a new one then
                    ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :contact];
                    [self performContactToGroupAssignment:managedObjectContext contactModel:(ContactDataModel *)contactModel groupModel:groupModel groupName:groupName contact:contact];
                    if(single) {
                        [self refreshAfterContactToGroupAssignment];
                    }
                }
                
            }
        }
        
    }
    
}

-(void) showAlertBox:(NSString *) msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Easy Message"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(Contact *) getContactFromContactModel:(ContactDataModel *) model {
    Contact *c = [[Contact alloc] init];
    c.name = model.name;
    c.lastName = model.lastname;
    c.phone = model.phone;
    c.email = model.email;
    /*TODOS
    if(model.alternateEmails!=nil && model.alternateEmails.length > 0) {
        c.alternateEmails = [[NSMutableArray alloc] init];
        [c.alternateEmails addObjectsFromArray:[model.alternateEmails componentsSeparatedByString: @";"]];
    }
    
    if(model.alternatePhones!=nil && model.alternatePhones.length > 0) {
        c.alternatePhones = [[NSMutableArray alloc] init];
        [c.alternatePhones addObjectsFromArray:[model.alternatePhones componentsSeparatedByString: @";"]];
    }*/
    return c;
}

-(BOOL) performContactToGroupAssignment: (NSManagedObjectContext *) managedObjectContext contactModel: (ContactDataModel *)contactModel groupModel: (GroupDataModel *) groupModel groupName:(NSString *) groupName contact: (Contact *) contact {
    
    
    if(groupModel.contacts.count >= 5 &&  ![[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
        [self showAlertBox:NSLocalizedString(@"lite_only_5_contacts_per_group", nil)];
        return false;
    }
    
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
        
        //WAS OK
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
    }
    
    return OK;
}

//adds a contact to an existing group
-(void) addContactsToExistingGroup:(id)sender {
    NSMutableArray *options = [[NSMutableArray alloc] init];
    [options addObjectsFromArray:self.groupsNamesArray];
    
    for(int i = 0; i < self.selectedContactsList.count; i++) {
        Contact *c = [self.selectedContactsList objectAtIndex:i];
        if([c isKindOfClass:Group.class]) {
            //need to hide this name
            NSLog(@"hide group %@ from options ", c.name);
            [options removeObject:c.name];
        }
    }
    
    //if no options do not show it, otherwise it might crash on "done" with nothing selected
    //ex: index 0 beyond bounds for empty array'
    //TODO refactor this, cause now i can have more then 1 contact selected
    //at least 1 group and not all native
    BOOL onlyNativeOnes = [self onlyHasNativeiCloudGroups];
    if(options.count > 0 && !onlyNativeOnes) {
        [PickerView showPickerWithOptions:options sender:sender title:NSLocalizedString(@"select_group", @"select_group") selectionBlock:^(NSString *selectedOption) {
            //was only adding the first one
            if(self.selectedContactsList.count > 1) {
                [self addMultipleContactsToGroup:selectedOption];
            } else if(selectedContactsList.count == 1) {
                //just add 1
                Contact *c = [self.selectedContactsList objectAtIndex:0];
                [self addContactToGroup: selectedOption contact:c isSingleInsert:true];
            }
        }];
    } else if( options.count > 0 && onlyNativeOnes) {
        [self showAlertBox:NSLocalizedString(@"native_groups_support", nil)];
    }
    
    
}

//show the input new group dialog
-(void) showCreateGroupAlert {
    UIAlertView * alert;
    //adding a group allowed
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"new_group",@"new_group") message:NSLocalizedString(@"enter_group_name",@"enter_group_name") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"save",@"save"),nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)optionsClicked:(id)sender event:(UIEvent *)event{
    [self showMenu:sender withEvent: event];
}

//show the input new group dialog
/*
- (IBAction)addGroupClicked:(id)sender{

    //adding a contact
    if(self.groupLocked) {
        if(self.selectedContactsList.count == 1) {
            
            NSMutableArray *options = [[NSMutableArray alloc] init];
            [options addObjectsFromArray:self.groupsNamesArray];
            Contact *c = [self.selectedContactsList objectAtIndex:0];
            if([c isKindOfClass:Group.class]) {
                //need to hide this name
                NSLog(@"hide group %@ from options ", c.name);
                [options removeObject:c.name];
            }
            //add a contact to an existing group
            [PickerView showPickerWithOptions:options sender:sender title:NSLocalizedString(@"select_group", @"select_group") selectionBlock:^(NSString *selectedOption) {
                    //TODO
                    Contact *c = [self.selectedContactsList objectAtIndex:0];
                    [self addContactToGroup: selectedOption contact:c];
                }];
            /**
             has presented a UIAlertController (<PickerAlertController: 0x102806000>) of style UIAlertControllerStyleActionSheet from UITabBarController (<UITabBarController: 0x101809600>). The modalPresentationStyle of a UIAlertController with this style is UIModalPresentationPopover. You must provide location information for this popover through the alert controller's popoverPresentationController. You must provide either a sourceView and sourceRect or a barButtonItem.  If this information is not known when you present the alert controller, you may provide it in the UIPopoverPresentationControllerDelegate method -prepareForPopoverPresentation.'
             */
 /*
        }
        else {
            [self showAddContactController];
        }
    }
    else {
        
        if(self.groupsList.count >= 5 &&  ![[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_PREMIUM_UPGRADE]) {
            [self showAlertBox:NSLocalizedString(@"lite_only_5_groups", nil)];
        }
        else {
            //adding a new group is allowed
            UIAlertView * alert;
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"new_group",@"new_group") message:NSLocalizedString(@"enter_group_name",@"enter_group_name") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel",@"cancel") otherButtonTitles:NSLocalizedString(@"save",@"save"),nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
        
        
    }
    
}
*/

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

//https://stackoverflow.com/questions/32835853/cncontactstore-retrieve-a-contact-by-email-address
//https://www.appsfoundation.com/post/create-edit-contacts-with-ios-9-contacts-ui-framework
-(void)loadAllContactsList {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if( status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
        [self showPermissionsMessage];
        
    }
    else
    {
        //Create repository objects contacts
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        //Select the contact you want to import the key attribute  ( https://developer.apple.com/library/watchos/documentation/Contacts/Reference/CNContact_Class/index.html#//apple_ref/doc/constant_group/Metadata_Keys )
        
        NSArray *keys = [[NSArray alloc]initWithObjects:CNContactIdentifierKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactPhoneNumbersKey, /*CNContactViewController.descriptorForRequiredKeys,*/ nil];
        
        // Create a request object
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        request.predicate = nil;
        
        [contactStore enumerateContactsWithFetchRequest:request
                                                  error:nil
                                             usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop)
         {
             // Contact one each function block is executed whenever you get
             NSString *phoneNumber = @"";
             if( contact.phoneNumbers)
                 phoneNumber = [[[contact.phoneNumbers firstObject] value] stringValue];
             
             NSLog(@"phoneNumber = %@", phoneNumber);
             NSLog(@"givenName = %@", contact.givenName);
             NSLog(@"familyName = %@", contact.familyName);
             NSLog(@"email = %@", contact.emailAddresses);
             
             
             //[contactList addObject:contact];
         }];
        
        // [contactTableView reloadData];
    }
    
}

/**
 * Delete the contact from the actual device address book
 */
//https://www.oreilly.com/library/view/ios-9-swift/9781491936689/ch04.html
//TODO PC check this search method
-(void)searchAndDeleteContactInContactsList: (Contact *)contact {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if( status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
        [self showPermissionsMessage];
    }
    else
    {
        //Create repository objects contacts
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        //Select the contact you want to import the key attribute  ( https://developer.apple.com/library/watchos/documentation/Contacts/Reference/CNContact_Class/index.html#//apple_ref/doc/constant_group/Metadata_Keys )
        
        NSArray *keys = [[NSArray alloc]initWithObjects:CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataAvailableKey, CNContactImageDataKey, CNContactPhoneNumbersKey, CNContactViewController.descriptorForRequiredKeys, nil];
        
        // Create a request object
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        request.predicate = nil;
        //trim start and end white spaces
        if( (contact.name!=nil &&  [contact.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) ||
           ( contact.lastName!=nil && [contact.lastName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 ) ) {
            request.predicate = [CNContact predicateForContactsMatchingName: ( contact.name!=nil ? contact.name : contact.lastName) ];
        }
        else if(contact.email!=nil) {
            if (@available(iOS 11.0, *)) {
                request.predicate = [CNContact predicateForContactsMatchingEmailAddress:contact.email];
            } else {
                // Fallback on earlier versions
                [[[[iToast makeText:NSLocalizedString(@"error_deleting_contact", @"error_deleting_contact")]
                   setGravity:iToastGravityBottom] setDuration:2000] show];
                return;
            }
        } else if(contact.phone!=nil) {
            if (@available(iOS 11.0, *)) {
                CNPhoneNumber *num = [[CNPhoneNumber alloc] initWithStringValue:contact.phone];
                request.predicate = [CNContact predicateForContactsMatchingPhoneNumber: num];
            } else {
                // Fallback on earlier versions
                [[[[iToast makeText:NSLocalizedString(@"error_deleting_contact", @"error_deleting_contact")]
                   setGravity:iToastGravityBottom] setDuration:2000] show];
                return;
            }
        } else {
            [[[[iToast makeText:NSLocalizedString(@"error_deleting_contact", @"error_deleting_contact")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
            return;
        }
        
        
        //it might delete more than 1
        NSError* fetchError = nil;
        NSArray *contacts = [contactStore unifiedContactsMatchingPredicate:request.predicate keysToFetch:keys error:&fetchError];
        
        CNMutableContact* copyOfContact = nil;
        //we just grab the first one
        if(contacts.count > 0) {
            
            if(contacts.count == 1) {
                copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
            } else {
                
                //more than 1
                //we have more than 1 result
                int index = 0;
                BOOL foundMatch = false;
                for(CNMutableContact *resultContact in contacts) {
                    
                    if(foundMatch) {
                        break;
                    }
                    //CHECK OTHER FIELDS
                    if(contact.email!= nil && resultContact.emailAddresses!=nil) {
                        //email
                        for(CNLabeledValue <CNPhoneNumber *> *email in resultContact.emailAddresses) {
                            
                            NSString *stringValue = email.value.stringValue;
                            if(stringValue!=nil && [stringValue isEqualToString:contact.email]) {
                                foundMatch = true;
                                break;
                            }
                        }
                        
                    }else if(contact.phone!= nil && resultContact.phoneNumbers!=nil) {
                        //phone
                        for(CNLabeledValue <CNPhoneNumber *> *phone in resultContact.phoneNumbers) {
                            
                            NSString *stringValue = phone.value.stringValue;
                            if(stringValue!=nil && [stringValue isEqualToString:contact.phone]) {
                                foundMatch = true;
                                break;
                            }
                        }
                    }
                    
                    if(foundMatch && index < contacts.count) {
                        copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:index] mutableCopy] ;
                    }
                    //otherwise increase index to next
                    index++;
                }
            }
            
            
            //if still here, grabe the first as default
            if(copyOfContact == nil) {
                copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
            }
            //-------------------------------------------------
            CNSaveRequest *edit = [[CNSaveRequest alloc] init];
            
            // Contact one each function block is executed whenever you get
            
            NSError* contactError = nil;
            @try {
                [edit deleteContact:copyOfContact];
                [contactStore executeSaveRequest:edit error: &contactError];
                if(contactError==nil) {
                    NSLog(@"deleted on db, contact: %@",copyOfContact.givenName);
                    [contactsList removeObject:contact];
                    
                    [[[[iToast makeText:NSLocalizedString(@"deleted", @"deleted")]
                       setGravity:iToastGravityBottom] setDuration:2000] show];
                    
                    [self refreshPhonebook:nil];
                }
                
            }@catch(NSException *e) {
                NSLog(@"Error deleting contact %@", copyOfContact.givenName);
                [[[[iToast makeText:NSLocalizedString(@"error_deleting_contact", @"error_deleting_contact")]
                   setGravity:iToastGravityBottom] setDuration:2000] show];
            }
            
        }else {
            //no results found!!
            [[[[iToast makeText:NSLocalizedString(@"error_deleting_contact", @"error_deleting_contact")]
               setGravity:iToastGravityBottom] setDuration:2000] show];
        }
        
    }
    
}

//search contact on on Contacts framework
-(CNMutableContact*) searchContactOnNativeAddressBook: (Contact *) contact {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if( status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
        [self showPermissionsMessage];
    }
    else
    {
        //Create repository objects contacts
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        //Select the contact you want to import the key attribute  ( https://developer.apple.com/library/watchos/documentation/Contacts/Reference/CNContact_Class/index.html#//apple_ref/doc/constant_group/Metadata_Keys )
        
        NSArray *keys = [[NSArray alloc]initWithObjects:CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataAvailableKey, CNContactImageDataKey, CNContactPhoneNumbersKey, CNContactViewController.descriptorForRequiredKeys, nil];
        
        // Create a request object
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
        request.predicate = nil;
        
        if(contact.name!=nil || contact.lastName!=nil) {
            request.predicate = [CNContact predicateForContactsMatchingName: ( contact.name!=nil ? contact.name : contact.lastName) ];
        }
        
        //it might delete more than 1
        NSError* fetchError = nil;
        NSArray *contacts = [contactStore unifiedContactsMatchingPredicate:request.predicate keysToFetch:keys error:&fetchError];
        
        //we just grab the first one matching this name
        if(contacts.count > 0) {
            CNMutableContact* copyOfContact = nil;
            
            if(contacts.count == 1) {
                copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
                return copyOfContact;
            }
            
            //we have more than 1 result
            int index = 0;
            BOOL foundMatch = false;
            for(CNMutableContact *resultContact in contacts) {
                //CHECK OTHER FIELDS
                if(contact.email!= nil && resultContact.emailAddresses!=nil) {
                   //email
                    for(CNLabeledValue <CNPhoneNumber *> *email in resultContact.emailAddresses) {
                        
                        NSString *stringValue = email.value.stringValue;
                        if(stringValue!=nil && [stringValue isEqualToString:contact.email]) {
                            foundMatch = true;
                            break;
                        }
                    }
                    
                }else if(contact.phone!= nil && resultContact.phoneNumbers!=nil) {
                   //phone
                    for(CNLabeledValue <CNPhoneNumber *> *phone in resultContact.phoneNumbers) {
                        
                       NSString *stringValue = phone.value.stringValue;
                       if(stringValue!=nil && [stringValue isEqualToString:contact.phone]) {
                           foundMatch = true;
                           break;
                       }
                   }
                }
                
                if(foundMatch && index < contacts.count) {
                    copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:index] mutableCopy] ;
                    return copyOfContact;
                }
                //otherwise increase index to next
                index++;
            }
            //if still here, grabe the first as default
            copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
            return copyOfContact;
        } else {
            //nothing returned, try find by phone number
            if(contact.phone!=nil) {
                if (@available(iOS 11.0, *)) {
                    CNPhoneNumber *num = [[CNPhoneNumber alloc] initWithStringValue:contact.phone];
                    request.predicate = [CNContact predicateForContactsMatchingPhoneNumber: num];
                    contacts = [contactStore unifiedContactsMatchingPredicate:request.predicate keysToFetch:keys error:&fetchError];
                    
                    if(contacts.count > 0) {
                        CNMutableContact* copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
                        //NSLog(@"FIND BY PHONE");
                        return copyOfContact;
                    } else {
                        //nothing returned for phone, try email
                        if(contact.email!=nil) {
                            if (@available(iOS 11.0, *)) {
                                request.predicate = [CNContact predicateForContactsMatchingEmailAddress:contact.email];
                                contacts = [contactStore unifiedContactsMatchingPredicate:request.predicate keysToFetch:keys error:&fetchError];
                                
                                if(contacts.count > 0) {
                                    //NSLog(@"FIND BY EMAIL");
                                    CNMutableContact* copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
                                    return copyOfContact;
                                }
                            }
                        }
                    }
                }
            } else {
                
                //no phone, maybe email?
                //nothing returned
                if(contact.email!=nil) {
                    if (@available(iOS 11.0, *)) {
                        request.predicate = [CNContact predicateForContactsMatchingEmailAddress:contact.email];
                        contacts = [contactStore unifiedContactsMatchingPredicate:request.predicate keysToFetch:keys error:&fetchError];
                        if(contacts.count > 0) {
                            //NSLog(@"FIND BY EMAIL 2");
                            CNMutableContact* copyOfContact = (CNMutableContact *)[[contacts objectAtIndex:0] mutableCopy] ;
                            return copyOfContact;
                        }
                    }
                }
            }
        }
        
    }
    NSLog(@"RETURN NILL");
    return nil;
}

-(void) showPermissionsMessage {
    
    // Display an error.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permissions issue!"
                                                    message:@"Permission was denied. Cannot load address book. Please change privacy settings in settings app"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    [alert show];
}

//check if modal and local contact are the same object
-(BOOL) isSameContact: (ContactDataModel*) contactModel contact:(Contact*) contact {
    if(contactModel.lastname!=nil && contact.lastName!=nil && [contactModel.lastname isEqualToString:contact.lastName]) {
        return true;
    }
    else if(contactModel.email!=nil && contact.email!=nil && [contactModel.email isEqualToString:contact.email]) {
        return true;
    }
    else if(contactModel.phone!=nil && contact.phone!=nil && [contactModel.phone isEqualToString:contact.phone]) {
        return true;
    }
    return false;
}
//save the location record
-(void)saveGroup:(NSString*)name {
    
  
        
        NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        GroupDataModel *groupModel = (GroupDataModel *)[NSEntityDescription insertNewObjectForEntityForName:@"GroupDataModel" inManagedObjectContext:managedObjectContext];
        
        
        groupModel.name = name;
        
        Group *group = [[Group alloc]init];
        group.name = name;
        group.isNative = false;
        group.isFavorite = false;
        
        for(Contact *selected in selectedContactsList) {
            
            //add group to another group
            if([selected isKindOfClass:Group.class]) {
                
                //TODO PC CHECK
                
                //cast contact to group
                Group *theSelected = (Group *) selected;
                
                
                //now get the real contacts on this group
                for(Contact *contact in theSelected.contactsList) {
                    
                    ContactDataModel *contactModelToAdd = nil;
                    bool found = false;
                    // get all the contacts by this name and find the best match
                    NSMutableArray *array = [CoreDataUtils fetchAllContactsDataModelByName: contact.name];
                    for(ContactDataModel *contactModel in array) {
                        
                        if ([self isSameContact:contactModel contact:contact]) {
                            contactModelToAdd = contactModel;
                            //found the core data match for this selected contact in this group
                            //add to core data
                            [groupModel addContactsObject:contactModelToAdd];
                            [contactModelToAdd addGroupObject:groupModel];
                            [group.contactsList addObject:contact];
                            found = true;
                            NSLog(@"FOUND A MATCH ASSIGNING THIS ONE %@",contactModelToAdd.name);
                            break; //break the inner for loop
                        }
                    }
                    if(!found || contactModelToAdd==nil) {
                        NSLog(@"DID NOT FOUND A MATCH, creating a new contact on core data for %@",contactModelToAdd.name);
                        //not on core data, maybe internal address book one
                        contactModelToAdd = [self prepareModelFromContact: managedObjectContext :contact];
                        
                        [groupModel addContactsObject:contactModelToAdd];
                        [contactModelToAdd addGroupObject:groupModel];
                        
                        [group.contactsList addObject:contact];
                    }
 
                }
                
            }
            else {
                
                //add single contact to group
                
                //get the existing ones from core data models and found the matching one
                NSMutableArray *array = [CoreDataUtils fetchAllContactsDataModelByName: selected.name];
                ContactDataModel *contactModelToAdd = nil;
                bool found = false;
                for(ContactDataModel *contactModel in array) {
                    //found the one matching the selected one
                    if ([self isSameContact:contactModel contact:selected]) {
                        contactModelToAdd = contactModel;
                        NSLog(@"FOUND A MATCH ASSIGNING THIS ONE %@",contactModelToAdd.name);
                        //found the core data match for this selected contact in this group
                        //add to core data
                        [groupModel addContactsObject:contactModelToAdd];
                        [contactModelToAdd addGroupObject:groupModel];
                        [group.contactsList addObject:selected];
                        found = true;
                        break; //break the inner for loop
                    }
                }
                //not found a mathc on core data, insert a new one (even if it will duplicate the one on address book)
                if(!found || contactModelToAdd==nil) {
                    NSLog(@"DID NOT FOUND A MATCH, creating a new contact on core data for %@",contactModelToAdd.name);
                    ContactDataModel *contactModel = [self prepareModelFromContact: managedObjectContext :selected];
                    
                    [groupModel addContactsObject:contactModel];
                    [contactModel addGroupObject:groupModel];
                    
                    [group.contactsList addObject:selected];
                }
                
                
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

#pragma search data delegates
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = self.searchController.searchBar.text;
    
    //if(searchString !=nil && searchString.length > 0) {
    NSInteger scope = self.searchController.searchBar.selectedScopeButtonIndex;
    
    if(scope == 0){
        //name
        [self filterContentForSearchText:searchString scope:@"name"];
    } else if(scope == 1) {
        //email
        [self filterContentForSearchText:searchString scope:@"email"];
    }
    else {
        //phone
        [self filterContentForSearchText:searchString scope:@"phone"];
    }
    
    //}
    
    [self.tableView reloadData];
    
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}

-(BOOL) isDarkModeEnabled {
    if (@available(iOS 12.0, *)) {
        return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    } else {
        // Fallback on earlier versions
        return NO;
    }
}

-(void) viewWillLayoutSubviews {
    
   BOOL darkModeEnabled = [self isDarkModeEnabled];
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   BOOL savedValue = [defaults boolForKey:@"darkModeEnabled"];
    
   if(darkModeEnabled) {
       self.tabBarController.tabBar.backgroundColor = [UIColor blackColor]; //[self colorFromHexString:@"#1c1c1e"];//1c1c1e
       self.tableView.backgroundColor = [UIColor blackColor];
   } else {
       PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
       self.tabBarController.tabBar.backgroundColor =  [delegate colorFromHex:0xfb922b]; //normal lite color
       self.tableView.backgroundColor = [delegate defaultTableColor: false];
   }
    
    [defaults setBool:darkModeEnabled forKey:@"darkModeEnabled"];
    
    if(savedValue!= darkModeEnabled) {
        
        [self.tableView reloadData];
    }
}
/*
-(void) checkAppearance {
    
 if([self isDarkModeEnabled]) {
        self.tabBarController.tabBar.backgroundColor = [UIColor blackColor]; //[self colorFromHexString:@"#1c1c1e"];//1c1c1e
        self.tableView.backgroundColor = [UIColor blackColor];
    } else {
        PCAppDelegate *delegate = (PCAppDelegate *)[ [UIApplication sharedApplication] delegate];
        self.tabBarController.tabBar.backgroundColor =  [delegate colorFromHex:0xfb922b]; //normal premium color
        self.tableView.backgroundColor = [delegate defaultTableColor: false];
    }
}*/

-(BOOL) isNotSquaredPhoto: (UIImage *) photo {
    
    //avoid any division by 0
    if(photo.size.width == 0 || photo.size.height == 0) {
        return false;
    }
    else if(photo.size.width ==  photo.size.height) {
        return false;
    }
    
    float bigger = (photo.size.height > photo.size.width) ? photo.size.height : photo.size.width;
    float smaller = (photo.size.height > photo.size.width) ? photo.size.width : photo.size.height;
    
    if(smaller / bigger <= 0.75) {
        return true;
    }
    
    return false;
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    double newCropWidth, newCropHeight;

    newCropWidth = size.width;
    newCropHeight = size.height;
    
    //=== To crop more efficently =====//
    /*if(image.size.width < image.size.height){
         if (image.size.width < size.width) {
                 newCropWidth = size.width;
          }
          else {
                 newCropWidth = image.size.width;
          }
          newCropHeight = (newCropWidth * size.height)/size.width;
    } else {
          if (image.size.height < size.height) {
                newCropHeight = size.height;
          }
          else {
                newCropHeight = image.size.height;
          }
          newCropWidth = (newCropHeight * size.width)/size.height;
    }*/
    //==============================//

    double x = image.size.width/2.0 - newCropWidth/2.0;
    double y = image.size.height/2.0 - newCropHeight/2.0;

    CGRect cropRect = CGRectMake(x, y, newCropWidth, newCropHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);

    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);

    return cropped;
}

@end
