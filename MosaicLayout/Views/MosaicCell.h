//
//  MosaicDataView.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/16/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MosaicData.h"
@class PFImageView;

@interface MosaicCell : UICollectionViewCell{
    PFImageView *_imageView;
    MosaicData *_mosaicData;
    UILabel *_titleLabel;
}

@property (strong) UIImage *image;
@property (strong) MosaicData *mosaicData;

@end
