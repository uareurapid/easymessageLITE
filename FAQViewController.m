//
//  FAQViewController.m
//  EasyMessage
//
//  Created by PC Dreams on 08/10/2019.
//  Copyright © 2019 Paulo Cristo. All rights reserved.
//

#import "FAQViewController.h"

@interface FAQViewController ()

@end

@implementation FAQViewController

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://pcdreamsapps.wixsite.com/easymessage/faq"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self.faqView.delegate = self;
    [self.faqView loadRequest:request];
    // Do any additional setup after loading the view from its nib.

}


-(void) webViewDidStartLoad:(UIWebView *)webView{
   //if (self.faqView.isLoading) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    //}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
   //Check here if still webview is loding the content
    if (webView.isLoading) {
      return;
    }

   self.activityIndicator.hidden = YES;
   //after code when webview finishes
   // UI updates must be on main thread
   [self.activityIndicator stopAnimating];
   
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
