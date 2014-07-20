//
//  RestaurantModel.h
//  Entree
//
//  Created by Jeremy Klein Sr on 6/28/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"


@interface RestaurantModel : NSObject

- (id)initWith:(NSString *)restaraurantName
    andCuisine:(NSString *)cusine
    andAddress:(NSString *)address;

/*At a glance info*/
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSString *restaurantCuisine;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) BOOL openNow;
@property (nonatomic) NSInteger numberOfReviews;
@property (nonatomic) double FSScore;

/*detail info to be filled out once restaurant is selected */
@property (nonatomic, strong) Menu *menu;
@property (nonatomic, strong) NSDictionary *hours;


- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath;

@end
