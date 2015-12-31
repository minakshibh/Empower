//
//  AppDelegate.h
//  TestBrowser
//
//  Created by Alexandru Catighera on 3/14/13.
//  Copyright (c) 2013 Alexandru Catighera. All rights reserved.
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import <UIKit/UIKit.h>
#import "BrowserDelegate.h"

@class BrowserViewController;

@interface AppDelegate : BrowserDelegate <UIApplicationDelegate>
{
    NSMutableArray *arrSites;
    NSUserDefaults *sharedUserDefaults;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *prevAddress;
@property (strong, nonatomic) BrowserViewController *viewController;



@end