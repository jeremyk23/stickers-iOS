//
//  EFeaturedViewController.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/18/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "FrontPageRestaurantsQTVC.h"
#import "Constants.h"
#import "Singleton.h"
#import "ParseRestaurant.h"
#import "RestaurantTableViewCell.h"
#import "RestaurantViewController.h"

@interface FrontPageRestaurantsQTVC ()
@end

@implementation FrontPageRestaurantsQTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.parseClassName = @"Restaurant";
        self.paginationEnabled = YES;
        self.pullToRefreshEnabled = YES;
        self.objectsPerPage = 10;
        self.tableView.rowHeight = [RestaurantTableViewCell rowHeight];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshParseData) name:_NOTIFICATION_LOCATION_UPDATE object:[Singleton sharedStore]];
    NSLog(@"currentLocation: %@", [[Singleton sharedStore] currentLocation]);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/*Query for all dishes that have a featured parent objectId equal to the current city */
-(PFQuery *)queryForTable {
    if ([[Singleton sharedStore] currentCity] == nil) {
        PFQuery *dummyQuery = [PFQuery queryWithClassName:@"Restaurant"];
        [dummyQuery setLimit:0];
        return dummyQuery;
    } else {
        PFQuery *featuredCity = [PFQuery queryWithClassName:@"Restaurant"];
        if (self.objects.count == 0) {
            featuredCity.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        [featuredCity whereKey:kFeaturedDishesCityKey equalTo:@"Portland"];
        [featuredCity whereKey:kFeaturedDishesStateKey equalTo:@"OR"];
        return featuredCity;
    }
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [self.tableView reloadData];
}

- (void)refreshParseData {
    [self queryForTable];
    //    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"CellIdentifier";
    RestaurantTableViewCell *cell = (RestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.restaurantNameLabel.text = object[@"restaurantName"];
    cell.restaurantCuisine.text = object[@"cuisine"];
    cell.addressLabel.text = object[@"address"];
    [cell setDollarSign:object[@"price"]];
    cell.avgScoreLabel.text = [[NSString alloc] initWithFormat:@"%lu Reviews", (unsigned long)[object[@"reviews"] count]];
    //    cell.imageView.image = [UIImage imageNamed:@"Crunch_CU.jpg"];
    
    if (object) {
        cell.imageView.file = [object objectForKey:@"restaurantPhoto"];
        
        // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
        if ([cell.imageView.file isDataAvailable]) {
            [cell.imageView loadInBackground];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantViewController *restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andPFObject:self.objects[indexPath.row]];
    
    //    NSDictionary *tempRDict = [[NSDictionary alloc] initWithObjectsAndKeys:foursquareId, @"foursquareId", nil];
    [self.navigationController pushViewController:restaurantVC animated:YES];
}

//- (ParseRestaurant *)createRestaurantModel:(PFObject *)pfRestaurant {
//    ParseRestaurant *restaurant = [[ParseRestaurant alloc] initWith:pfRestaurant[@"restaurantName"] andCuisine:pfRestaurant[@"cuisine"] andAddress:pfRestaurant[@"restaurant"]];
//    restaurant.numberOfReviews = 5;
//    restaurant.imageFile = pfRestaurant[@"restaurantPhoto"];
//    restaurant.
//
//
//
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
