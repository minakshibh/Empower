//
//  serverUploadViewController.m
//  TestBrowser
//
//  Created by Krishna Mac Mini 2 on 18/01/16.
//  Copyright © 2016 Alexandru Catighera. All rights reserved.
//

#import "serverUploadViewController.h"
#import "BrowserViewController.h"
#import "APIRequest.h"

@interface serverUploadViewController ()

@end

@implementation serverUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webView.delegate = self;
   
    
    
    status1 = false;
    status2 = false;
    // Do any additional setup after loading the view from its nib.
    
    
    lblActivity.layer.cornerRadius = 5.0;
    lblActivity.layer.borderWidth = 2.0;
    lblActivity.layer.borderColor = [UIColor colorWithRed:144.0f/255.0f green:184.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
    [lblActivity setClipsToBounds:YES];
    
    
    
    lblClass.layer.cornerRadius = 5.0;
    lblClass.layer.borderWidth = 2.0;
    lblClass.layer.borderColor = [UIColor colorWithRed:144.0f/255.0f green:184.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
    [lblClass setClipsToBounds:YES];
    
    btnUploadToServer.layer.cornerRadius = 5.0;
    [btnUploadToServer setClipsToBounds:YES];
    
    tableViewActivity.layer.cornerRadius = 5.0;
    tableViewActivity.layer.borderWidth = 1.0;
    tableViewActivity.layer.borderColor = [UIColor colorWithRed:144.0f/255.0f green:184.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
    [tableViewActivity setClipsToBounds:YES];
    
    tableViewClass.layer.cornerRadius = 5.0;
    tableViewClass.layer.borderWidth = 1.0;
    tableViewClass.layer.borderColor = [UIColor colorWithRed:144.0f/255.0f green:184.0f/255.0f blue:218.0f/255.0f alpha:1.0f].CGColor;
    [tableViewClass setClipsToBounds:YES];

    classArr = [[NSMutableArray alloc]initWithObjects:@"Select a Class",@"class 1",@"class 2",@"class 3", nil];
    
    btnUploadToServer.userInteractionEnabled = NO;
    btnUploadToServer.backgroundColor = [UIColor darkGrayColor];
    
    
}
-(void)viewWillAppear:(BOOL)animated{

    btnUploadToServer.hidden = YES;
    
    lblSelectActivityType.hidden = YES;
    lblActivity.hidden = YES;
    btnActivity.hidden = YES;
    icontdropDownActivity.hidden = YES;
    
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"userID"]!= nil) {
        
    }else{
        
        [self.view addSubview:viewWebView];
        viewWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self checkUserLogin];
        
        webView.layer.cornerRadius = 5.0;
        [webView setClipsToBounds:YES];
    }
    //    heading.center.x  -= view.bounds.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnMainView:(id)sender
{
    BrowserViewController *browserVC = [[BrowserViewController alloc]initWithNibName:@"BrowserViewController" bundle:nil];
    [self.navigationController pushViewController:browserVC animated:YES];
}

-(void)checkUserLogin
{
    NSString *urlStr;
//    [APIRequest postRequestUrl:urlStr parameters:nil headers:nil indicator:YES indicatorMessage:@"loading.." withErrorResponse:NO response:^(NSMutableDictionary *response) {
//    }];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies != nil && cookies.count > 0) {
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    urlStr = @"https://educate.adams50.org/Educate/default.aspx?LOAD_PAGE=true";
    urlStr = [urlStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    
    
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [webView loadRequest:request];
    [self ShowIndicator:self.view];
//    webView.hidden = NO;
//    [self.view bringSubviewToFront:webView];
}

#pragma mark- webView delegates
- (BOOL)isWebViewFirstResponder
{
    NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.tagName"];
    if([[str lowercaseString]isEqualToString:@"input"]) {
        return YES;
    }
    return NO;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)requestURL navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [requestURL URL];
    NSLog(@"##### url = %@",[url absoluteString]);
    
    NSArray *loggedInStr = [[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@"="];
    if ([[loggedInStr objectAtIndex:1] isEqualToString:@"PLAYLIST_HOME_CLASS"]) {
        [[NSUserDefaults standardUserDefaults]setObject:[loggedInStr objectAtIndex:1] forKey:@"userID"];
        [viewWebView removeFromSuperview];
    }
    
    
    if([self isWebViewFirstResponder] &&
       navigationType != UIWebViewNavigationTypeFormSubmitted) {
        
        return NO;
    } else {
        
        return YES;
    }
    
    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //Check here if still webview is loding the content
    if (webView.isLoading)
        return;
    else //finished
        [self HideIndicator];
        NSLog(@"Webview loding finished");
}
#pragma  mark- Indicator Delegates
-(void)ShowIndicator:(UIView*)view
{
    activityIndicatorObject = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicatorObject.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    DisableView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        activityIndicatorObject.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        DisableView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];

    }
    //DisableView.backgroundColor=[UIColor blackColor];
    DisableView.alpha=0.5;
    [view addSubview:DisableView];
    activityIndicatorObject.color=[UIColor grayColor];
    [DisableView addSubview:activityIndicatorObject];
    [activityIndicatorObject startAnimating];
}


-(void)HideIndicator
{
    [activityIndicatorObject stopAnimating];
    [DisableView removeFromSuperview];
}
#pragma mark - tableview Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tableViewClass) {
        return classArr.count;
    }else{
        return activityArr.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
 
    if (tableView==tableViewClass) {
        cell.textLabel.text = [classArr objectAtIndex: indexPath.row];
    }else{
        cell.textLabel.text = [activityArr objectAtIndex:indexPath.row];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor colorWithRed:13.0f/255.0f green:102.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tableViewClass) {
       
        [btnClass setTitle:[classArr objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(aTime1) userInfo:nil repeats:NO];
        btnClass.userInteractionEnabled = NO;
        activityArr = [[NSMutableArray alloc]init];
        [self ShowIndicator:viewLoadingClass];
    }else{
        [btnActivity setTitle:[activityArr objectAtIndex:indexPath.row] forState:UIControlStateNormal];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(aTime2) userInfo:nil repeats:NO];
        btnActivity.userInteractionEnabled = NO;
        [self ShowIndicator:viewLoadingActivity];
    }
    tableViewActivity.hidden = YES;
     tableViewClass.hidden = YES;
    status1 = false;
    status2 = false;
}
-(void)aTime2
{
    btnUploadToServer.backgroundColor = [UIColor colorWithRed:13.0f/255.0f green:102.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
    [self HideIndicator];
    btnActivity.userInteractionEnabled = YES;
    btnUploadToServer.hidden = NO;
    
}
-(void)aTime1
{
     activityArr  = [[NSMutableArray alloc]initWithObjects:@"Select an Activity",@"Activity 1",@"Activity 2",@"Activity 3", nil];
    
    btnClass.userInteractionEnabled = YES;
    [self HideIndicator];
    [tableViewActivity reloadData];
    
    lblSelectActivityType.hidden = NO;
    lblActivity.hidden = NO;
    btnActivity.hidden = NO;
    icontdropDownActivity.hidden = NO;
}
#pragma mark - Buttons
-(IBAction)btnClass:(id)sender{
    
    
    if (status1==false) {
        tableViewClass.hidden = NO;
        status1 =true;
        tableViewActivity.hidden = YES;
        status2 =false;
        if (classArr.count==0) {
            tableViewClass.hidden = YES;
            status1 =false;
        }
        [tableViewClass reloadData];
    }else{
        tableViewClass.hidden = YES;
        status1 =false;
    }
    
}
-(IBAction)btnActivity:(id)sender{
    if (status2==false) {
        tableViewActivity.hidden = NO;
        status2 =true;
        tableViewClass.hidden = YES;
        status1 =false;
        if (activityArr.count==0) {
           tableViewActivity.hidden = YES;
            status2 =false;
        }
        [tableViewActivity reloadData];
    }else{
        tableViewActivity.hidden = YES;
        status2 =false;
    }
}
-(IBAction)btnUploadToServer:(id)sender{
    
}
@end
