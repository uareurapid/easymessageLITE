//
//  IAPMasterViewController.m
//  EasyMessage
//
//  Created by Paulo Cristo on 9/7/13.
//  Copyright (c) 2013 Paulo Cristo. All rights reserved.
//

#import "IAPMasterViewController.h"
#import "EasyMessageIAPHelper.h"


@interface IAPMasterViewController () {

  //the products list on app store for in app purchase
  NSArray *_products;
  NSMutableArray * _selectedProducts;
  SKProduct * _lastSelectedProduct;
  NSNumberFormatter * _priceFormatter;
}

@end

@implementation IAPMasterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/**
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil rootViewController: (PCViewController *) rootViewController
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"In App Purchase";
    }
    return self;
}*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"In-App";
        self.tabBarItem.image = [UIImage imageNamed:@"80-shopping-cart"];
    }
    return self;
}

//register for the notification
- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    _lastSelectedProduct = nil;
    
    //BOOL purchasedMessages = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_COMMON_MESSAGES];
    //BOOL purchasedGroups = [[EasyMessageIAPHelper sharedInstance] productPurchased:PRODUCT_GROUP_SUPPORT];
    //self.navigationItem.rightBarButtonItem setEnabled:<#(BOOL)#>
    
    
}
//unregister from notifications
-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _selectedProducts = [[NSMutableArray alloc] init];
    _lastSelectedProduct = nil;
    
    if ([SKPaymentQueue canMakePayments]) {
        // Display a store to the user.
        NSLog(@"payments available");
    } else {
        // Warn the user that purchases are disabled.
        NSLog(@"no payments available");
        NSString *msg = @"No payments available. In-App products will be disabled";
        if(msg!=nil) {
            [[[[iToast makeText:msg]
               setGravity:iToastGravityBottom] setDuration:2000] show];
        }
    }
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"restore",@"restore") style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reload {
    
    _products = nil;
    [self.tableView reloadData];
    [[EasyMessageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
    //[self requestProductData];
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
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    if(indexPath.row < _products.count) {
        
        cell.textLabel.text = product.localizedTitle;
        
        [_priceFormatter setLocale:product.priceLocale];
        cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
        
        if ([[EasyMessageIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView = nil;
            cell.imageView.image = [UIImage imageNamed:@"Unlock32"];
        } else {
            
            
            //UILabel  *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 37)];
            //label1.backgroundColor = [UIColor clearColor];
            //UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
       
            //[container addSubview:label1];
          
            //label1.text = [_priceFormatter stringFromNumber:product.price];
            //cell.accessoryView = container;
            //cell.accessoryType = UITableViewCellAccessoryNone;//UITableViewCellAccessoryDisclosureIndicator;
            
            cell.imageView.image = [UIImage imageNamed:@"Lock32"];
            
            /*UIImage *buyImage = [UIImage imageNamed:@"80-shopping-cart"];
            UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
            buyButton.frame = CGRectMake(0, 0, 48, 48);
            [buyButton setBackgroundImage:buyImage forState:UIControlStateNormal];
            //[buyButton setTitle:NSLocalizedString(@"buy",@"buy") forState:UIControlStateNormal];
            buyButton.tag = indexPath.row;
            [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            */
            
            cell.accessoryView = nil;// buyButton;
        }
        
    }
     /*
    // Configure the cell...
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    
    
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = [self priceAsString:product.priceLocale price:product.price];
        
        if([_selectedProducts containsObject:product] ){
           
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    
    }*/
    
    
    
    //NSLog(@"Product title: %@" , product.localizedTitle);
    //NSLog(@"Product description: %@" , product.localizedDescription);
    //NSLog(@"Product price: %@" , product.price);
    
    //<#(NSDecimalNumber *)#>[ NSString stringWithFormat: @"%@",product.price ];
    //NSLog(@"Product id: %@" , product.productIdentifier);
    //NSLog(@"Product locale: %@" , product.priceLocale);
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     if(_products!=nil && indexPath.row < _products.count) {
     
     _lastSelectedProduct = [_products objectAtIndex:indexPath.row];
     
     if(![_selectedProducts containsObject:_lastSelectedProduct]) {
         
         [_selectedProducts addObject:_lastSelectedProduct];
     }
   
     
     }
     [self.tableView reloadData];
    
     if(_lastSelectedProduct !=nil) {
         [self startPurchaseOf:_lastSelectedProduct];
     }
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"available_products",@"available products");
}

-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(_products==nil || _products.count==0)
      return @"";
    else if (_lastSelectedProduct==nil || _selectedProducts.count==0) {
        return NSLocalizedString(@"click_row_product_details",@"Click a row to get product details");
    }
    else {
    
      return [NSString stringWithFormat:@"%@ - %@",_lastSelectedProduct.localizedTitle, _lastSelectedProduct.localizedDescription ];
    }

}

//get the notification when a product is purchased
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
    [self askForReview];
    
}

//@deprecated
- (NSString *) priceAsString: (NSLocale *) priceLocale price: (NSDecimalNumber * )price
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale: priceLocale];
    
    NSString *str = [formatter stringFromNumber: price];
    return str;
}

//buy button clicked
- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[EasyMessageIAPHelper sharedInstance] buyProduct:product];
    
}

- (void)startPurchaseOf:(SKProduct *) product {
    
    //UIButton *buyButton = (UIButton *)sender;
    //SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[EasyMessageIAPHelper sharedInstance] buyProduct:product];
    
}
//restore clicked
- (void)restoreTapped:(id)sender {
    [[EasyMessageIAPHelper sharedInstance] restoreCompletedTransactions];
}

-(void) askForReview {
    
    
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    }
    else {
            
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Easy Message"
                                                            message: NSLocalizedString(@"ask_to_rate", nil)
                                                           delegate:self
                                                  cancelButtonTitle: NSLocalizedString(@"cancel", nil)
                                                  otherButtonTitles:@"OK", nil];
        [alert show];
    }
    //do not ask again, simulate that we used it for 11 messages already (it usually shows at 10 messages)
    [[NSUserDefaults standardUserDefaults] setInteger:11 forKey:KEY_ASK_FOR_REVIEW];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex==1) { //0 - cancel, 1 - save/ok
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1448046358?mt=8&action=write-review"]];
    }
}


@end
