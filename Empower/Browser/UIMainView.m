//
//  UIMainView.m
//
//  Created by Alexandru Catighera on 10/17/13.
//
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import "UIMainView.h"
#import "BrowserViewController.h"

@implementation UIMainView

@synthesize statusBarView, statusViewHeightConstraint, controller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

- (void) sizeStatusBar {
    /*if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        statusViewHeightConstraint.constant = 2.0;
        statusBarView.backgroundColor = [UIColor blackColor];
    }*/
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([event type]==UIEventTypeTouches) {
        UIView *v=[super hitTest:point withEvent:event];
        if (statusBarView==v) {
            [controller scrollToTop:self];
        } else {
            return v;
        }
    }
    return nil;
}

@end