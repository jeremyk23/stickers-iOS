//
//  ELocuParser.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Menu;
@interface ELocuParser : NSObject

- (Menu *)getFormattedEMenuObject:(NSDictionary *)response;

@end
