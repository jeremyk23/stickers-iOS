//
//  ParseRestaurant.h
//  Entree
//
//  Created by Jeremy Klein Sr on 6/30/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "RestaurantModel.h"
@class PFFile;

@interface ParseRestaurant : RestaurantModel

@property (nonatomic) double BBScore;
@property (nonatomic, strong) PFFile *imageFile;

- (UITableViewCell *)tableView: (UITableView *)tableView representationAsCellForRowAtIndexPath: (NSIndexPath *)indexPath;

@end
