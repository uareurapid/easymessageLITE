//
//  PreferedItemOrderViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 6/26/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "SocialNetworksViewController.h"

@interface SocialNetworksViewController ()

@end

@implementation SocialNetworksViewController

@synthesize sendOptions,selectedServiceOptions,previousController,isTwitterAvailable,isFacebookAvailable,isLinkedinAvailable;
@synthesize initiallySelectedNumOfSocialNetworks;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) previous services:(NSArray *) services{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        sendOptions = [[NSMutableArray alloc] initWithArray:services];
        selectedServiceOptions = [[NSMutableArray alloc] init];
        previousController = previous;
        isFacebookAvailable = [services containsObject:OPTION_SENDTO_FACEBOOK_ONLY];
        isTwitterAvailable = [services containsObject:OPTION_SENDTO_TWITTER_ONLY];
        isLinkedinAvailable = [services containsObject:OPTION_SENDTO_LINKEDIN_ONLY];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"done_button", @"done_button") style:UIBarButtonItemStyleDone target:self action:@selector(goBackAfterSelection:)];
        
        doneButton.tintColor = UIColor.whiteColor;
        
        self.navigationItem.rightBarButtonItem = doneButton;
        //self.title = @"Advanced Options";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    initiallySelectedNumOfSocialNetworks = 0;
  
}

//view will appear
-(void) viewWillAppear:(BOOL)animated {
    
    initiallySelectedNumOfSocialNetworks = selectedServiceOptions.count;
    
}

//save user preferrences
-(void) viewWillDisappear:(BOOL)animated {
    
    
    //do we have ore than 0, and is different from the begining??
    if(selectedServiceOptions.count > 0 ) {

        if(selectedServiceOptions.count!=initiallySelectedNumOfSocialNetworks) {
            NSString *msg = NSLocalizedString(@"alert_message_include_social_networks",@"alert_message_include_social_networks");
            [[[[iToast makeText:msg]
               setGravity:iToastGravityBottom] setDuration:2000] show];
        }
        
        
        
        SettingsViewController *settings = (SettingsViewController *) previousController;
        [settings.socialServicesOptions addObjectsFromArray:selectedServiceOptions];
        
        
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return sendOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    //section 0 is email options
    if(section==0) {
        
        cell = [self labelForOptionIndex:row cellView:cell];
        NSString *option = [sendOptions objectAtIndex:row];
        
        if( [selectedServiceOptions containsObject: option]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    
    
    return cell;
}

-(UITableViewCell *) labelForOptionIndex: (NSInteger) rowIndex cellView: (UITableViewCell *) cell  {
    
    NSInteger options = 1;
    if(isFacebookAvailable) {
        options+=1;
    }
    if(isTwitterAvailable) {
        options+=1;
    }
    
    if(options==3) {
        if(rowIndex==0) {
            cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
            cell.imageView.image = [UIImage imageNamed:@"facebook"];
        }
        else if(rowIndex==1) {
            cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
            cell.imageView.image = [UIImage imageNamed:@"twitter"];
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"option_send_linkedin_only",@"send only to linkedin");
            cell.imageView.image = [UIImage imageNamed:@"linkedin"];
        }
    }
    else if(options==1) {
        if(isFacebookAvailable) {
            cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
            cell.imageView.image = [UIImage imageNamed:@"facebook"];
            
        }
        else if (isLinkedinAvailable) {
            cell.textLabel.text = NSLocalizedString(@"option_send_linkedin_only",@"send only to linkedin");
            cell.imageView.image = [UIImage imageNamed:@"linkedin"];
        }
        else { //twitter
            cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
            cell.imageView.image = [UIImage imageNamed:@"twitter"];
        }
    }
    else if(options==2) {
        if(isFacebookAvailable && isTwitterAvailable) {
            
            if(rowIndex==0) {
                cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
                cell.imageView.image = [UIImage imageNamed:@"facebook"];
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
            }
            
            
        }
        else if(isFacebookAvailable && isLinkedinAvailable) {
            if(rowIndex==0) {
                cell.textLabel.text = NSLocalizedString(@"option_send_facebook_only",@"send only to facebook");
                cell.imageView.image = [UIImage imageNamed:@"facebook"];
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"option_send_linkedin_only",@"send only to linkedin");
                cell.imageView.image = [UIImage imageNamed:@"linkedin"];
            }
        }
        else  {
            //linkeding && twitter
            if(rowIndex==0) {
                cell.textLabel.text = NSLocalizedString(@"option_send_twitter_only",@"send only to twitter");
                cell.imageView.image = [UIImage imageNamed:@"twitter"];
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"option_send_linkedin_only",@"send only to linkedin");
                cell.imageView.image = [UIImage imageNamed:@"linkedin"];
            }
        }
    }
    
    return cell;
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
    
    NSInteger row = indexPath.row;

    NSString *optionSelected = [sendOptions objectAtIndex:row];
    if([selectedServiceOptions containsObject:optionSelected]) {
        [selectedServiceOptions removeObject:optionSelected];
    }
    else {
        [selectedServiceOptions addObject:optionSelected];
    }

   [self.tableView reloadData];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==0) {
        return NSLocalizedString(@"option_send_include_social_network", @"include social networks");
    }
    else {
        return @"";
    }
    
}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section==0) {
        
        NSString *str = [NSString stringWithFormat:@"%@\r\n\r\n%@",NSLocalizedString(@"footer_social_networks", @""),NSLocalizedString(@"social_networks_copy_paste", @"")];
        return str;
    }
    else {
        return @"";
    }
    
}

//just go back
-(IBAction)goBackAfterSelection:(id)sender {
    [self.navigationController popToViewController:previousController animated:YES];
}

@end
