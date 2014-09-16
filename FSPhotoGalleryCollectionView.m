//
//  FSPhotoGalleryCollectionView.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/31/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "FSPhotoGalleryCollectionView.h"
#import "RestaurantPhotoGalleryCell.h"
#import <FSBasicImageSource.h>
#import <FSBasicImage.h>
#import <Parse/Parse.h>
#import "Helpers.h"
#import "Constants.h"

@implementation FSPhotoGalleryCollectionView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self setCellIdentifier:kPhotoGalleryCollectionViewCellIdentifier withNibNamed:@"RestaurantPhotoGalleryCell"];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setPicturesAndCellTypeWithRestaurant:(PFObject *)restaurant {
    
    self.fsImageSource = [[FSBasicImageSource alloc] initWithImages:[Helpers createPhotosArray:restaurant]];
    [self reloadData];
}

- (void)setPicturesWithArray:(NSArray *)pictures {
    self.fsImageSource = [[FSBasicImageSource alloc] initWithImages:pictures];
    if (!self.fsImageSource) {
        NSArray *placeholderImage = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"placeholder-photo.png"], nil];
        self.fsImageSource = [[FSBasicImageSource alloc] initWithImages:placeholderImage];
    }
    [self reloadData];
}

- (void)setCellIdentifier:(NSString *)cellIdentifier withNibNamed:(NSString *)nibName {
    [self registerNib:[UINib nibWithNibName:nibName bundle:nil]  forCellWithReuseIdentifier:cellIdentifier];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger numberOfImages = self.fsImageSource.numberOfImages;
    if (numberOfImages) {
        return numberOfImages;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RestaurantPhotoGalleryCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kPhotoGalleryCollectionViewCellIdentifier forIndexPath:indexPath];
    NSURL *pictureURL = [self.fsImageSource objectAtIndexedSubscript:indexPath.row].URL;
    if (!pictureURL) {
        cell.imageView.image = [self.fsImageSource objectAtIndexedSubscript:indexPath.row].image;
    } else {
        [cell.imageView sd_setImageWithURL:pictureURL
                          placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"]];
        [cell.imageView sd_setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                cell.imageView.image = [Helpers imageByScalingAndCroppingForSize:cell.imageView.frame.size withImage:image];
            } else {
                NSLog(@"error getting images in photo gallery: %@", error);
            }
            
        }];
        
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fsImageSource.numberOfImages > 1) {
        if (self.photoGalleryDelegate && [self.photoGalleryDelegate respondsToSelector:@selector(didSelectRestaurantAndShouldPushViewController:)]) {
            FSImageViewerViewController *photoViewer = [[FSImageViewerViewController alloc] initWithImageSource:self.fsImageSource imageIndex:indexPath.row];
            [self.photoGalleryDelegate didSelectRestaurantAndShouldPushViewController:photoViewer];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 44;
//}


@end
