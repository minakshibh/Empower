//
//  serverUploadViewController.h
//  TestBrowser
//
//  Created by Krishna Mac Mini 2 on 18/01/16.
//  Copyright © 2016 Alexandru Catighera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface serverUploadViewController : UIViewController<UIWebViewDelegate>

{
    UIActivityIndicatorView *activityIndicatorObject;
    UIView  *DisableView;
    IBOutlet UIWebView *webView;
    IBOutlet UITableView *tableViewClass;
    IBOutlet UITableView *tableViewActivity;
    IBOutlet UILabel *lblActivity;
    IBOutlet UILabel *lblClass;
    IBOutlet UIButton *btnClass;
    IBOutlet UIButton *btnActivity;
    IBOutlet UIButton *btnUploadToServer;
    BOOL status1,status2;
    
    IBOutlet UIView *viewLoadingActivity;
    IBOutlet UIView *viewLoadingClass;
    IBOutlet UILabel *lblSelectAClass;
    IBOutlet UILabel *lblSelectActivityType;
    NSMutableArray *classArr,*activityArr;
    IBOutlet UIImageView *icontdropDownClass;
    IBOutlet UIImageView *icontdropDownActivity;
    IBOutlet UIView *viewWebView;
}
-(IBAction)btnMainView:(id)sender;
-(IBAction)btnUploadToServer:(id)sender;
-(IBAction)btnClass:(id)sender;
-(IBAction)btnActivity:(id)sender;
@end
