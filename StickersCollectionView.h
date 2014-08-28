//
//  StickersCollectionView.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/26/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//
@protocol StickersCollectionViewDelegate;

#import <UIKit/UIKit.h>
#import "MosaicLayoutDelegate.h"
@class PFObject;



@interface StickersCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegate, MosaicLayoutDelegate>

@property (weak) id <StickersCollectionViewDelegate> stickersDelegate;
@property (nonatomic, strong) NSMutableArray *publicationLogos;

- (void)displayReviewIconsForRestaurant:(PFObject *)restaurant;
- (void)displayReviewIconsWithReviews:(NSArray *)reviews andAwards:(NSArray *)awards;

@end


@protocol StickersCollectionViewDelegate <NSObject>

- (void)didSelectLogoWithURL:(NSURL *)url;
- (void)numberOfPublicationsAndAwardsWithIcons:(NSUInteger)numberOfIcons;

@end


