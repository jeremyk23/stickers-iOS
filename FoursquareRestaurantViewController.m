//
//  FoursquareRestaurantViewController.m
//  Best Bites
//
//  Created by Jeremy Klein Sr on 7/19/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FoursquareRestaurantViewController.h"
#import "MenuViewController.h"
#import "BBLabel.h"
#import <Parse/Parse.h>
#import "MenuItemTableViewCell.h"

@interface FoursquareRestaurantViewController ()
@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic, strong) NSDictionary *restaurantDict;
@property (nonatomic, strong) NSArray *tips;
@property (nonatomic, strong) NSArray *photos;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation FoursquareRestaurantViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andFsID:(NSString *)foursquareId {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.foursquareId = foursquareId;
        self.restaurantDict = [[NSDictionary alloc] init];
        self.offscreenCells = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.request requestRestaurantInfoWithId:self.foursquareId];
    [self.request requestPhoto:self.foursquareId];
}

- (void)configureViewWithResponse:(NSDictionary *)response {
    self.restaurantDict = response[@"venue"];
    self.tips = [[NSArray alloc] initWithArray:[EFoursquareParser returnProfessionalTips:response[@"venue"]]];
    self.restaurantNameLabel.text = self.restaurantDict[@"name"];
    if ([self.restaurantDict objectForKey:@"location"] != nil) {
        self.addressLabel.text = [[self.restaurantDict objectForKey:@"location"] objectForKey:@"address"];
    } else {
        self.addressLabel.text = @"";
    }
    [self.tableView reloadData];
}

- (void)setPhotoHeaderWithResponse:(NSDictionary *)response {
    if (response[@"photos"][@"count"] != 0) {
        NSURL *url = [EFoursquareParser getPhotoClosestTo:640 byHeight:360 withResponse:response];
        self.photos = [[NSArray alloc] initWithObjects:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]], nil];
    } else {
        //use placeholder image
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Tips";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //empty for now
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfTips = self.tips.count;
    if (numberOfTips != 0) {
        return numberOfTips;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tipCellIdentifier = @"tipCell";
    MenuItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    if (cell == nil) {
        cell = [[MenuItemTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipCellIdentifier];
    }
    [cell updateFonts];
    cell.titleLabel.text = self.tips[indexPath.row][@"name"];
    cell.bodyLabel.text = self.tips[indexPath.row][@"tip"];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *reuseIdentifier = @"tipCell";
    MenuItemTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[MenuItemTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    cell.titleLabel.text = self.tips[indexPath.row][@"name"];
    cell.bodyLabel.text = self.tips[indexPath.row][@"tip"];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    
    return height;
}

- (void)didFinishLoadingFoursquare:(NSDictionary *)response {
    if (response[@"photos"]) {
        [self setPhotoHeaderWithResponse:response];
    } else {
        [self configureViewWithResponse:response];
    }
}

- (void)didFailWithError:(NSError *)error {
    NSLog(@"Failed getting foursquare data with error: %@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
