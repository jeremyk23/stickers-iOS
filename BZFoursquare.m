/*
 * Copyright (C) 2011-2013 Ba-Z Communication Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import "BZFoursquare.h"

#ifndef __has_feature
#define __has_feature(x) 0
#endif

#define kMinSupportedVersion    @"20120609"
#define kAuthorizeBaseURL       @"https://foursquare.com/oauth2/authorize"

@interface BZFoursquare ()
@property(nonatomic,copy,readwrite) NSString *clientID;
@property(nonatomic,copy,readwrite) NSString *callbackURL;
@end

@implementation BZFoursquare

- (id)init {
    return [self initWithClientID:nil callbackURL:nil];
}

- (id)initWithClientID:(NSString *)clientID callbackURL:(NSString *)callbackURL {
    NSParameterAssert(clientID != nil && callbackURL != nil);
    self = [super init];
    if (self) {
        self.clientID = clientID;
        self.callbackURL = callbackURL;
        self.version = kMinSupportedVersion;
    }
    return self;
}

- (BZFoursquareRequest *)requestWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<BZFoursquareRequestDelegate>)delegate {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
//    if (_accessToken) {
//        mDict[@"oauth_token"] = _accessToken;
//    }
    if (_version) {
        mDict[@"v"] = _version;
    }
    if (_locale) {
        mDict[@"locale"] = _locale;
    }
    return [[BZFoursquareRequest alloc] initWithPath:path HTTPMethod:HTTPMethod parameters:mDict delegate:delegate];
}

- (BZFoursquareRequest *)userlessRequestWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<BZFoursquareRequestDelegate>)delegate {
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    mDict[@"client_id"] = _clientID;
    if (_clientSecret) {
        mDict[@"client_secret"] = _clientSecret;
    }
    if (_version) {
        mDict[@"v"] = _version;
    }
    if (_locale) {
        mDict[@"locale"] = _locale;
    }
    return [[BZFoursquareRequest alloc] initWithPath:path HTTPMethod:HTTPMethod parameters:mDict delegate:delegate];
}

@end
