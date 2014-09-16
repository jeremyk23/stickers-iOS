//
//  SingleRestaurantTableViewCell.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/29/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "SingleRestaurantTableViewCell.h"
#import "FSPhotoGalleryCollectionView.h"
#import "Constants.h"

@implementation SingleRestaurantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithOutCollectionViewAndWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    //    layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
    layout.itemSize = CGSizeMake(320.0f, 245.0f);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    FSPhotoGalleryCollectionView *fsGallery = [[FSPhotoGalleryCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    fsGallery.delegate = fsGallery;
    fsGallery.dataSource = fsGallery;
    self.collectionView = fsGallery;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView setPagingEnabled:YES];
    self.categoryLabel.alpha = 1.0f;
    self.transparencyView.alpha = 1.0f;
    [self.contentView addSubview:self.collectionView];
    [self displayCategoryLabel];
    CGFloat topOfCategoryLabel = CGRectGetMinY(self.categoryLabel.frame);
    self.restaurantNameLabel = [[UILabel alloc] init];
    self.restaurantNameLabel.frame = CGRectMake(0.0f, topOfCategoryLabel - 25.0f, 320.0f, 30.0f);
    self.restaurantNameLabel.textColor = [UIColor whiteColor];
    self.restaurantNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.restaurantNameLabel];
    return self;
}

@end
