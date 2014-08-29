//
//  AFViewController.m
//  AFTabledCollectionView
//
//  Created by Ash Furrow on 2013-03-14.
//  Copyright (c) 2013 Ash Furrow. All rights reserved.
//

#import "AFViewController.h"
#import "RestaurantViewController.h"
#import "AFTableViewCell.h"
#import "Constants.h"
#import "RestaurantCategory.h"
#import "RestaurantCollectionViewCell.h"
#import "CategoriesData.h"
#import "FrontPageDataSource.h"
#import "BBLabel.h"
#import "Helpers.h"

#import <Parse/Parse.h>

@interface AFViewController ()

@property (nonatomic, strong) FrontPageDataSource *fpDataSource;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation AFViewController

-(void)loadView
{
    [super loadView];
    /*
    PFQuery *categoryQuery = [PFQuery queryWithClassName:@"Restaurant"];
    categoryQuery.limit = 50;
    NSArray *objects = [categoryQuery findObjects];
    NSMutableDictionary *categories = [[NSMutableDictionary alloc] initWithCapacity:10];
    for (PFObject *restaurant in objects) {
        NSString *cuisineCategory = restaurant[@"cuisine"];
        if (categories[cuisineCategory]) {
            [categories[cuisineCategory] addObject:restaurant];
        } else {
            NSMutableArray *listOfRestaurants = [[NSMutableArray alloc] initWithCapacity:10];
            [listOfRestaurants addObject:restaurant];
            categories[cuisineCategory] = listOfRestaurants;
        }
    }
    NSMutableArray *tempCategoriesArray = [[NSMutableArray alloc] initWithCapacity:categories.count];
    for (id key in categories) {
        RestaurantCategory *rc = [[RestaurantCategory alloc] init];
        rc.categoryName = key;
        rc.restaurants = categories[key];
        [tempCategoriesArray addObject:rc];
    }
     */
    
    
    self.fpDataSource = [[FrontPageDataSource alloc] initAndConstructQuery];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    AFTableViewCell *cell = (AFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[AFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    RestaurantCategory *rc = self.categoriesArray[indexPath.row];
    cell.categoryLabel.text = rc.categoryName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 245.0f;
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RestaurantCategory *rc = self.categoriesArray[collectionView.tag];
    return rc.restaurants.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    RestaurantCategory *rc = self.categoriesArray[collectionView.tag];
    cell.restaurantPhoto.image = [UIImage imageNamed:@"placeholder-photo.png"];
    cell.restaurantNameLabel.text = rc.restaurants[indexPath.item][@"restaurantName"];
        [self.view bringSubviewToFront:cell.restaurantNameLabel];
        PFFile *photoFile = rc.restaurants[indexPath.item][@"restaurantPhoto"];
        if (photoFile) {
            cell.restaurantPhoto.file = photoFile;
            [cell.restaurantPhoto loadInBackground:^(UIImage *image, NSError *error) {
                cell.restaurantPhoto.image = [Helpers imageByScalingAndCroppingForSize:cell.restaurantPhoto.frame.size withImage:image];
            }];
        }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantCategory *rc = self.categoriesArray[collectionView.tag];
    PFObject *restaurant = rc.restaurants[indexPath.item];
    RestaurantViewController *restaurantVC = [[RestaurantViewController alloc] initWithNibName:@"RestaurantViewController" bundle:nil andPFObject:restaurant];
    [self.navigationController pushViewController:restaurantVC animated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

@end
