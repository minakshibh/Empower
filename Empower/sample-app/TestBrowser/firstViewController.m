//
//  firstViewController.m
//  sampleWebView
//
//  Created by Krishna Mac Mini 2 on 16/10/15.
//  Copyright © 2015 Krishna_Mac_2. All rights reserved.
//

#import "firstViewController.h"
#import "TAlertView.h"
#import "UIView+MaterialDesign.h"
#import "BrowserViewController.h"
@interface firstViewController ()

@end

@implementation firstViewController

- (void)viewDidLoad {
    
    //---yes this is
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    //--hide navigation bar
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationItem.title = @"Save URL";
    
    //make text look like round
     lblbacktxt.layer.cornerRadius = 3.0;  [lblbacktxt setClipsToBounds:YES];
    
    //----hide cancel button for the first time
    if([_firstTime isEqualToString:@"yes"])
    {
        btnCancel.hidden = YES;
    }
    
    //---set the text field value with the save preferrence value
    NSString *urlStr = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"URL"]];
    if ([urlStr rangeOfString:@"nil" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
    }else if([urlStr rangeOfString:@"null" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
    }else{
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        txtField.text = urlStr;
    }
   //------
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //txtField.text = @"https://educate.adams50.org/Educate/iFrame.aspx?iCtrl=PLAYLIST_HOME_CLASS";

     [[self navigationController] setNavigationBarHidden:YES animated:YES];
//    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
//    {
//        CGRect frame = txtField.frame;
//        frame.origin.x = lblbacktxt.frame.origin.x +5;
//        txtField.frame = frame;
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSave:(id)sender {
    NSString* url = [txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if([url isEqualToString:@""])
    {
        //-----alertview animation
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"Error"
                                                      message:@"Kindly enter url."
                                                      buttons:@[@"Ok"]
                                                  andCallBack:^(TAlertView *alertView, NSInteger buttonIndex) {}];
        alert.style = TAlertViewStyleError;
        alert.tapToClose = NO;
        [alert show];
        return;
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"URL"];
    [user setObject:url forKey:@"URL"];
    
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"URL"]);
    
    BrowserViewController *SVC = [[BrowserViewController alloc]initWithNibName:@"MainWindow-iPad" bundle:nil];
    SVC.url = self.txtSearch.text;
    
    [UIView transitionFromView:self.view
                        toView:SVC.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft |
     UIViewAnimationOptionAllowUserInteraction    |
     UIViewAnimationOptionBeginFromCurrentState
                    completion:nil];
    SVC.url = url;
    [self.navigationController pushViewController:SVC animated:NO];

    
}
- (IBAction)btnSave1:(id)sender;
{
    NSLog(@"done");
}
- (IBAction)btnCancel:(id)sender
{
//   
//    CGPoint position = [sender position];
//    [self.view mdInflateAnimatedFromPoint:position backgroundColor:[UIColor lightGrayColor] duration:0.5 completion:nil];
    
    
    BrowserViewController *SVC = [[BrowserViewController alloc]initWithNibName:@"MainWindow-iPad" bundle:nil];
    SVC.url = self.txtSearch.text;
    
    [UIView transitionFromView:self.view
                        toView:SVC.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft |
     UIViewAnimationOptionAllowUserInteraction    |
     UIViewAnimationOptionBeginFromCurrentState
                    completion:nil];
    [self.navigationController pushViewController:SVC animated:NO];
    //--
}


@end

