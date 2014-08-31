//
//  JKLocuRequest.h
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 2/15/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//

// #import <Foundation/Foundation.h>

@protocol JKLocuRequestDelegate;

@interface JKLocuRequest : NSObject

@property(nonatomic,copy,readonly) NSString *path;
@property(nonatomic,copy,readonly) NSString *HTTPMethod;
@property(nonatomic,copy,readonly) NSDictionary *parameters;
@property(nonatomic,assign) id <JKLocuRequestDelegate> delegate;
@property(nonatomic,retain) NSOperationQueue *delegateQueue NS_AVAILABLE(NA, 6_0);

@property(nonatomic,copy,readonly) NSDictionary *response;

+ (NSURL *)baseURL;
- (id)initWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<JKLocuRequestDelegate>)delegate;

- (void)start;
- (void)cancel;

@end

@protocol JKLocuRequestDelegate <NSObject>
@optional
- (void)jkRequestDidStartLoading:(JKLocuRequest *)request;
- (void)jkRequestDidFinishLoading:(JKLocuRequest *)request;
- (void)jkRequest:(JKLocuRequest *)request didFailWithError:(NSError *)error;
@end
