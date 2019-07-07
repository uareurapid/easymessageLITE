//
//  CustomMessagesDetailController.m
//  EasyMessage
//
//  Created by PC Dreams on 04/06/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "CustomMessagesDetailController.h"
#import <QuartzCore/QuartzCore.h>
#import "PCAppDelegate.h"
@interface CustomMessagesDetailController ()

@end

@implementation CustomMessagesDetailController
@synthesize message, textView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self.textView layer] setBorderColor:[[UIColor blackColor] CGColor]];
    [[self.textView layer] setBorderWidth:1.8];
    [[self.textView layer] setCornerRadius:5];
    
    self.textView.delegate = self;
    
    PCAppDelegate *delegate = (PCAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save",@"save")
                                                                   style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked:)];
    self.navigationController.navigationBar.barTintColor = [delegate colorFromHex:0xfb922b];
    doneButton.tintColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = doneButton;
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)saveClicked:(id)sender {
    
    if( self.textView.text!=nil && ([self.textView.text length] > 0) && ![self.textView.text isEqualToString:message.msg]) {
        //make sure it is the exact same
        
        if(self.model!=nil && [self.message.msg isEqualToString:self.model.msg] && (self.model.isDefault.boolValue == self.message.isDefault.boolValue) ) {
            //make sure we have the same
            
            NSManagedObjectContext *managedObjectContext = [(PCAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
            //copy the new msg values
            self.model.msg = self.textView.text;
            NSError *error;
            
            if(![managedObjectContext save:&error]){
                
                NSLog(@"Unable to save object, error is: %@",error.description);
                //This is a serious error saying the record
                //could not be saved. Advise the user to
                //try again or restart the application.
                self.messagesController.forceReload = false;
            } else {
                NSLog(@"updated message");
                self.messagesController.forceReload = true;
            }
            
        }
        
        //save
        [self.navigationController popToRootViewControllerAnimated:YES];
    }//otherwise no changes
    else {
        NSLog(@"ERROR");
    }
}

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil previousController: (UIViewController *) parent message:(Message *) message {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.textView.text = message.msg;
    self.message = message;
    self.messagesController = (CustomMessagesController *) parent;
    return self;
    
}

-(void) viewWillAppear:(BOOL)animated{
    self.textView.text = self.message.msg;
}
/*
 - (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
 return YES;
 }
 
 [txtView resignFirstResponder];
 return NO;
 }*/
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

