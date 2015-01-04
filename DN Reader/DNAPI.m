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
#import "ACSimpleKeychain.h"


NSString *const DNAPIBaseURL  = @"https://api-news.layervault.com";
NSString *const DNAPIStories  = @"/api/v1/stories?client_id=750ab22aac78be1c6d4bbe584f0e3477064f646720f327c5464bc127100a1a6d";
NSString *const DNAPIComments = @"/api/v1/comments/:id";
NSString *const DNAPILogin    = @"/oauth/token";
NSString *const DNAPIStoriesUpvote = @"/api/v1/stories/:id/upvote";


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

@implementation DNAPI

+ (void)upvoteWithStory:(NSDictionary *)story {
    // Token
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [keychain credentialsForUsername:@"token" service:@"DN"];
    NSString *token = [credentials valueForKey:ACKeychainIdentifier];
    
    // POST data
    NSURLRequest *request = [NSURLRequest postRequest:DNAPIStoriesUpvote
                                           parameters:@{@"id":story[@"id"]}];
    // With authorization
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    request = [mutableRequest copy];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSError *serializeError;
                                            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializeError];
                                            double delayInSeconds = 1.0f;   // Just for debug
                                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                
                                                // Get response
                                                NSLog(@"Upvote response: %@", json);
                                            });
                                        }];
    [task resume];
}

@end

@implementation DNUser

+ (void)saveUpvoteWithStory:(NSDictionary *)story
{
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [keychain credentialsForUsername:@"token" service:@"DN"];
    NSString *token = [credentials valueForKey:ACKeychainIdentifier];
    NSString *upvotes = [credentials valueForKey:ACKeychainPassword];
    upvotes = [NSString stringWithFormat:@"%@,%@", upvotes, story[@"id"]];
    if ([keychain storeUsername:@"token" password:upvotes identifier:token forService:@"DN"]) {
        NSLog(@"Update upvotes %@", upvotes);
    }
}

+ (void)isUpvotedWithStory:(NSDictionary *)story completion:(void (^)(BOOL succeed, NSError *error))completion
{
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [keychain credentialsForUsername:@"token" service:@"DN"];
    NSString *upvotes = [credentials valueForKey:ACKeychainPassword];
    NSArray *upvotesArray = [upvotes componentsSeparatedByString:@","];
    NSString *idString = [NSString stringWithFormat:@"%@", story[@"id"]];
    
    if([upvotesArray containsObject: idString]) {
        completion(YES, nil);
    }
}

@end


