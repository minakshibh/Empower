//
//  APIRequest.m
//  OpenRadtab
//
//  Created by ravi kumar on 03/12/14.
//  Copyright (c) 2014 masterSoftwareSolutions. All rights reserved.
//

#import "APIRequest.h"

@implementation APIRequest

#pragma mark
#pragma mark post request


+(NSString *)postRequestUrl:(NSString *)url parameters:(id)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString
{
    
    UIWindow *appDel= [[[UIApplication sharedApplication]delegate]window];
    
    if (indicator==YES) {
        if (indicatorMessage==nil) {
            indicatorMessage=@"";
        }
        [DejalBezelActivityView activityViewForView:appDel.rootViewController.view withLabel:indicatorMessage];
    }
    
    NSLog(@"url  ==== %@",url);
    NSLog(@"parameters  ==== %@",parameters);
    if (headers==nil) {
        [[LRResty client] post:url payload:parameters
                     withBlock:^(LRRestyResponse *response){
                         NSLog(@"res %@",response);
                         NSError* error;
                         if (response.status==0) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self noInternetConnectionAlert];
                             return;
                         }
                         
                         if (withErrorResponse==YES) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                             json=[json dictionaryByRemovingNull];
                             responseString((NSMutableDictionary*) json);
                             return;
                         }
                         if (response.status==400) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self ErrorMessage];
                             
                             return;
                         }
                         
                         if (response.status==404) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self ErrorMessage];
                             return;
                         }
                         
                         if (response.status==503) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self ErrorMessage];
                             
                             return;
                         }
                         
                         if (response.status==200) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                             json=[json dictionaryByRemovingNull];
                             responseString((NSMutableDictionary*) json);
                         }
                         
                         if (response.status==409) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self ErrorMessage];
                             
                             return;
                         }
                         
                         if (response.status==500) {
                             [DejalBezelActivityView removeViewAnimated:YES];
                             [self ErrorMessage];
                             
                             return;
                         }
                         
                     }];
        
    }else if(headers!=nil)
    {
        
        [[LRResty client] post:url payload:parameters headers:headers withBlock:^(LRRestyResponse *response){
            
            NSError* error;
            if (response.status==0) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self noInternetConnectionAlert];
                
                
                return;
            }
            if (withErrorResponse==YES) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
                return;
            }
            if (response.status==400) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            if (response.status==404) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            if (response.status==409) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            
            if (response.status==503) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            
            if (response.status==500) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            
            
            
            if (response.status==200) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
            }
            
            
            
        }];
    }
    
    return (NSString*)responseString;
}

#pragma mark
#pragma mark get request

+(NSString *)getRequestUrl:(NSString *)url parameters:(NSMutableDictionary *)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;
{
    
   
    UIWindow *appDel= [[[UIApplication sharedApplication]delegate]window];
    if (indicator==YES) {
        if (indicatorMessage==nil) {
            indicatorMessage=@"";
        }
        [DejalBezelActivityView activityViewForView:appDel.rootViewController.view withLabel:indicatorMessage];
    }
    NSLog(@"url  ==== %@",url);
    NSLog(@"parameters  ==== %@",parameters);
    if (headers==nil) {
        
        [[LRResty client] get:url parameters:parameters
                    withBlock:^(LRRestyResponse *response){
                        NSLog(@"res : %@",response.asString);
                        NSLog(@"res.status : %@",response);
                        NSError* error;
                        if (response.status==0) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self noInternetConnectionAlert];
                            return;
                        }
                        if (withErrorResponse==YES) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                            json=[json dictionaryByRemovingNull];
                            responseString((NSMutableDictionary*) json);
                            return;
                        }
                        if (response.status==400) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            return;
                        }
                        if (response.status==404) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        if (response.status==503) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        if (response.status==500) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        
                        if (response.status==200) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData
                                                                                        options:kNilOptions
                                                                                          error:&error];
                            json=[json dictionaryByRemovingNull];
                            responseString((NSMutableDictionary*) json);
                        }
                        
                    }];
        
    }else if(headers!=nil)
    {
        [[LRResty client] get:url parameters:parameters headers:headers withBlock:^(LRRestyResponse *response){
            
            
            NSLog(@"status %lu",(unsigned long)response.status);
            if (response.status==0) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self noInternetConnectionAlert];
                
                return;
            }
            if (withErrorResponse==YES) {
                NSError* error;
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
                return;
            }
            if (response.status==400) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            if (response.status==404) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            if (response.status==503) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            if (response.status==500) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            
            
            
            if (response.status==200) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSError* error;
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData
                                                                            options:kNilOptions
                                                                              error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
            }
        }];
    }
    
    return (NSString*)responseString;
}



#pragma mark
#pragma mark delete request

+(NSString *)deleteRequestUrl:(NSString *)url parameters:(NSMutableDictionary *)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;
{
    
    UIWindow *appDel= [[[UIApplication sharedApplication]delegate]window];
    if (indicator==YES) {
        if (indicatorMessage==nil) {
            indicatorMessage=@"";
        }
        [DejalBezelActivityView activityViewForView:appDel.rootViewController.view withLabel:indicatorMessage];
    }
    
    NSLog(@"url  ==== %@",url);
    NSLog(@"parameters  ==== %@",parameters);
    if(headers!=nil)
    {
        
        
        [[LRResty client] delete:url headers:headers withBlock:^(LRRestyResponse *response){
            NSError* error;
            
            if (response.status==0) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self noInternetConnectionAlert];
                return;
            }
            if (withErrorResponse==YES) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
                return;
            }
            if (response.status==400) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            if (response.status==404) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            
            if (response.status==500) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                return;
            }
            
            
            if (response.status==200) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData
                                                                            options:kNilOptions
                                                                              error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
            }
            
            
        }];
    }
    
    return (NSString*)responseString;
}


#pragma mark
#pragma mark Put request

+(NSString *)putRequestUrl:(NSString *)url parameters:(id)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;
{
    
    UIWindow *appDel= [[[UIApplication sharedApplication]delegate]window];
    
    NSLog(@"url  ==== %@",url);
    NSLog(@"parameters  ==== %@",parameters);
    if (indicator==YES) {
        if (indicatorMessage==nil) {
            indicatorMessage=@"";
        }
        [DejalBezelActivityView activityViewForView:appDel.rootViewController.view withLabel:indicatorMessage];
    }
    if (headers==nil) {
        [[LRResty client] put:url payload:parameters
                    withBlock:^(LRRestyResponse *response){
                        NSLog(@"res %lu",(unsigned long)response.asString);
                        NSError* error;
                        if (response.status==0) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self noInternetConnectionAlert];
                            
                            return;
                        }
                        if (withErrorResponse==YES) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                            json=[json dictionaryByRemovingNull];
                            responseString((NSMutableDictionary*) json);
                            return;
                        }
                        if (response.status==400) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        if (response.status==404) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        if (response.status==503) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        if (response.status==200) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                            NSLog(@"jaon jaon %@",json);
                            json=[json dictionaryByRemovingNull];
                            responseString((NSMutableDictionary*) json);
                        }
                        
                        if (response.status==409) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                           [self ErrorMessage];
                            
                            return;
                        }
                        
                        if (response.status==500) {
                            [DejalBezelActivityView removeViewAnimated:YES];
                            [self ErrorMessage];
                            
                            return;
                        }
                        
                        
                        
                        
                    }];
        
    }else if(headers!=nil)
    {
        NSLog(@"parameters parameters %@",parameters);
        [[LRResty client] put:url payload:parameters headers:headers withBlock:^(LRRestyResponse *response){
            NSLog(@"res as String %lu",(unsigned long)response.status);
            
            NSError* error;
            if (response.status==0) {
                [DejalBezelActivityView removeViewAnimated:YES];
               [self noInternetConnectionAlert];
                
                return;
            }
            
            if (withErrorResponse==YES) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions  error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
                return;
            }
            
            if (response.status==400) {
                [DejalBezelActivityView removeViewAnimated:YES];
               [self ErrorMessage];
                return;
            }
            if (response.status==404) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            if (response.status==409) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            
            if (response.status==503) {
                [DejalBezelActivityView removeViewAnimated:YES];
               [self ErrorMessage];
                
                return;
            }
            if (response.status==500) {
                [DejalBezelActivityView removeViewAnimated:YES];
                [self ErrorMessage];
                
                return;
            }
            
            
            if (response.status==200) {
                [DejalBezelActivityView removeViewAnimated:YES];
                NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:response.responseData  options:kNilOptions error:&error];
                json=[json dictionaryByRemovingNull];
                responseString((NSMutableDictionary*) json);
            }
            
            
            
            
        }];
    }
    
    return (NSString*)responseString;
}

#pragma mark
#pragma mark alert messages

+(void)noInternetConnectionAlert
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

+(void)ErrorMessage
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"There is some problem ,Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
