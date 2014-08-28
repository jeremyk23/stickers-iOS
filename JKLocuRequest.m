//
//  JKLocuRequest.m
//  TasteBuds
//
//  Created by Jeremy Klein Sr on 2/15/14.
//  Copyright (c) 2014 Max Lemkin. All rights reserved.
//

#import "JKLocuRequest.h"

#define API_BASE_URL           @"http://api.locu.com/v1_0/venue/"
#define TIMEOUT_INTERVAL        180.0

@interface JKLocuRequest()
@property(nonatomic,copy,readwrite) NSString *path;
@property(nonatomic,copy,readwrite) NSString *HTTPMethod;
@property(nonatomic,copy,readwrite) NSDictionary *parameters;
@property(nonatomic,retain) NSURLConnection *connection;
@property(nonatomic,retain) NSMutableData *responseData;
@property(nonatomic,copy,readwrite) NSDictionary *response;
@property(nonatomic,retain,setter=_setDelegateQueue:) NSOperationQueue *_delegateQueue;
- (NSURLRequest *)requestForGETMethod;
@end

@implementation JKLocuRequest

+ (NSURL *)baseURL
{
    return [NSURL URLWithString:API_BASE_URL];
}

- (id)initWithPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters delegate:(id<JKLocuRequestDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.path = path;
        self.HTTPMethod = HTTPMethod ?: @"GET";
        self.parameters = parameters;
        self.delegate = delegate;
    }
    return self;
}

- (NSOperationQueue *)delegateQueue
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        // 5.1.x or earlier
        // Note: NSURLConnection setDelegateQueue is broken on iOS 5.x.
        // See http://openradar.appspot.com/10529053.
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    } else {
        // 6.0 or later
        return __delegateQueue;
    }
}

- (void)setDelegateQueue:(NSOperationQueue *)delegateQueue
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
        // 5.1.x or earlier
        // Note: NSURLConnection setDelegateQueue is broken on iOS 5.x.
        // See http://openradar.appspot.com/10529053.
        [self doesNotRecognizeSelector:_cmd];
    } else {
        // 6.0 or later
        self._delegateQueue = delegateQueue;
    }
}

- (void)start
{
    [self cancel];
    self.response = nil;
    NSURLRequest *request;
    if ([_HTTPMethod isEqualToString:@"GET"]) {
        request = [self requestForGETMethod];
    } else {
        NSAssert2(NO, @"*** %s: HTTP %@ method not supported", __PRETTY_FUNCTION__, _HTTPMethod);
        request = nil;
    }
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    NSAssert1(_connection != nil, @"*** %s: connection is nil", __PRETTY_FUNCTION__);
    if (__delegateQueue) {
        [_connection setDelegateQueue:__delegateQueue];
    }
    [_connection start];
}

- (void)cancel {
    if (_connection) {
        [_connection cancel];
        self.connection = nil;
        self.responseData = nil;
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [NSMutableData data];
    if ([_delegate respondsToSelector:@selector(jkRequestDidStartLoading:)]) {
        [_delegate jkRequestDidStartLoading:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if (!response) {
        goto bye;
    }
    self.response = response;
bye:
    if (error) {
        if ([_delegate respondsToSelector:@selector(jkRequest:didFailWithError:)]) {
            ([_delegate jkRequest:self didFailWithError:error]);
        }
    } else {
        if ([_delegate respondsToSelector:@selector(jkRequestDidFinishLoading:)]) {
            [_delegate jkRequestDidFinishLoading:self];
        }
    }
    self.connection = nil;
    self.responseData = nil;
}

#pragma mark GET Request Format

- (NSURLRequest *)requestForGETMethod
{
    //array to hold query string
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in _parameters) {
        NSString *value = _parameters[key];
        //if its not a string, see if it's a number
        if (![value isKindOfClass:[NSString class]]) {
            if ([value isKindOfClass:[NSNumber class]]) {
                value = [value description];
            } else {
                continue;
            }
        }
        CFStringRef escapedValue = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)value, NULL, CFSTR("%:/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
       //construct "key=value"
        NSMutableString *pair = [key mutableCopy];
        [pair appendString:@"="];
        [pair appendString:(__bridge NSString *)escapedValue];
        [pairs addObject:pair];
    }
    NSString *URLString = [API_BASE_URL stringByAppendingPathComponent:_path];
    NSMutableString *mURLString = [URLString mutableCopy];
    [mURLString appendString:@"/?"];
    [mURLString appendString:[pairs componentsJoinedByString:@"&"]];
    NSURL *URL = [NSURL URLWithString:mURLString];
    return [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIMEOUT_INTERVAL];
}
@end