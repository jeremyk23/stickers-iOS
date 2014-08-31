
//
//  EMenu_Dish.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import "Menu_MenuType.h"

@interface Menu_Dish : Menu_MenuType

@property (nonatomic, strong) NSString *dishName;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *rating;

- (id)initWithDishName:(NSString *)name;

@end
