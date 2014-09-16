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
#import "RestaurantCategoryCollectionViewCell.h"
#import "SingleRestaurantTableViewCell.h"
#import "CategoriesData.h"
#import "FPCategoryGroup.h"
#import "BBLabel.h"
#import "Helpers.h"
#import <MBProgressHUD.h>
#import "RestaurantCategoryCellData.h"

#import <Parse/Parse.h>

@interface AFViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) FrontPageDataSource *fpDataSource;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation AFViewController

-(void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.tableView.rowHeight = 245.0f;
//    [self.tableView registerClass:[SingleRestaurantTableViewCell class] forCellReuseIdentifier:kSingleRestaurantTVCellIdentifier];
    self.HUD.delegate = self;
    self.fpDataSource = [[FrontPageDataSource alloc] initAndConstructQuery];
    self.fpDataSource.fpDatasourceDelegate = self;
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shouldReloadTable {
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

#pragma mark - UITableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fpDataSource.elements.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.fpDataSource tableView:tableView configureCellForIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(AFTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *categoryGroup = self.fpDataSource.elements[indexPath.row];
    [mutableArrayLock unlock];
    if (categoryGroup.groupType == kSingleRestaurantGroup) {
        cell.collectionView.tag = indexPath.row;
    } else {
        [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
    
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
    NSLock *mutableArrayLock = [[NSLock alloc] init];
    [mutableArrayLock lock];
    FPCategoryGroup *fpCategoryGroup = self.fpDataSource.elements[collectionView.tag];
    [mutableArrayLock unlock];
    if (fpCategoryGroup.groupType == kCategoriesOnlyGroup) {
        return fpCategoryGroup.items.count;
    } else {
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.fpDataSource collectionView:collectionView configureItemAtIndexPath:indexPath];
    if (!cell) {
        NSLog(@"!!!!!!XXXXXXXX YOUR NOT RETURNING A CELL! XXXXXXXX!!!!!!");
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.fpDataSource collectionView:collectionView configureDidSelectItemAtIndexPath:indexPath];
}

// FPDatasourceDelegate METHOD
- (void)didSelectItemAndShouldPushViewController:(UIViewController *)viewController {
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
