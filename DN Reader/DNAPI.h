//
//  DNAPI.h
//  DN Reader
//
//  Created by Mario C. Delgado Jr. on 12/30/14.
//  Copyright (c) 2014 Mario C. Delgado Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
//referencing variables
extern NSString *const DNAPIBaseURL;
extern NSString *const DNAPIStories;
extern NSString *const DNAPIComments;
extern NSString *const DNAPILogin;

@interface NSURLRequest (DNAPI)


+ (instancetype)requestWithPattern: (NSString *)string object:(id)object;
+ (instancetype)postRequest: (NSString *)string parameters:(NSDictionary *)parameters;
+ (instancetype)deleteRequest: (NSString *)string parameters:(NSDictionary *)parameters;
+ (instancetype)requestWithMethod:(NSString *)method url:(NSString *)url parameters:(NSDictionary *)parameters;



@end
