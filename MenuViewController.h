//
//  MenuViewController.h
//  Entree
//
//  Created by Jeremy Klein Sr on 7/6/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BBLabel;
@class Menu;

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControlMenu;
@property (weak, nonatomic) IBOutlet BBLabel *restaurantNameLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)storeFoursquareId:(NSString *)foursquareId parseId:(NSString *)parseId restaurantName:(NSString *)restaurantName andLocuId:(NSString *)locuId;

@end
