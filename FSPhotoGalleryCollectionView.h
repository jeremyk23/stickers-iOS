//
//  FSPhotoGalleryCollectionView.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/31/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//
@protocol FSPhotoGalleryCollectionViewDelegate;

#import <UIKit/UIKit.h>
@class FSBasicImageSource;
@class PFObject;

@interface FSPhotoGalleryCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) FSBasicImageSource *fsImageSource;
@property (weak) id <FSPhotoGalleryCollectionViewDelegate> photoGalleryDelegate;

- (void)setPicturesWithArray:(NSArray *)pictures andObjectId:(NSString *)objectId;
- (void)setPicturesAndCellTypeWithRestaurant:(PFObject *)restaurant;
- (void)setCellIdentifier:(NSString *)cellIdentifier withNibNamed:(NSString *)nibName;

@end

@protocol FSPhotoGalleryCollectionViewDelegate <NSObject>

- (void)didSelectRestaurantAndShouldPushPhotoViewerView:(UIViewController *)viewController;
- (void)didSelectRestaurantAndShouldPushRestaurantWithObjectId:(NSString *)objectId;

@end