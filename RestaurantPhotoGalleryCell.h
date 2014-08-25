//
//  RestaurantPhotoGalleryCell.h
//  Best Bites
//
//  Created by Jeremy Klein on 8/24/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RestaurantPhotoGalleryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
