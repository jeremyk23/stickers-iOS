//
//  RestaurantViewController.m
//  Entree
//
//  Created by Jeremy Klein Sr on 7/4/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "RestaurantViewController.h"
#import "BBLabel.h"
#import <Parse/Parse.h>
#import "ERequestInterface.h"
#import "EFoursquareParser.h"
#import "Menu.h"
#import "MenuViewController.h"
#import "RestaurantPhotoGalleryCell.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MapKit/MapKit.h>
#import "Helpers.h"

#define NUMBER_OF_ASYNCH_CALLS 2
#define METERS_PER_MILE 1609.344


@interface RestaurantViewController ()
@property (nonatomic, strong) NSArray *restaurantInfo;
@property (nonatomic, strong) NSArray *topDishes;
@property (nonatomic, strong) NSArray *awards;
@property (nonatomic, strong) NSMutableArray *displayedReviews;
@property (nonatomic, strong) NSArray *allReviews;
@property (nonatomic, strong) FSBasicImageSource *fsImageSource;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSMutableArray *imageCache;

@property (nonatomic) int numberOfSections;
@property (nonatomic) int infoSection;
@property (nonatomic) int menuSection;
@property (nonatomic) int awardsSection;
@property (nonatomic) int reviewsSection;

@property (nonatomic) int waitForTableReload;

@end

@implementation RestaurantViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPFObject:(PFObject *)restaurant {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.restaurant = restaurant;
        self.displayedReviews = [[NSMutableArray alloc] initWithCapacity:5];
        self.request = [[ERequestInterface alloc] init];
        self.request.eDelegate = self;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.request = [[ERequestInterface alloc] init];
        self.request.eDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //in the case that a subclass with no restaurant calls this method, check to make sure restaurant exists
    if (self.restaurant) {
        [self.request requestRestaurantInfoWithId:self.restaurant[@"foursquareId"]];
        self.infoSection = 0;
        self.menuSection = 1;
        self.awardsSection = -1;
        self.reviewsSection = -1;
        
        self.waitForTableReload = 0;
        
        CALayer * logoLayer = [self.restaurantLogo layer];
        [logoLayer setMasksToBounds:YES];
        [logoLayer setCornerRadius:10.0];
        self.restaurantLogo.file = self.restaurant[@"restaurantLogo"];
        [self.restaurantLogo loadInBackground];
        
        [self.photoGallery registerNib:[UINib nibWithNibName:@"RestaurantPhotoGalleryCell" bundle:nil]  forCellWithReuseIdentifier:@"RestaurantPhotoCell"];
        self.fsImageSource = [[FSBasicImageSource alloc] initWithImages:[self createPhotosArray]];
        [self.photoGallery reloadData];
        
        self.stickersGridView.stickersDelegate = self;
        
        self.title = self.restaurant[@"restaurantName"];
        self.restaurantNameLabel.text = self.restaurant[@"restaurantName"];
        self.addressLabel.text = self.restaurant[@"address"];
//        [self.view bringSubviewToFront:self.restaurantNameLabel];
        [self detailedRestaurantQuery];
    }
}

- (void)zoomInMapWithLatitude:(float)latitude andLongitude:(float)longitude {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = latitude;
    zoomLocation.longitude= longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:zoomLocation];
    [annotation setTitle:self.restaurantNameLabel.text]; //You can set the subtitle too
    [self.mapView addAnnotation:annotation];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.infoBackdropView.backgroundColor = [UIColor colorWithRed:12.0f/255.0f green:146.0f/255.0f blue:148.0f/255.0f alpha:0.75f];
    self.restaurantNameLabel.font = [UIFont fontWithName:@"GillSans" size:20.0f];
    self.addressLabel.font = [UIFont fontWithName:@"GillSans" size:10.0f];

}

- (void)resizeStickerGridWithNumberOfIcons:(NSUInteger)numberOfIcons {
    if (numberOfIcons == 0) {
        self.stickerGridViewHeight.constant = 0.0f;
        [self.view updateConstraints];
    }
    if (numberOfIcons < 6) {
        self.stickerGridViewHeight.constant = 80.0f;
        [self.view updateConstraints];
    }
    
}

- (NSArray *)createPhotosArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[self.restaurant[@"pictures"] count] + 1];
    PFFile *photoFile = self.restaurant[@"restaurantPhoto"];
    if (photoFile.url) {
        NSURL *mainRestaurantPhotoURL = [[NSURL alloc] initWithString:photoFile.url];
        [tempArray addObject:[[FSBasicImage alloc] initWithImageURL:mainRestaurantPhotoURL]];
    }
    for (NSString *photoURLString in self.restaurant[@"pictures"]) {
        if (photoURLString) {
            NSURL *photoURL = [[NSURL alloc] initWithString:photoURLString];
            if (photoURL && photoURL.scheme && photoURL.host) {
                [tempArray addObject:[[FSBasicImage alloc] initWithImageURL:photoURL]];
            }
        }
    }
    if (tempArray.count == 0) {
        [tempArray addObject:[[FSBasicImage alloc] initWithImage:[UIImage imageNamed:@"placeholder-photo.png"]]];
    }
    return (NSArray *)tempArray;
}

- (NSArray *)createReviewsArray:(NSMutableArray *)reviews {
    NSSet *topPublications = [Helpers topPublications];
    //shuffle review order
//    NSUInteger count = [reviews count];
//    for (NSUInteger i = 0; i < count; ++i) {
//        NSUInteger remainingCount = count - i;
//        NSUInteger exchangeIndex = i + arc4random_uniform(remainingCount);
//        [reviews exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
//    }
    
    //place national publications at front
    NSMutableArray *orderedReviewArray = [[NSMutableArray alloc] initWithCapacity:reviews.count];
    for (PFObject *review in reviews) {
        if (![review isEqual:[NSNull null]]) {
            if ([topPublications containsObject:review[@"publicationName"]]) {
                [orderedReviewArray insertObject:review atIndex:0];
            } else {
                [orderedReviewArray addObject:review];
            }
        }
    }
    return (NSArray *)orderedReviewArray;
}

- (void)addMoreReviewsToArray {
    NSUInteger reviewsLeft = self.allReviews.count - self.displayedReviews.count;
    if (reviewsLeft >= 10) {
        NSIndexSet *next10 = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(self.displayedReviews.count, 10)];
        [self.displayedReviews addObjectsFromArray:[self.allReviews objectsAtIndexes:next10]];
    } else {
        NSIndexSet *restOfReviews = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, reviewsLeft)];
        [self.displayedReviews addObjectsFromArray:[self.allReviews objectsAtIndexes:restOfReviews]];
    }
    [self.tableView reloadData];
}

- (void)detailedRestaurantQuery {
    PFQuery *detailQuery = [PFQuery queryWithClassName:@"Restaurant"];
    [detailQuery includeKey:@"topDishes"];
    [detailQuery includeKey:@"awards"];
    [detailQuery includeKey:@"awards.publication"];
    [detailQuery includeKey:@"reviews.publication"];
    [detailQuery getObjectInBackgroundWithId:self.restaurant.objectId block:^(PFObject *detailedRestaurant, NSError *error) {
        self.restaurant = detailedRestaurant;
        if (!error) {
            int sectionCount = 2;
            if ([detailedRestaurant[@"topDishes"] count] != 0 ) {
                self.topDishes = [NSArray arrayWithArray:detailedRestaurant[@"topDishes"]];
            }
            
            if (detailedRestaurant[@"awards"]) {
                self.awards = [NSArray arrayWithArray:detailedRestaurant[@"awards"]];
                self.awardsSection = sectionCount;
                sectionCount += 1;
            }
            
            NSUInteger reviewsCount = [detailedRestaurant[@"reviews"] count];
            if (reviewsCount != 0) {
                if (reviewsCount > 5) {
                    self.allReviews = [self createReviewsArray:(NSMutableArray *)detailedRestaurant[@"reviews"]];
                    NSIndexSet *first5 = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 5)];
                    self.displayedReviews = [[NSMutableArray alloc] initWithArray:[self.allReviews objectsAtIndexes:first5]];
                } else {
                    self.allReviews = [self createReviewsArray:(NSMutableArray *)detailedRestaurant[@"reviews"]];
                    self.displayedReviews = (NSMutableArray *)self.allReviews;
                }
                self.reviewsSection = sectionCount;
                sectionCount += 1;
            }
            
            [self.stickersGridView displayReviewIconsWithReviews:detailedRestaurant[@"reviews"] andAwards:detailedRestaurant[@"awards"]];
            self.numberOfSections = sectionCount;
            [self updateWaitForReloadTable];
        } else {
            NSLog(@"error when loading reviews: %@", error);
        }
    }];
}

- (void)configureRestaurantInfo:(NSDictionary *)venue {
    NSString *telephoneNumber = venue[@"contact"][@"formattedPhone"];
    NSString *openOrClosedStatus = venue[@"hours"][@"status"];
    NSString *moreInfo = @"More Info";
    NSMutableArray *arrayToFilterOutNils = [[NSMutableArray alloc] initWithCapacity:3];
    if (telephoneNumber) {
        [arrayToFilterOutNils addObject:telephoneNumber];
    }
    if (openOrClosedStatus) {
        [arrayToFilterOutNils addObject:openOrClosedStatus];
    }
    [arrayToFilterOutNils addObject:moreInfo];
    self.restaurantInfo = [[NSArray alloc] initWithArray:(NSArray *)arrayToFilterOutNils];
    self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@", venue[@"location"][@"address"], telephoneNumber];
    [self updateWaitForReloadTable];
}

- (void)updateWaitForReloadTable {
    self.waitForTableReload += 1;
    if (self.waitForTableReload == NUMBER_OF_ASYNCH_CALLS) {
        [self.tableView reloadData];
        self.waitForTableReload = 0;
    }
}

#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == self.infoSection) {
        if (self.restaurantInfo) {
            return self.restaurantInfo.count;
        } else {
            return 1;
        }
    }

    //view menu
    if (section == self.menuSection) {
        if (self.topDishes.count != 0) {
            //+ 1 to account for view menu cell
            return self.topDishes.count + 1;
        } else {
            return 1;
        }
    }
    
    else if (section == self.awardsSection) {
        if ([self.awards count] != 0) {
            return [self.awards count];
        } else {
            return 0;
        }
    }
    
    else if (section == self.reviewsSection) {
        NSUInteger displayedReviewsCount = self.displayedReviews.count;
        if (self.displayedReviews != 0) {
            if (self.allReviews.count == displayedReviewsCount) {
                return displayedReviewsCount; //all reviews are displayed
            } else {
                return self.displayedReviews.count + 1; // +1 for view more cell
            }
            
        } else {
            return 0;
        }
    }
    else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.infoSection) {
        return @"Restaurant Info";
    }
    
    if (section == self.menuSection) {
        if (self.topDishes.count != 0) {
            return @"Top Dishes";
        } else {
            return @"Menu";
        }
    }
    else if (section == self.awardsSection) {
        return @"Awards";
    }
    else if (section == self.reviewsSection) {
        return @"Reviews";
    }
    else {
        return @"";
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *infoCell = @"infoCell";
    static NSString *topDishesCell = @"topDishesCell";
    static NSString *awardsCell = @"awardsCell";
    static NSString *reviewCell = @"reviewCell";
    UITableViewCell *cell;
    
    if (indexPath.section == self.infoSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:infoCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCell];
        }
        cell.textLabel.text = self.restaurantInfo[indexPath.row];
        if (indexPath.row == self.restaurantInfo.count-1) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    else if (indexPath.section == self.menuSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:topDishesCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topDishesCell];
        }
        if (indexPath.row == self.topDishes.count) {
            cell.textLabel.text = @"View Complete Menu";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = self.topDishes[indexPath.row][@"name"];
        }

    }
    
    else if (indexPath.section == self.awardsSection) {
        PFTableViewCell *pfCell = [tableView dequeueReusableCellWithIdentifier:awardsCell];
        if (!cell) {
            pfCell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:awardsCell];
        }
        pfCell.imageView.file = self.awards[indexPath.row][@"awardIcon"];
        pfCell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [pfCell.imageView loadInBackground];
        
        pfCell.textLabel.text = self.awards[indexPath.row][@"bestower"];
        pfCell.detailTextLabel.text = self.awards[indexPath.row][@"awardTitle"];
        return pfCell;
    }
    
    else if (indexPath.section == self.reviewsSection) {
        cell = [tableView dequeueReusableCellWithIdentifier:reviewCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reviewCell];
        }
        if (indexPath.row == self.displayedReviews.count) {
            cell.textLabel.text = @"View More Reviews...";
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            if (self.displayedReviews[indexPath.row] != [NSNull null]) {
                cell.textLabel.text = self.displayedReviews[indexPath.row][@"publicationName"];
                cell.detailTextLabel.text = self.displayedReviews[indexPath.row][@"headline"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.text = @"Sorry!";
                cell.detailTextLabel.text = @"There was an error retrieving this review.";
            }
        }
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:topDishesCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topDishesCell];
        }
        cell.textLabel.text = @"Something went wrong";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.menuSection) {
        if (indexPath.row == self.topDishes.count) {
            MenuViewController *menuVC = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
            [menuVC storeFoursquareId:self.restaurant[@"foursquareId"] parseId:self.restaurant.objectId restaurantName:self.restaurant[@"restaurantName"] andLocuId:self.restaurant[@"locuId"]];
            [self.navigationController pushViewController:menuVC animated:YES];
        }
    }
    
    else if (indexPath.section == self.reviewsSection) {
        if (indexPath.row == self.displayedReviews.count) {
            [self addMoreReviewsToArray];
        }
        else {
            [self pushWebViewWithURL:[NSURL URLWithString:self.displayedReviews[indexPath.row][@"url"]]];
        }
    }
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
    RestaurantPhotoGalleryCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"RestaurantPhotoCell" forIndexPath:indexPath];
    NSURL *pictureURL = [self.fsImageSource objectAtIndexedSubscript:indexPath.row].URL;
    if (!pictureURL) {
        cell.imageView.image = [self.fsImageSource objectAtIndexedSubscript:indexPath.row].image;
    } else {
        [cell.imageView sd_setImageWithURL:pictureURL
                          placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"]];
        [cell.imageView sd_setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            cell.imageView.image = [Helpers imageByScalingAndCroppingForSize:cell.imageView.frame.size withImage:image];
        }];

    }
        return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fsImageSource.numberOfImages > 1) {
        FSImageViewerViewController *photoViewer = [[FSImageViewerViewController alloc] initWithImageSource:self.fsImageSource imageIndex:indexPath.row];
        [self.navigationController pushViewController:photoViewer animated:YES];
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

#pragma mark - StickersCollectionView
- (void)didSelectLogoWithURL:(NSURL *)url {
    [self pushWebViewWithURL:url];
}

- (void)numberOfPublicationsAndAwardsWithIcons:(NSUInteger)numberOfIcons {
    [self resizeStickerGridWithNumberOfIcons:numberOfIcons];
}
#pragma mark - ERequestInterface
- (void)didFinishLoadingFoursquare:(NSDictionary *)response {
    NSDictionary *TEST = response[@"venue"][@"location"];
    NSDictionary *TEST2 = response[@"venue"][@"location"][@"lat"];
    [self zoomInMapWithLatitude:[response[@"venue"][@"location"][@"lat"] floatValue] andLongitude:[response[@"venue"][@"location"][@"lng"] floatValue]];
    [self configureRestaurantInfo:response[@"venue"]];
}

- (void)didFinishLoadingLocu:(NSDictionary *)response {
    
}

- (void)didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushWebViewWithURL:(NSURL *)url {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
    UIViewController *webController = [[UIViewController alloc] init];
    [webController.view addSubview:webView];
    [self.navigationController pushViewController:webController animated:YES];
}

@end
