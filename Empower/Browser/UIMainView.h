//
//  UIStatusBarView.h
//
//  Created by Alexandru Catighera on 10/17/13.
//
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import <UIKit/UIKit.h>
@class BrowserViewController;

@interface UIMainView : UIView {
    IBOutlet UIView *statusBarView;
    IBOutlet BrowserViewController *controller;
    IBOutlet NSLayoutConstraint *statusViewHeightConstraint;
}

@property(nonatomic,strong) UIView *statusBarView;
@property(nonatomic,strong) BrowserViewController *controller;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *statusViewHeightConstraint;

- (void) sizeStatusBar;

@end
