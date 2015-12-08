//
//  firstViewController.h
//  sampleWebView
//
//  Created by Krishna Mac Mini 2 on 16/10/15.
//  Copyright © 2015 Krishna_Mac_2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface firstViewController : UIViewController
{
    
    IBOutlet UILabel *lblbacktxt;
    IBOutlet UIButton *btnCancel;
    IBOutlet UITextField *txtField;
}
@property (strong, nonatomic) IBOutlet UITextField *txtSearch;
- (IBAction)btnSave:(id)sender;
- (IBAction)btnCancel:(id)sender;
- (IBAction)btnSave1:(id)sender;
@property (weak, nonatomic) IBOutlet NSString *firstTime;

@end
