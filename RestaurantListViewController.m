//
//  RestaurantListViewController.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/30/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "RestaurantListViewController.h"
#import "SingleRestaurantTableViewCell.h"
#import "RestaurantCategoryCollectionViewCell.h"
#import "RestaurantViewController.h"
#import "FrontPageCategoryData.h"
#import "CategoriesData.h"
#import "Constants.h"

@interface RestaurantListViewController ()
@property (nonatomic, strong) CategoriesData *categoryData;
@property (nonatomic, strong) NSArray *restaurants;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) FSPhotoGalleryCollectionView *photoGalleryView;
@end

@implementation RestaurantListViewController

- (id)initWithCategoryData:(CategoriesData *)categoryData {
    self = [super init];
    if (self) {
        self.navigationController.title = categoryData.categoryTitle;
        self.categoryData = categoryData;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.restaurants) {
//        PFQuery *restaurantQuery = [PFQuery queryWithClassName:@"Restaurant"];
//        [restaurantQuery whereKey:@"restaurants" containedIn:self.categoryData.restaurants];
//        [restaurantQuery includeKey:@"pictures"];
//        [restaurantQuery findObjectsInBackgroundWithBlock:^(NSArray *parseRestaurants, NSError *error) {
//            if (!error) {
//                self.restaurants = parseRestaurants;
//                [self.tableView reloadData];
//            } else {
//                NSLog(@"Error retrieving restaurants in category: %@", error);
//            }
//        }];

        
        PFQuery *categoryQuery = [PFQuery queryWithClassName:@"Category"];
        [categoryQuery includeKey:@"restaurants"];
        [categoryQuery includeKey:@"pictures"];
        [categoryQuery getObjectInBackgroundWithId:self.categoryData.parseCategoryObjectId block:^(PFObject *category, NSError *error) {
            if (!error) {
                self.restaurants = category[@"restaurants"];
                [self.tableView reloadData];
            } else {
                NSLog(@"Error retrieving category object: %@",error);
            }
        }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SingleRestaurantTableViewCell *cell = (SingleRestaurantTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSingleRestaurantTVCellIdentifier];
    
    if (!cell) {
        cell = [[SingleRestaurantTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSingleRestaurantTVCellIdentifier];
        FSPhotoGalleryCollectionView *fsCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
        fsCollectionView.photoGalleryDelegate = self;
        [fsCollectionView setPicturesAndCellTypeWithRestaurant:self.restaurants[indexPath.row]];
    }
    cell.restaurantNameLabel.text = self.restaurants[indexPath.row][@"restaurantName"];
    cell.categoryLabel.text = self.restaurants[indexPath.row][@"address"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SingleRestaurantTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FSPhotoGalleryCollectionView *photoGalleryCollectionView = (FSPhotoGalleryCollectionView *)cell.collectionView;
    [cell setCollectionViewDataSourceDelegate:photoGalleryCollectionView index:indexPath.row];
    NSInteger index = cell.collectionView.tag;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantViewController *restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andPFObject:self.restaurants[indexPath.row]];
    [self.navigationController pushViewController:restaurantVC animated:YES];
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 245.0f;
}


@end
