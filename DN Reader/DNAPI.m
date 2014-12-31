//
//  DNAPI.m
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/30/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import "DNAPI.h"
#import "SOCKit.h"
#import "AFURLRequestSerialization.h"

NSString *const DNAPIBaseURL  = @"https://api-news.layervault.com";
NSString *const DNAPIStories  = @"/api/v1/stories?client_id=750ab22aac78be1c6d4bbe584f0e3477064f646720f327c5464bc127100a1a6d";
NSString *const DNAPIComments = @"/api/v1/comments/:id";
NSString *const DNAPILogin    = @"/oauth/token";

#pragma mark -

@interface NSURL (DNAPI)

+ (NSURL *)DNURLWithString:(NSString *)string;

@end

@implementation NSURL (DNAPI)

+ (NSURL *)DNURLWithString:(NSString *)string {
    return [[self class] URLWithString:[NSString stringWithFormat:@"%@%@", [self baseURL], string]];
}

+ (NSString *)baseURL {
    NSString *baseURLConfiguration = [[[NSProcessInfo processInfo] environment] objectForKey:@"baseURL"];
    
    return baseURLConfiguration ?: DNAPIBaseURL;
}

@end

@implementation NSURLRequest (DNAPI)

+ (NSURLRequest *)requestWithPattern:(NSString *)string object:(id)object {
    SOCPattern *pattern = [SOCPattern patternWithString:string];
    NSString *urlString = [pattern stringFromObject:object];
    NSURLRequest *request = [self requestWithURL:[NSURL DNURLWithString:urlString]];
    return request;
}

+ (NSURLRequest *)postRequest:(NSString *)string parameters:(NSDictionary *)parameters {
    return [NSURLRequest requestWithMethod:@"POST"
                                       url:string
                                parameters:parameters];
}

+ (NSURLRequest *)deleteRequest:(NSString *)string parameters:(NSDictionary *)parameters {
    return [NSURLRequest requestWithMethod:@"DELETE"
                                       url:string
                                parameters:parameters];
}

+ (NSURLRequest *)requestWithMethod:(NSString *)method
                                url:(NSString *)url
                         parameters:(NSDictionary *)parameters {
    
    SOCPattern *pattern = [SOCPattern patternWithString:url];
    NSString *urlString = [pattern stringFromObject:parameters];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:method
                                    URLString:[NSString stringWithFormat:@"%@%@", [NSURL baseURL], urlString]
                                    parameters:parameters];
    return request;
}

@end
