//
//  BrowserViewController.m
//
//  Created by Alexandru Catighera on 3/5/13.
//
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import "BrowserViewController.h"
#import "Tab.h"
#import "BookmarksController.h"
#import "BookmarksFormController.h"
#import "BookmarkFolderFormController.h"
#import "UIMainView.h"
#import "BrowserDelegate.h"
#import "Reachability.h"
#import "firstViewController.h"
#import "AppDelegate.h"
#import <CoreFoundation/CoreFoundation.h>

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface BrowserViewController ()

@end

@implementation BrowserViewController {

    BOOL localWiFiRef;
    SCNetworkReachabilityRef reachabilityRef;
}

@synthesize addressBar, addressBarButtonsView, addressItem, searchItem, activityIndicator, topBar, bottomBar, refreshButton, forwardButton, backButton, navBar, oldAddressText, addTab, selectedTab, tabs, tabsView, webViewTemplate, bookmarksController, bookmarksFormController,  bookmarkButton, bugListNavBar, stopButton,  moreButton, reloadOnPageLoad,  initialPageLoad, progressBar, gotoUrl, contentSize, barItemPopoverPresenter, padPopover, popupQuery,  saveScrollPosition, customButton, customButton2, userAgent;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibNameOrNil == nil) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nibNameOrNil = @"MainWindow";
        } else {
            nibNameOrNil = @"MainWindow-iPad";
        }
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    j=0;
    i=0;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//    [user removeObjectForKey:@"URL"];
//    [user setObject:@"https://educate.adams50.org/Educate/iFrame.aspx?iCtrl=PLAYLIST_HOME_CLASS" forKey:@"URL"];
    
   // @"https://educate.adams50.org/Educate/iFrame.aspx?iCtrl=PLAYLIST_HOME_CLASS";
    
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

    [super viewDidLoad];
    
    //set background for toolbar in top bar
    if ([self isPad]) {
        UIImage *img = [UIImage imageNamed:@"gray-pixel.png"];
        [bottomBar setBackgroundImage:img forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    //size statusbar
    [(UIMainView *)[self view] sizeStatusBar];
    // Set up bookmark controllers
	BookmarksFormController *bookmarksFormController = [[BookmarksFormController alloc]
                                                        initWithNibName:@"BookmarksForm"
                                                        bundle:[NSBundle mainBundle]];
	BookmarkFolderFormController *bookmarkFolderFormController = [[BookmarkFolderFormController alloc]
																  initWithNibName:@"BookmarkFoldersForm"
																  bundle:[NSBundle mainBundle]];
	
	BookmarksController *bookmarksController = [[BookmarksController alloc] initWithNibName:@"Bookmarks" bundle:[NSBundle mainBundle]];
	bookmarksNavController = [[UINavigationController alloc] initWithRootViewController:bookmarksController];
	
	[self setBookmarksFormController:bookmarksFormController];
	[bookmarksController setBrowserController:self];
	[bookmarkFolderFormController setBookmarksController:bookmarksController];
	[bookmarksController setFolderController:bookmarkFolderFormController];
	[self setBookmarksController:navBar];
    
    // Tweak address bar view so text doesn't overflow
    UIView *addressBarStatusView = [[ UIView  alloc ]  initWithFrame:
									CGRectMake(0.0, 0.0, 23.0, 10.0)];
	[self.addressBar setRightView: addressBarStatusView];
	[self.addressBar setRightViewMode: UITextFieldViewModeUnlessEditing];
	self.oldAddressText = [NSMutableString stringWithString:@""];
    
    selectedTab.currentURLString = [user objectForKey:@"URL"];
    
    [self registerForKeyboardNotifications];
    
    addressBar.enabled = NO;

}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification *)aNotification {
    if (![self isPad] && [selectedTab currentURL] == nil && ![addressBar isFirstResponder]) {
        [self scrollToTop:aNotification];
        [[selectedTab webView] stringByEvaluatingJavaScriptFromString:@"document.getElementById('contain').style.top = '-15px'"];
    }
}

- (void)keyboardWasHidden:(NSNotification*)aNotification {
    if (![self isPad] && [selectedTab currentURL] == nil && ![addressBar isFirstResponder]) {
        [[selectedTab webView] stringByEvaluatingJavaScriptFromString:@"document.getElementById('contain').style.top = '15%'"];
        [self scrollToTop:aNotification];
    }
}

-(void) saveOpenTabs {
    NSManagedObjectContext *managedObjectContext = [(BrowserDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    int orderCount = 0;
    for (Tab *tab in [self tabs]) {
        NSManagedObject *tabEntity =[NSEntityDescription insertNewObjectForEntityForName:@"Tab" inManagedObjectContext:managedObjectContext];
        [tabEntity setValue:[[tab tabButton] titleForState:UIControlStateNormal] forKey:@"title"];
        [tabEntity setValue:[tab currentURLString] forKey:@"url"];
        [tabEntity setValue:[NSNumber numberWithInteger:orderCount] forKey:@"order"];
        orderCount++;
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error inserting %@ - error:%@",[self tabs],error);
    }
}

-(void) openSavedTabs {
    NSManagedObjectContext *managedObjectContext = [(BrowserDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	NSEntityDescription *tabEntity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:managedObjectContext];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"order" ascending:YES];

    [request setEntity:tabEntity];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSMutableArray *tabFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    for (NSManagedObject *tab in tabFetchResults) {
        [self addTabWithAddress:[tab valueForKey:@"url"]];
        [selectedTab setTitle:[tab valueForKey:@"title"]];
        
        [managedObjectContext deleteObject:tab];
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",tabFetchResults,error);
    }

}

-(void) deleteSavedTabs {
    NSManagedObjectContext *managedObjectContext = [(BrowserDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError *error = nil;
	NSEntityDescription *tabEntity = [NSEntityDescription entityForName:@"Tab" inManagedObjectContext:managedObjectContext];
    [request setEntity:tabEntity];
    NSMutableArray *tabFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    for (NSManagedObject *tab in tabFetchResults) {
        [managedObjectContext deleteObject:tab];
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",tabFetchResults,error);
    }
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //create initial tab
    if ([self.tabs count] == 0) {
        [self addTab:[self addTab]];
    }
	
}

- (void) viewWillAppear:(BOOL)animated {
    //[refreshButton setHidden:YES];
    [super viewWillAppear:animated];
    
}

-(void) viewWillDisappear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Scrolling

-(IBAction)scrollToTop:(id)sender {
    if (![self isPad]) {
        BOOL animated = ![sender isKindOfClass:[NSNotification class]];
        [[[self webView] scrollView] setContentOffset:CGPointMake(0, - topBar.frame.size.height) animated:NO];
        [[[self webView] scrollView] setContentInset:UIEdgeInsetsMake(-[[self webView] scrollView].contentOffset.y, 0, 0, 0)];
    }
}

- (IBAction)btnSetting:(id)sender {
    //---went to first view with animation
    firstViewController *obj = [[firstViewController alloc]initWithNibName:@"firstViewController" bundle:nil];
    
    [UIView transitionFromView:self.view
                        toView:obj.view
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromRight |
     UIViewAnimationOptionAllowUserInteraction    |
     UIViewAnimationOptionBeginFromCurrentState
                    completion:nil];
    [self.navigationController pushViewController:obj animated:NO];
    
    
//    firstViewController  *abc = [[firstViewController alloc]initWithNibName:@"firstViewController" bundle:nil];
//    [self.navigationController pushViewController:abc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    ScrollDirection scrollDirection;
//    int minWebViewSize = webViewTemplate.frame.size.height;
//    int maxWebViewSize = minWebViewSize + bottomBar.frame.size.height;
//    if (self.lastScrollContentOffset > scrollView.contentOffset.y)
//        scrollDirection = ScrollDirectionUp;
//    else if (self.lastScrollContentOffset < scrollView.contentOffset.y)
//        scrollDirection = ScrollDirectionDown;
//    
//    if (saveScrollPosition) {
//        selectedTab.scrollPosition = scrollView.contentOffset.y;
//    }
//    if(![self isPad]) {
//        UIView *statusBarView = [(UIMainView *)self.view statusBarView];
//        if (scrollView.contentOffset.y <= -topBar.frame.size.height) {
//            // noop
//        } else if (scrollView.contentOffset.y < -statusBarView.frame.size.height) {
//            [[[self webView] scrollView] setContentInset:UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)];
//        } else {
//            [[[self webView] scrollView] setContentInset:UIEdgeInsetsMake(statusBarView.frame.size.height, 0, 0, 0)];
//        }
//        
//        // show bottom toolbar when scrolling up fast
//        if (scrollDirection == ScrollDirectionUp && scrollView.contentOffset.y - self.lastScrollContentOffset < -20 && bottomBar.alpha == 0.0) {
//                [UIView animateWithDuration: 0.5
//                                      delay: 0.0
//                                    options: UIViewAnimationOptionCurveEaseOut
//                                 animations:^{
//                                     bottomBar.alpha = 1.0;
//                                 }
//                                 completion:^(BOOL finished){
//                                     if (finished) {
//                                         [selectedTab webView].frame = CGRectMake([selectedTab webView].frame.origin.x, [selectedTab webView].frame.origin.y, [selectedTab webView].frame.size.width, minWebViewSize);
//                                     }
//                                 }];
//                topBar.frame=CGRectMake(0,0, topBar.frame.size.width, topBar.frame.size.height);
//    
//            
//        } else if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y + scrollView.frame.size.height < scrollView.contentSize.height) {
//            if (scrollDirection == ScrollDirectionDown && bottomBar.alpha == 1.0) {
//                [selectedTab webView].frame = CGRectMake([selectedTab webView].frame.origin.x, [selectedTab webView].frame.origin.y, [selectedTab webView].frame.size.width, maxWebViewSize);
//                
//                [UIView animateWithDuration: 1.0
//                                      delay: 0.0
//                                    options: UIViewAnimationOptionCurveEaseIn
//                                 animations:^{
//                                     bottomBar.alpha = 0.0;
//                                 }
//                                 completion:^(BOOL finished){
//                                     if (finished) {
//                                     }
//                                 }];
//            }
//        
//        // show bottom toolbar
//        } else if (bottomBar.alpha == 0.0)  {
//
//            
//            [UIView animateWithDuration: 0.5
//                                  delay: 0.0
//                                options: UIViewAnimationOptionCurveEaseOut
//                             animations:^{
//                                 bottomBar.alpha = 1.0;
//                             }
//                             completion:^(BOOL finished){
//                                 if (finished) {
//                                     [selectedTab webView].frame = CGRectMake([selectedTab webView].frame.origin.x, [selectedTab webView].frame.origin.y, [selectedTab webView].frame.size.width, minWebViewSize);
//                                     if (scrollView.contentOffset.y > 0) {
//                                         CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - [selectedTab webView].frame.size.height);
//                                         [scrollView setContentOffset:bottomOffset animated:NO];
//                                     }
//                                 }
//                             }];
//
//        }
//    }
//    
//    //topbar logic
//    if(![self isPad] && scrollView.contentOffset.y>=-topBar.frame.size.height && (scrollView.contentOffset.y <= 0 || scrollDirection == ScrollDirectionDown))
//    {
//        topBar.frame=CGRectMake(0,-topBar.frame.size.height-scrollView.contentOffset.y, topBar.frame.size.width, topBar.frame.size.height);
//    }
//    
//    self.lastScrollContentOffset = scrollView.contentOffset.y;
}

- (void)showHideView
{
    // Fade out the view right away
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         bottomBar.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:1.0
                                               delay: 1.0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              bottomBar.alpha = 1.0;
                                          }
                                          completion:nil];
                     }];
}



// Web methods
#pragma mark- delegate webview
- (void)saveCookies
{
    NSMutableArray *cookieArray = [[NSMutableArray alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookieArray addObject:cookie.name];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
        [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
        [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
        [cookieProperties setObject:[NSNumber numberWithInt:cookie.version] forKey:NSHTTPCookieVersion];
        
        [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
        
        [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:cookieArray forKey:@"cookieArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)loadCookies
{
    NSArray             *cookies       = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: @"cookies"]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        [cookieStorage setCookie: cookie];
    }
}
- (NSURLRequest*)addCookies:(NSArray *)cookies forRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    if ([cookies count] > 0)
    {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies)
        {
            if (!cookieHeader)
            {
                cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
            }
            else
            {
                cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        if (cookieHeader)
        {
            [mutableRequest setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
        }
        
        return [mutableRequest copy];
    }
    
    return nil;
}
- (void) currentWebViewDidStartLoading:(UIWebView *) webView  {
    if (addressBar.editing) {
        [webView stopLoading];
        return;
    }
    
    NSURL *url = [webView.request URL];
    Tab *tab = nil;
    for (id cTab in tabs) {
        if ([cTab webView] == webView) {
            tab = cTab;
        }
    }
    if (tab == selectedTab) {
        
        if (initialPageLoad) {
            [refreshButton setHidden:true];
            [stopButton setHidden:false];
        }
        
    }
    if (progressBar.progress < 0.95) {
        [progressBar setProgress: progressBar.progress + 0.05];
    }
    [self setInitialPageLoad:NO];
}

-(void) currentWebViewDidFinishFinalLoad:(UIWebView *) webView {
    [progressBar setProgress:1.0 animated:NO];
    [progressBar setHidden:YES];
    
    [stopButton setHidden:YES];
    [self loadCookies];
    
    NSURL *url = [webView.request URL];
    if ([url isFileURL] || [[url absoluteString] isEqualToString:@"about:blank"]) {
        [refreshButton setHidden:YES];
    } else {
        [refreshButton setHidden:NO];
    }
    if (saveScrollPosition && [selectedTab scrollPosition] > 0) {
        [[[self webView] scrollView] setContentOffset:CGPointMake(0, [selectedTab scrollPosition]) animated:NO];
    }
    [self loadTabs:webView];
}

-(void) gotoAddress:(id) sender withRequestObj:(NSURLRequest *)request inTab:(Tab *)tab {
    // Clear detected bugs
    tab.currentURLString = @"";
    [self setInitialPageLoad:YES];
	
    //[whiteView setHidden:NO];
    [[self webView] stopLoading];
    //[[self webView] loadHTMLString:@"<html><head></head><body></body></html>" baseURL:[NSURL URLWithString:@"about:blank" ]];
    
    //saveScrollPosition = [[[request URL] host] isEqualToString:@"duckduckgo.com"] || [[[request URL] host] isEqualToString:@"www.duckduckgo.com"];
    
    if (![self isPad]) {
        [self scrollToTop:nil];
    }
	
	[oldAddressText setString:[NSString stringWithFormat:@"%@",[request URL]]];
	
	// Load the request in the UIWebView.
    if ([self checkNetworkStatus]) {
        //[[self webView] loadRequest:requestObj];
        
        NSMutableURLRequest *mRequest = [request mutableCopy];
        NSString *d = @"iPad";
        if (!self.userAgent) {
            self.userAgent = [[tab webView] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        }
        [mRequest setValue:[NSString stringWithFormat:self.userAgent, d] forHTTPHeaderField:@"User-Agent"];
        
        if ( [[[request URL] host] isEqualToString:@"itunes.apple.com"]) {
            [[UIApplication sharedApplication] openURL: mRequest.URL ];
        } else {
            [progressBar setHidden:NO];
            [progressBar setProgress:0.1 animated:NO];
            tab.urlConnection = nil;
            tab.urlConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:tab];
//            if (sender != refreshButton) {
//                [tab updateHistory];
//            }
        }
        
        
    } else {
        /*UIAlertView *netAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Open Page"
                                                           message:@"Cannot open page because it is not connected to the internet!"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Okay", nil];

        [netAlert show];*/
        [progressBar setHidden:YES];
        [self cannotConnect:nil];
        
    }
    [self saveCookies];
    [addressBar resignFirstResponder];
}

-(IBAction) didStartEditingAddressBar:(id)sender {
    if ([[addressBar text] length] > 0) {
        [self performSelector:@selector(selectAllAddressText) withObject:nil afterDelay:0.0];
    }
    [addressBarButtonsView setHidden:YES];
}

-(void) selectAllAddressText {
    [addressBar setSelectedTextRange:[addressBar textRangeFromPosition:addressBar.beginningOfDocument toPosition:addressBar.endOfDocument]];
}

-(IBAction) gotoAddress:(id) sender {
    [addressBarButtonsView setHidden:NO];
    [stopButton setHidden:NO];
    [refreshButton setHidden:YES];
    
     NSString *urlStr = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"URL"]];
    
    NSString *inputText = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    gotoUrl = [NSURL URLWithString:inputText];
    if (gotoUrl != nil && (!([[gotoUrl scheme] isEqualToString:@"http"] || [[gotoUrl scheme] isEqualToString:@"https"]))) {
        gotoUrl = [NSURL URLWithString: [@"http://" stringByAppendingString: [gotoUrl absoluteString]]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:gotoUrl];
    if ([inputText rangeOfString:@"."].location != NSNotFound && [NSURLConnection canHandleRequest:request]){
        [self gotoAddress:sender withRequestObj:request inTab:selectedTab];
    } else {
        [self searchWeb:sender];
    }
}

-(IBAction) didEndEditingAddressBar:(id)sender {
    
}

-(IBAction) searchWeb:(id) sender {
	NSString *searchQuery = [addressBar text];
    NSString *encodedSearchQuery = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)searchQuery,
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
	NSString *urlString = [@" " stringByAppendingString:encodedSearchQuery];
    
    // Load the request in the UIWebView.
    if ([self checkNetworkStatus]) {
        [self gotoAddress:sender withRequestObj:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] inTab:selectedTab];
    } else {
        [self cannotConnect:nil];
        [progressBar setHidden:YES];
        
    }
	//Load the request in the UIWebView.
	[addressBar resignFirstResponder];
}

-(void) cannotConnect:(UIWebView *) cnWebView {
    [stopButton setHidden:NO];
    [refreshButton setHidden:YES];
    NSURL *ucUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"unable_to_connect" ofType:@"html"] isDirectory:NO];
    NSString *ucContentString = [NSString stringWithContentsOfURL:ucUrl encoding:NSUTF8StringEncoding error:nil];
    [[self webView] loadHTMLString:ucContentString baseURL:nil];
}

-(IBAction) goBack:(id)sender {
	
    [selectedTab goBack];
    self.reloadOnPageLoad = YES;
}

-(IBAction) goForward:(id)sender {
	
    [selectedTab goForward];
	//[[self webView] stringByEvaluatingJavaScriptFromString:@"history.forward();"];
}

-(IBAction) cancel:(id)sender {
	//[self contractBar: sender];
}

-(IBAction) showBookmarks:(id)sender {
    [self showBookmarksView:sender];
}

-(void) showBookmarksView:(id)sender {

    [UIView transitionFromView:self.view
                        toView:[bookmarksController view]
                      duration:0.5
                       options:(UIViewAnimationOptionTransitionCrossDissolve)
                    completion:^(BOOL finished) {}];
	
}

-(IBAction) stopLoading:(id)sender {
	[stopButton setHidden:true];
    [refreshButton setHidden:false];
    [progressBar setHidden:YES];
    
	//[activityIndicator stopAnimating];
    if ([tabs count] > 0) {        
        [[selectedTab webView] stopLoading];
    }
}

-(NSArray *) actionSheetButtons {
    // hide add bookmark for local html files
    if ([[[selectedTab webView] request].URL isFileURL]) {
        return [NSArray arrayWithObjects:@"Clear Cookies", @"Clear Cache", @"Import Bookmarks", nil];
    } else {
        return [NSArray arrayWithObjects:@"Add Bookmark", @"Clear Cookies", @"Clear Cache", @"Import Bookmarks", nil];
    }
}

-(IBAction)showActionSheet:(id)sender {
	// Hide popover for ipad
	if ([self isPad] ) {
        
		if (padPopover.popoverVisible) {
			[padPopover dismissPopoverAnimated:YES];
		}
        
		if (popupQuery.visible || barItemPopoverPresenter == moreButton) {
			barItemPopoverPresenter = nil;
			[popupQuery dismissWithClickedButtonIndex:nil animated:YES];
		} else {
            [self generatePopupQuery];
			barItemPopoverPresenter = moreButton;
			[popupQuery showFromBarButtonItem:moreButton animated:YES];
		}
	} else {
        [self generatePopupQuery];
		[popupQuery showInView:self.view];
	}
}

-(void) generatePopupQuery {
    UIActionSheet *pQuery= [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    for (NSString *button in [self actionSheetButtons]) {
        [pQuery addButtonWithTitle:button];
    }
    
    pQuery.cancelButtonIndex = [pQuery addButtonWithTitle:@"Cancel"];
    
    self.popupQuery = pQuery;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // skip add bookmarks if we are loading a local file
    if ([[[selectedTab webView] request].URL isFileURL]) {
        buttonIndex += 1;
    }
    // Add Bookmark
	if (buttonIndex == 0) {
        [self addBookmarkFromSheet:actionSheet];
    }
    
    // Clear Cookies
    else if (buttonIndex == 1) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
    }
    
    // Clear Cache
    else if (buttonIndex == 2) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
    
    
    // Import Bookmarks
    else if (buttonIndex == 3) {
        [self addTab:actionSheet];
        NSString *urlAddress = @"";
        //[[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"import_bookmark_howto" ofType:@"html"]isDirectory:NO]]];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"import_bookmark_howto" ofType:@"html"];
        NSData *launchData = [NSData dataWithContentsOfFile:path];
        [[self webView] loadData:launchData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        [addressBar setText:urlAddress];
    }

}

-(void) addBookmarkFromSheet:(UIActionSheet *) sheet {
    [sheet dismissWithClickedButtonIndex:0 animated:YES];
    [bookmarksFormController setMode:'A'];
    [[bookmarksFormController navigationItem] setHidesBackButton:YES animated:NO];
    [bookmarksController pushViewController:bookmarksFormController animated:NO];
    if ([self isPad]) {
        if (padPopover == nil) {
            UIPopoverController *ppop = [[UIPopoverController alloc]
                                         initWithContentViewController:bookmarksController];
            self.padPopover = ppop;
            
        } else {
            [self.padPopover setContentViewController:bookmarksController animated:YES];
        }
        [self.padPopover presentPopoverFromBarButtonItem: bookmarkButton
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    } else {
        [UIView transitionFromView:self.view
                            toView:[bookmarksController view]
                          duration:0.5
                           options:(UIViewAnimationOptionTransitionCrossDissolve)
                        completion:^(BOOL finished) {}];
    }
}

// TABS

-(IBAction) addTab:(id)sender {
    if (tabsView.hidden) {
        [self toggleTabsView:sender];
    }
    [self addTabWithAddress:@""];
}

-(void) addTabWithAddress:(NSString *)urlAddress {

	if ([tabs count] == 0) {
		tabs = [[NSMutableArray alloc] initWithCapacity:8];
	}
	// reset navbar
	//[self contractBar:sender];
    /*if (!stopButton.hidden) {
     [self stopLoading:sender];
     }*/
	
    Tab *nTab = [[Tab alloc] initWithFrame:CGRectMake((100.0 * [tabs count]) + 2.0, 2.0, 100.0, 34.0) addTarget: self ];
    
    
	[self switchTabFrom:selectedTab ToTab:nTab];
	[tabsView addSubview:selectedTab];
	
	[tabs addObject:selectedTab];
	[selectedTab select];
    selectedTab.currentURL = [NSURL URLWithString:urlAddress];
	//scrolling
	tabsView.contentSize = CGSizeMake(((100.0) * [tabs count]) + 5.0, 23.0);
    if (tabsView.frame.size.width < tabsView.contentSize.width) {
        tabsView.contentOffset = CGPointMake(tabsView.contentSize.width - tabsView.frame.size.width,0);
    }
    
	tabsView.clipsToBounds = YES;
	tabsView.showsHorizontalScrollIndicator = NO;
    
    if(i==0)
    {
        i++;
       // [[NSUserDefaults standardUserDefaults]setObject:@"https://educate.adams50.org/Educate/iFrame.aspx?iCtrl=PLAYLIST_HOME_CLASS" forKey:@"URL"];
    
        NSString *urlStr = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"URL"]];
        if([urlStr isKindOfClass:[NSNull class]])
        {
            NSLog(@"");
        }
        if ([urlStr rangeOfString:@"nil" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            NSLog(@"");
        }
        if (_url!=nil) {
            urlStr = _url;
            
        }
        if ([urlStr rangeOfString:@"nil" options:NSCaseInsensitiveSearch].location != NSNotFound || [urlStr rangeOfString:@"" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            firstViewController *obj1 = [[firstViewController alloc]initWithNibName:@"firstViewController" bundle:nil];
            obj1.firstTime = @"yes";
        //[self.navigationController pushViewController:obj1 animated:YES];
        
            [UIView transitionFromView:self.view
                            toView:obj1.view
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight |
             UIViewAnimationOptionAllowUserInteraction    |
             UIViewAnimationOptionBeginFromCurrentState
                        completion:nil];
            [self.navigationController pushViewController:obj1 animated:NO];
            return;
                }else if([urlStr rangeOfString:@"null" options:NSCaseInsensitiveSearch].location != NSNotFound || [urlStr rangeOfString:@"" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    firstViewController *obj2 = [[firstViewController alloc]initWithNibName:@"firstViewController" bundle:nil];
                    obj2.firstTime = @"yes";
                    //[self.navigationController pushViewController:obj2 animated:YES];
        
                    [UIView transitionFromView:self.view
                            toView:obj2.view
                          duration:1
                           options:UIViewAnimationOptionTransitionFlipFromRight |
                     UIViewAnimationOptionAllowUserInteraction    |
                     UIViewAnimationOptionBeginFromCurrentState
                        completion:nil];
                    [self.navigationController pushViewController:obj2 animated:NO];        return;
                }
        if ([urlStr rangeOfString:@"www" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    
                }else{
                    if(urlStr.length <3)
                    {
                    firstViewController *obj2 = [[firstViewController alloc]initWithNibName:@"firstViewController" bundle:nil];
                    obj2.firstTime = @"yes";
                    //[self.navigationController pushViewController:obj2 animated:YES];
                    
                    [UIView transitionFromView:self.view
                                        toView:obj2.view
                                      duration:1
                                       options:UIViewAnimationOptionTransitionFlipFromRight |
                     UIViewAnimationOptionAllowUserInteraction    |
                     UIViewAnimationOptionBeginFromCurrentState
                                    completion:nil];
                    [self.navigationController pushViewController:obj2 animated:NO];        return;
                    }else{
                        if (_url!=nil) {
                            urlStr = _url;

                        }
                    }
                }
    
                    urlAddress = urlStr;
                    i++;
    }
    
    if ([urlAddress isEqualToString:@""]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"launch" ofType:@"html"];
        NSData *launchData = [NSData dataWithContentsOfFile:path];
        [[self webView] loadData:launchData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
        if (![addressBar isFirstResponder])  {
            [addressBar setText:urlAddress];
        }
        
    } else {
        [self gotoAddress:nil withRequestObj:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlAddress]] inTab:selectedTab];
        
    }
    
	[self loadTabs:[selectedTab webView]];
}

-(IBAction) removeTab:(id)sender {
    AppDelegate*appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    appdelegate.prevAddress=@"";
    lblOpenin.hidden = YES;
    btnIBooks.hidden = YES;
	[sender setEnabled:NO];
	Tab *toBeRemoved = (Tab *)[sender superview];
	[[toBeRemoved tabButton] setEnabled:NO];
	
	BOOL removed = false;
	BOOL select = false;
	
	for (id cTab in tabs) {
		if (select) {
			[self switchTabFrom:selectedTab ToTab:cTab];
			select = false;
		}
		if (removed) {
			[cTab incrementOffset];
		}
		if ([cTab closeButton] == sender) {
			removed = YES;
			select = (selectedTab == cTab);
		}
        
	}
    
	if (toBeRemoved == [tabs lastObject] && [tabs lastObject] != [NSNull null] && [tabs count] > 1) {
		[self switchTabFrom:selectedTab ToTab:[tabs objectAtIndex:[tabs count]-2]];
	} else if ([tabs count] == 0) {
        self.webView = nil;
    }
	[toBeRemoved removeFromSuperview];
	[[toBeRemoved webView] removeFromSuperview];
	[tabs removeObject: toBeRemoved];
	
	
	if ([tabs count] == 0) {
		[self addTab:nil];
	}
	[self loadTabs:[selectedTab webView]];
	
	//scrolling
	tabsView.contentSize = CGSizeMake(((100.0) * [tabs count]) + 40.0, 23.0);
    j=0;
}

-(IBAction) selectTab:(id)sender {
    lblOpenin.hidden = YES;
    btnIBooks.hidden = YES;
	for (id cTab in tabs) {
		if ([cTab tabButton] == sender) {
			[self switchTabFrom:selectedTab ToTab:cTab];
            if ([cTab tabButton].tag ==100) {
                AppDelegate*appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                appdelegate.prevAddress=@"";
            }
		}
	}
	[self loadTabs:[selectedTab webView]];
}

-(void) switchTabFrom:(Tab *)fromTab ToTab:(Tab *)toTab {
	if ([tabs count] > 0) {
		[fromTab deselect];

	}
   
    
    
    
    
	[toTab select];
	selectedTab = toTab;
    selectedTab.tabTitle.text =selectedTab.currentURLString;
    if (![toTab loading]) {
        [[self progressBar] setHidden:YES];
        [[self stopButton] setHidden:YES];
        [[self refreshButton] setHidden:NO];
        [[self addressBar] setText:[selectedTab currentURLString]];
    } else {
        [[self progressBar] setHidden:NO];
        [[self stopButton] setHidden:NO];
        [[self refreshButton] setHidden:YES];
    }
    
    
    NSString *currentURL = [NSString stringWithFormat:@"%@",selectedTab.currentURLString];

    if ([currentURL rangeOfString:@".pdf" options:NSCaseInsensitiveSearch].location != NSNotFound)
    {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapWebView:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.delegate = self;
        [selectedTab.webView addGestureRecognizer:singleTap];
        iBooksPDFPath = currentURL;
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory=[paths objectAtIndex:0];
            
            NSString *finalPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"myFile.pdf"]]; //check your path correctly and provide your name dynamically
            NSLog(@"finalpath--%@",finalPath);
            NSData *datapdf = [NSData dataWithContentsOfURL:[NSURL URLWithString:iBooksPDFPath]];
            
            
            //add url string here
            NSLog(@"data--%@",datapdf);
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(datapdf)
                    [datapdf writeToFile:finalPath atomically:YES];
                
                
                
                
                
            });
        });
        [[self progressBar] setHidden:YES];

    }else{
        [[self progressBar] setHidden:YES];
    }
}

/*-(IBAction) toggleTabsView:(id)sender {
    if ([self isPad]) {
        if (tabsView.hidden) {
            [self webView].frame = CGRectMake([self webView].frame.origin.x,
                                              [self webView].frame.origin.y + tabsView.bounds.size.height,
                                              [self webView].bounds.size.width,
                                              [self webView].bounds.size.height - tabsView.bounds.size.height);
            progressBar.frame = CGRectMake(progressBar.frame.origin.x,
                                           progressBar.frame.origin.y + tabsView.bounds.size.height,
                                           progressBar.frame.size.width,
                                           progressBar.frame.size.height);
            tabsView.hidden = NO;
        } else {
            [self webView].frame = CGRectMake([self webView].frame.origin.x,
                                              [self webView].frame.origin.y - tabsView.bounds.size.height,
                                              [self webView].bounds.size.width,
                                              [self webView].bounds.size.height + tabsView.bounds.size.height);
            progressBar.frame = CGRectMake(progressBar.frame.origin.x,
                                           progressBar.frame.origin.y - tabsView.bounds.size.height,
                                           progressBar.frame.size.width,
                                           progressBar.frame.size.height);
            tabsView.hidden = YES;
        }
    } else {
        if (tabsView.hidden) {

            progressBar.frame = CGRectMake(progressBar.frame.origin.x,
                                           progressBar.frame.origin.y + tabsView.bounds.size.height,
                                           progressBar.frame.size.width,
                                           progressBar.frame.size.height);
            tabsView.hidden = NO;
            addTab.hidden = NO;
        } else {
            addTab.hidden = YES;
            tabsView.hidden = YES;

            progressBar.frame = CGRectMake(progressBar.frame.origin.x,
                                           progressBar.frame.origin.y - tabsView.bounds.size.height,
                                           progressBar.frame.size.width,
                                           progressBar.frame.size.height);
        }
        
        [[[self webView] scrollView] setContentInset:UIEdgeInsetsMake(topBar.frame.size.height, 0, 0, 0)];
        [[[self webView] scrollView] setContentOffset:CGPointMake(0, - topBar.frame.size.height) animated:YES];
    }
    
}*/

// WEBVIEW

-(UIWebView *) webView {
    return [selectedTab webView];
}

-(UIWebView *) setWebView:(UIWebView *)newWebView {
	[selectedTab setWebView:newWebView];
	return newWebView;
}


-(void) loadTabs:(UIWebView *)webView {
    Tab *tab = nil;
	
    [[self view] sendSubviewToBack:webView];
    
	for (id cTab in tabs) {
		if ([cTab webView] == webView) {
			tab = cTab;
		} else {
            [[self view] sendSubviewToBack:[cTab webView]];
        }
	}
	
	if (tab == selectedTab) {
        
            NSString *addressText = tab.currentURLString;
        
                if (![addressBar isFirstResponder]) {
                    [addressBar setText: addressText];
                }
                [refreshButton setHidden:[tab loading]];
            
            
        
        
		if([selectedTab canGoForward]) {
			forwardButton.enabled = TRUE;
		}
		else if(![selectedTab canGoForward]) {
			forwardButton.enabled = FALSE;
		}
		if([selectedTab canGoBack]) {
			backButton.enabled = TRUE;
		}
		else if(![selectedTab canGoBack]) {
			backButton.enabled = FALSE;
		}
        
        NSString *currentURL = [NSString stringWithFormat:@"%@",tab.currentURL];
        if ([currentURL rangeOfString:@".pdf" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapWebView:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.delegate = self;
            [selectedTab.webView addGestureRecognizer:singleTap];
            iBooksPDFPath = currentURL;
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                
                NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDirectory=[paths objectAtIndex:0];
                
                NSString *finalPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"myFile.pdf"]]; //check your path correctly and provide your name dynamically
                NSLog(@"finalpath--%@",finalPath);
                NSData *datapdf = [NSData dataWithContentsOfURL:[NSURL URLWithString:iBooksPDFPath]];
                
                
                //add url string here
                NSLog(@"data--%@",datapdf);
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(datapdf)
                        [datapdf writeToFile:finalPath atomically:YES];
                    
                    
                    
                    
                    
                });
            });
            
        }

	}
    // Set title
    //[tab showText];
}
- (void)singleTapWebView:(UITapGestureRecognizer *)gesture
{
    if(value==false)
    {
        lblOpenin.hidden = NO;
        btnIBooks.hidden = NO;
        value = true;
        timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:NO];
        return;
    }
    
    lblOpenin.hidden = YES;
    btnIBooks.hidden = YES;
    value = false;
    [timer invalidate];
    return;
}
- (void)timerTick:(NSTimer *)timer {
    
    lblOpenin.hidden = YES;
    btnIBooks.hidden = YES;
    value = false;
}
-(IBAction) btnIBooks:(id)sender
{
    //---locally save PDF
 
    NSString *abc = [NSString stringWithFormat:@"%@",iBooksPDFPath];
    
    NSLog(@"%@",abc);
    
    //---
    
    //to get path of saved pdf with myFile name
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    
    NSString *finalPath=[documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"myFile.pdf"]]; //check your path correctly and provide your name dynamically
    NSLog(@"finalpath--%@",finalPath);
    
    
    //---
    // check pdf exist or not
    NSString* foofile = [documentDirectory stringByAppendingPathComponent:@"myFile.pdf"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    if(fileExists)
    {
        NSLog(@"yes exists");
    }
    
    finalPath = [NSString stringWithFormat:@"file://%@",finalPath];
    
    //NSURL *url = [[NSBundle mainBundle]URLForResource: @"myFile" withExtension:@"pdf"];
    
    docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL URLWithString:finalPath]];
    docController.delegate = self;
    CGRect rect = btnIBooks.frame;
    rect.origin.y = btnIBooks.frame.origin.y;
    // CGRect r = CGRectMake(btnIBooks.frame.origin.x-30, btnIBooks.frame.origin.y, 300, 300);
    BOOL isValid = [docController presentOpenInMenuFromRect:rect inView:self.view animated:YES];
    NSLog(@"Is valid %d",isValid);
    [timer invalidate];
    


}
#pragma mark - Show Indicator
-(void)ShowIndicator
{
    activityIndicatorObject = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityIndicatorObject.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    DisableView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        activityIndicatorObject.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        DisableView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1400, 1400)];
    }
    DisableView.backgroundColor=[UIColor blackColor];
    DisableView.alpha=0.5;
    [self.view addSubview:DisableView];
    activityIndicatorObject.color=[UIColor grayColor];
    [DisableView addSubview:activityIndicatorObject];
    [activityIndicatorObject startAnimating];
}

#pragma mark - Hide Indicator

-(void)HideIndicator
{
    [activityIndicatorObject stopAnimating];
    [DisableView removeFromSuperview];
}
// Orientation

- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskAll;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIDeviceOrientationPortrait;
}


// Reachability
- (BOOL) checkNetworkStatus
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus *netstat = [reachability currentReachabilityStatus];
    return netstat != NotReachable;
}

// HARDWARE
- (BOOL) isPad {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}
#pragma mark - Hide Indicator
- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application{
    
    NSLog(@"willBeginSendingToApplication");
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application{
    NSLog(@"didEndSendingToApplication");
    
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller{
    NSLog(@"documentInteractionControllerDidDismissOpenInMenu");
    
    lblOpenin.hidden = YES;
    btnIBooks.hidden = YES;
    value = false;
}

@end
