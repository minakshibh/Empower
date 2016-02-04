//
//  APIRequest.h
//  OpenRadtab
//
//  Created by ravi kumar on 03/12/14.
//  Copyright (c) 2014 masterSoftwareSolutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRResty.h"
#import "ISRemoveNull.h"
#import "DejalActivityView.h"
#import <UIKit/UIKit.h>
@interface APIRequest : NSObject
{
    NSMutableData *dataReceived;
    NSURLConnection *UrlConnection;
}


/**
**** Post Request *****
 PostRequestUrl : give your complete url
 
 Parameters: Make a dictionary of parameters ,key should be your parameter name and value should be your                        parameter value
 
 Headers   : Make a dictionary of headers ,key should be your header name and value should be your                        header value
 
 Indicator : If you want to display Activity Indicator pass bool value YES else NO
 
 Indicator Message : Give a message you want to display below activity indicator (ex: loading)
 
 WithErrorResponse: if you want only success response give a bool value NO 
 if you want to handle errors give a bool value YES
 
 Response : Respons is your api response in dictionary format
 
**/
+(NSString *)postRequestUrl:(NSString *)url parameters:(id)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;
/**
 **** Get Request *****
 
 GetRequestUrl : give your complete url
 
 Parameters: Make a dictionary of parameters ,key should be your parameter name and value should be your                        parameter value
 
 Headers   : Make a dictionary of headers ,key should be your header name and value should be your                        header value
 
 Indicator : If you want to display Activity Indicator pass bool value YES else NO
 
 Indicator Message : Give a message you want to display below activity indicator (ex: loading)
 
 WithErrorResponse: if you want only success response give a bool value NO
 if you want to handle errors give a bool value YES
 
 Response : Respons is your api response in dictionary format
 
 **/
+(NSString *)getRequestUrl:(NSString *)url parameters:(NSMutableDictionary *)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;
/**
 **** Delete Request *****

 deleteRequestUrl : give your complete url
 
 Parameters: Make a dictionary of parameters ,key should be your parameter name and value should be your                        parameter value
 
 Headers   : Make a dictionary of headers ,key should be your header name and value should be your                        header value
 
 Indicator : If you want to display Activity Indicator pass bool value YES else NO
 
 Indicator Message : Give a message you want to display below activity indicator (ex: loading)
 
 WithErrorResponse: if you want only success response give a bool value NO
 if you want to handle errors give a bool value YES
 
 Response : Respons is your api response in dictionary format
 
 **/

+(NSString *)deleteRequestUrl:(NSString *)url parameters:(NSMutableDictionary *)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;


/**
 **** Put Request *****
 
 PutRequestUrl : give you complete url
 
 Parameters: Make a dictionary of parameters ,key should be your parameter name and value should be your                        parameter value
 
 Headers   : Make a dictionary of headers ,key should be your header name and value should be your                        header value
 
 Indicator : If you want to display Activity Indicator pass bool value YES else NO
 
 Indicator Message : Give a message you want to display below activity indicator (ex: loading)
 
 WithErrorResponse: if you want only success response give a bool value NO
 if you want to handle errors give a bool value YES
 
 Response : Respons is your api response in dictionary format
 
 **/
+(NSString *)putRequestUrl:(NSString *)url parameters:(id)parameters headers:(NSMutableDictionary *)headers indicator:(BOOL)indicator indicatorMessage:(id)indicatorMessage withErrorResponse:(BOOL)withErrorResponse response:(void (^)(NSMutableDictionary *))responseString;

+(void)noInternetConnectionAlert;
+(void)ErrorMessage;



@end
