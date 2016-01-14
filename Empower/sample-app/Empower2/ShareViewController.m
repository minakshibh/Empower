//
//  ShareViewController.m
//  Empower2
//
//  Created by Krishna Mac Mini 2 on 30/12/15.
//  Copyright © 2015 Alexandru Catighera. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@import MobileCoreServices;

static NSString *const AppGroupId = @"group.empowerExtention";
static NSString *const APP_SHARE_URL_SCHEME = @"com.empower";

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
   
    
    
    NSExtensionItem *item1 = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item1.attachments.firstObject;
    
    NSData *data = item1.attachments.firstObject;
    NSLog(@"%@",data);
    NSArray *arrayStr = [[NSString stringWithFormat:@"%@",data] componentsSeparatedByString:@"\""];
    NSString *val = [NSString stringWithFormat:@"%@",[arrayStr objectAtIndex:1]];
    
        if([itemProvider hasItemConformingToTypeIdentifier:val])
        {
            [itemProvider loadItemForTypeIdentifier:val options:nil completionHandler:
            ^(id<NSSecureCoding> item2, NSError *error)
            {
                if ([val isEqualToString:@"public.image"]) {
               
                    UIImage *sharedImage = nil;
                    if([(NSObject*)item2 isKindOfClass:[UIImage class]])
                    {
                        sharedImage = (UIImage*)item2;
                        NSData *imageData = UIImagePNGRepresentation(sharedImage);
                        NSLog(@"%@",imageData);
                        NSLog(@"2");
                        
                        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:AppGroupId];
                        [shared setObject:imageData forKey:@"data"];
                        [shared setObject:@"image" forKey:@"type"];
                        [shared setObject:item2 forKey:@"url"];
                        [shared synchronize];
                        [self invokeApp:[NSString stringWithFormat:@"%@",item2]];
                    }
                    if([(NSObject*)item2 isKindOfClass:[NSURL class]])
                    {
                        NSLog(@"1");
                        sharedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:(NSURL*)item2]];
                    }
                }else{
                    NSString *str = [NSString stringWithFormat:@"%@",item2];
                    NSString *typeStr = [self mimeTypeForFileAtPath:[NSURL URLWithString:str]];
                    NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[
                                                                             NSURL URLWithString:str]];
                    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:AppGroupId];
                    [shared setObject:pdfData forKey:@"data"];
                    [shared setObject:typeStr forKey:@"type"];
                    [shared setObject:str forKey:@"url"];
                    [shared synchronize];
                    [self invokeApp:str];
                    NSLog(@"%@",pdfData);
                   
                    
                }
                
            }];
        }
    
    

    // ↓ this is the wrong location ↓
    
}
- (NSString*) mimeTypeForFileAtPath: (NSURL *) path {
    
    // Borrowed from http://stackoverflow.com/questions/5996797/determine-mime-type-of-nsdata-loaded-from-a-file
    // itself, derived from  http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    
    if (!mimeType) {
        //return @"application/octet-stream";
        return  @"";
    }
    return [NSString stringWithFormat:@"%@",mimeType];
    //return NSMakeCollectable((NSString *)mimeType) ;
}

- ( void ) invokeApp: ( NSString * ) invokeArgs
{
    // Prepare the URL request
    // this will use the custom url scheme of your app
    // and the paths to the photos you want to share:
    NSString * urlString = [ NSString stringWithFormat: @"%@://%@", APP_SHARE_URL_SCHEME, ( NULL == invokeArgs ? @"" : invokeArgs ) ];
    NSURL * url = [ NSURL URLWithString: urlString ];
    
    NSString *className = @"UIApplication";
    if ( NSClassFromString( className ) )
    {
        id object = [ NSClassFromString( className ) performSelector: @selector( sharedApplication ) ];
        [ object performSelector: @selector( openURL: ) withObject: url ];
    }
    
    // Now let the host app know we are done, so that it unblocks its UI:
    [ super didSelectPost ];
}

- (NSArray *)configurationItems {
   
    return @[];
}

@end
