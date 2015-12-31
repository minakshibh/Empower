//
//  ShareViewController.m
//  Empower2
//
//  Created by Krishna Mac Mini 2 on 30/12/15.
//  Copyright © 2015 Alexandru Catighera. All rights reserved.
//

#import "ShareViewController.h"
@import MobileCoreServices;

static NSString *const AppGroupId = @"group.empowerExtention";

@interface ShareViewController ()
{
    SLComposeSheetConfigurationItem *item;
}
@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}
-(void)viewDidLoad
{
    sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroupId];
    // here you must have to provide your app group id that you already created
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
 //--->   [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    
    
    inputItem = self.extensionContext.inputItems.firstObject;
    NSItemProvider *urlItemProvider = [[inputItem.userInfo valueForKey:NSExtensionItemAttachmentsKey] objectAtIndex:0];
    if ([urlItemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL])
    {
        [urlItemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error)
            {
                NSLog(@"Error occured");
            }
            else
            {
                NSMutableArray *arrSites;
                if ([sharedUserDefaults valueForKey:@"SharedExtension"])
                    arrSites = [sharedUserDefaults valueForKey:@"SharedExtension"];
                else
                    arrSites = [[NSMutableArray alloc] init];
                NSDictionary *dictSite = [NSDictionary dictionaryWithObjectsAndKeys:self.contentText, @"Text", url.absoluteString, @"URL",nil];
                
                
                
                
                
                [arrSites addObject:dictSite];
                [sharedUserDefaults setObject:arrSites forKey:@"SharedExtension"];
                [sharedUserDefaults synchronize];
                UIAlertController * alert= [UIAlertController
                                            alertControllerWithTitle:@"Success"
                                            message:@"Posted Successfully."
                                            preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                {
                    [UIView animateWithDuration:0.20 animations:^
                    {
                        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
                    }
                                     completion:^(BOOL finished)
                    {
                        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
                    }];
                }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments )
    {
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
        {
            [itemProvider loadItemForTypeIdentifier:@"public.url" options:nil completionHandler:
             ^(id<NSSecureCoding> itema, NSError *error)
             {
                 NSLog(@"%@",itema);
                 
                 NSData *data1 = [NSData dataWithContentsOfURL:(NSURL*)itema];                 NSLog(@"%@",data1);
                
                 
             }];

        }
        if([itemProvider hasItemConformingToTypeIdentifier:@"public.image"])
        {
            [itemProvider loadItemForTypeIdentifier:@"public.image" options:nil completionHandler:
             ^(id<NSSecureCoding> item, NSError *error)
             {
                 UIImage *sharedImage = nil;
                 if([(NSObject*)item isKindOfClass:[NSURL class]])
                 {
                     NSLog(@"1");
                     sharedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)item]];
                 }
                 if([(NSObject*)item isKindOfClass:[UIImage class]])
                 {
                     NSLog(@"2");
                     sharedImage = (UIImage*)item;
                 }
             }];
        }
    }
   [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

- (NSArray *)configurationItems {
    item = [[SLComposeSheetConfigurationItem alloc] init];
    // Give your configuration option a title.
    [item setTitle:@"Item One"];
    // Give it an initial value.
    [item setValue:@"None"];
    // Handle what happens when a user taps your option.
    [item setTapHandler:^(void){
    }];
    // Return an array containing your item.
    return @[item];
}

@end
