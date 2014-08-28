//
//  StickersCollectionView.m
//  Best Bites
//
//  Created by Jeremy Klein on 8/26/14.
//  Copyright (c) 2014 Best Bites. All rights reserved.
//

#import "StickersCollectionView.h"
#import "MosaicLayout.h"
#import "MosaicCell.h"
#import "Helpers.h"
#import <Parse/Parse.h>

#define kCellIdentifier @"PUBLICATION_ICON_CELL"
#define kDoubleColumnProbability 20
#define kDoubleColumnProbabilityTopPublication 25


@implementation StickersCollectionView

- (id)init {
    MosaicLayout *layout = [[MosaicLayout alloc] init];
    layout.delegate = self;
    self = [super initWithFrame:self.frame collectionViewLayout:layout];
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[MosaicCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
        self.publicationLogos = [[NSMutableArray alloc] initWithCapacity:10];
    }
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        //do nothing
    }
    return self;
}

- (void)awakeFromNib {
    // do nothing
}

- (void)displayReviewIconsForRestaurant:(PFObject *)restaurant {
    NSSet *topPublications = [Helpers topPublications];
    PFQuery *reviewsQuery = [PFQuery queryWithClassName:@"Review"];
    [reviewsQuery whereKey:@"restaurant" equalTo:restaurant];
    [reviewsQuery includeKey:@"publication"];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        if (!error) {
            for (PFObject *review in reviews) {
                PFObject *publication = review[@"publication"];
                PFFile *publicationIcon = publication[@"icon"];
                if (publicationIcon) {
                    MosaicData *mData = [[MosaicData alloc] initWithPFFile:publicationIcon publicationName:publication[@"name"] andDatePublished:review[@"datePublished"]];
                    if ([topPublications containsObject:publication[@"name"]]) {
                        mData.isTopPublication = TRUE;
                    }
                    NSString *review_url = review[@"url"];
                    if (review_url) {
                        mData.reviewURL = review_url;
                    }
                    [self.publicationLogos addObject:mData];
                }
            }
            [self reloadData];
        } else {
            NSLog(@"Unable to retrieve reviews for sticker display due to error: %@", error);
        }
    }];
    
    PFQuery *awardsQuery = [PFQuery queryWithClassName:@"Awards"];
    [awardsQuery whereKey:@"restaurant" equalTo:restaurant];
    [awardsQuery includeKey:@"publication"];
    [awardsQuery findObjectsInBackgroundWithBlock:^(NSArray *awards, NSError *error) {
        if (!error) {
            for (PFObject *award in awards) {
                PFFile *icon = award[@"icon"];
                if (!icon) {
                    icon = award[@"publication"][@"icon"];
                }
                if (icon) {
                    MosaicData *mData = [[MosaicData alloc] initWithPFFile:icon publicationName:award[@"name"] andDatePublished:award[@"datePublished"]];
                    if ([topPublications containsObject:award[@"publication"][@"name"]]) {
                        mData.isTopPublication = TRUE;
                    }
                    NSString *review_url = award[@"url"];
                    if (review_url) {
                        mData.reviewURL = review_url;
                    }
                    [self.publicationLogos addObject:mData];
                }
            }
            [self reloadData];
        } else {
            NSLog(@"Unable to retrieve awards for sticker display due to error: %@", error);
        }
    }];
}

- (void)displayReviewIconsWithReviews:(NSArray *)reviews andAwards:(NSArray *)awards {
    NSSet *topPublications = [Helpers topPublications];
    for (PFObject *review in reviews) {
        PFObject *publication = review[@"publication"];
        PFFile *publicationIcon = publication[@"icon"];
        if (publicationIcon) {
            MosaicData *mData = [[MosaicData alloc] initWithPFFile:publicationIcon publicationName:publication[@"name"] andDatePublished:review[@"datePublished"]];
            if ([topPublications containsObject:publication[@"name"]]) {
                mData.isTopPublication = TRUE;
            }
            NSString *review_url = review[@"url"];
            if (review_url) {
                mData.reviewURL = review_url;
            }
            [self.publicationLogos addObject:mData];
        }
    }
    
    for (PFObject *award in awards) {
        PFFile *icon = award[@"icon"];
        if (!icon) {
            icon = award[@"publication"][@"icon"];
        }
        if (icon) {
            MosaicData *mData = [[MosaicData alloc] initWithPFFile:icon publicationName:award[@"name"] andDatePublished:award[@"datePublished"]];
            if ([topPublications containsObject:award[@"publication"][@"name"]]) {
                mData.isTopPublication = TRUE;
            }
            NSString *review_url = award[@"url"];
            if (review_url) {
                mData.reviewURL = review_url;
            }
            [self.publicationLogos addObject:mData];
        }
    }
    if (self.stickersDelegate && [self.stickersDelegate respondsToSelector:@selector(numberOfPublicationsAndAwardsWithIcons:)]) {
        [self.stickersDelegate numberOfPublicationsAndAwardsWithIcons:self.publicationLogos.count];
    }
    [self reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.publicationLogos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MosaicCell *cell =
    (MosaicCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                            forIndexPath:indexPath];
    
    MosaicData *data = [self.publicationLogos objectAtIndex:indexPath.row];
    cell.mosaicData = data;
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    cell.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.stickersDelegate && [self.stickersDelegate respondsToSelector:@selector(didSelectLogoWithURL:)]) {
        MosaicData *data = [self.publicationLogos objectAtIndex:indexPath.row];
        NSURL *url = [[NSURL alloc] initWithString:data.reviewURL];
        if (url && url.scheme && url.host) {
            [self.stickersDelegate didSelectLogoWithURL:url];
        }
    }
}

#pragma mark - Mosaic Layout Delagate
-(float)collectionView:(UICollectionView *)collectionView relativeHeightForItemAtIndexPath:(NSIndexPath *)indexPath {
    //  Base relative height for simple layout type. This is 1.0 (height equals to width)
    float retVal = 1.0;
    
    MosaicData *aMosaicModule = [self.publicationLogos objectAtIndex:indexPath.row];
    
    if (aMosaicModule.relativeHeight != 0){
        
        //  If the relative height was set before, return it
        retVal = aMosaicModule.relativeHeight;
        
    }else{
        
        BOOL isDoubleColumn = [self collectionView:collectionView isDoubleColumnAtIndexPath:indexPath];
        if (isDoubleColumn){
            //  Base relative height for double layout type. This is 0.75 (height equals to 75% width)
            retVal = 0.75;
        }
        
        /*  Relative height random modifier. The max height of relative height is 25% more than
         *  the base relative height */
        
        float extraRandomHeight = arc4random() % 25;
        retVal = retVal + (extraRandomHeight / 100);
        
        /*  Persist the relative height on MosaicData so the value will be the same every time
         *  the mosaic layout invalidates */
        
        aMosaicModule.relativeHeight = retVal;
    }
    
    return retVal;
    
}
-(BOOL)collectionView:(UICollectionView *)collectionView isDoubleColumnAtIndexPath:(NSIndexPath *)indexPath {
    MosaicData *aMosaicModule = [self.publicationLogos objectAtIndex:indexPath.row];
    
    if (aMosaicModule.layoutType == kMosaicLayoutTypeUndefined){
        
        /*  First layout. We have to decide if the MosaicData should be
         *  double column (if possible) or not. */
        
        NSUInteger random = arc4random() % 100;
        NSUInteger probability = aMosaicModule.isTopPublication ? kDoubleColumnProbabilityTopPublication : kDoubleColumnProbability;
        
        if (random < probability) {
            aMosaicModule.layoutType = kMosaicLayoutTypeDouble;
        }else{
            aMosaicModule.layoutType = kMosaicLayoutTypeSingle;
        }
    }
    BOOL retVal = aMosaicModule.layoutType == kMosaicLayoutTypeDouble;
    return retVal;
}




-(NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    return 8;
}

@end
