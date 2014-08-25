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
#import "Helpers.h"

#define NUMBER_OF_ASYNCH_CALLS 2

@interface RestaurantViewController ()
@property (nonatomic, strong) NSArray *restaurantInfo;
@property (nonatomic, strong) NSArray *topDishes;
@property (nonatomic, strong) NSArray *awards;
@property (nonatomic, strong) NSArray *reviews;
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
        
        [self.photoGallery registerNib:[UINib nibWithNibName:@"RestaurantPhotoGalleryCell" bundle:nil]  forCellWithReuseIdentifier:@"RestaurantPhotoCell"];
//        self.photos = [self createPhotosArray];
        self.fsImageSource = [[FSBasicImageSource alloc] initWithImages:[self createPhotosArray]];
        [self.photoGallery reloadData];
        
//        self.restaurantPhoto.file = self.restaurant[@"restaurantPhoto"];
//        [self.restaurantPhoto loadInBackground];
        self.restaurantNameLabel.text = self.restaurant[@"restaurantName"];
        self.restaurantNameLabel.textColor = [UIColor blackColor];
        self.addressLabel.text = self.restaurant[@"address"];
        [self.view bringSubviewToFront:self.restaurantNameLabel];
        [self detailedRestaurantQuery];
    }
}

- (NSArray *)createPhotosArray {
//    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[self.restaurant[@"pictures"] count] + 1];
//    PFFile *mainRestaurantPhoto = self.restaurant[@"restaurantPhoto"];
//    if (mainRestaurantPhoto) {
//        [tempArray addObject:mainRestaurantPhoto];
//    }
//    [tempArray addObjectsFromArray:self.restaurant[@"pictures"]];
//    return (NSArray *)tempArray;
    
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
    
//    [tempArray addObjectsFromArray:self.restaurant[@"pictures"]];
    return (NSArray *)tempArray;
}

- (void)detailedRestaurantQuery {
    PFQuery *detailQuery = [PFQuery queryWithClassName:@"Restaurant"];
    [detailQuery includeKey:@"topDishes"];
    [detailQuery includeKey:@"awards"];
    [detailQuery includeKey:@"reviews"];
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
            
            if ([detailedRestaurant[@"reviews"] count] != 0) {
                self.reviews = [NSArray arrayWithArray:detailedRestaurant[@"reviews"]];
                self.reviewsSection = sectionCount;
                sectionCount += 1;
            }
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
        if (self.reviews != 0) {
            return self.reviews.count;
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

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat screenWidth = self.view.frame.size.width;
    switch (section) {
            //view menu
        if (section == self.menuSection) {
            UIView *menuHeader = [[UIView alloc] initWithFrame:CGRectMake(-30, 0, screenWidth, 30.0f)];
            UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30.0f)];
            menuHeader.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0];
            menuLabel.text = @"Menu";
            [menuHeader addSubview:menuLabel];
            return menuHeader;
            break;
        }
            
            //top dishes
        case 1: {
            UIView *topDishesHeader = [[UIView alloc] initWithFrame:CGRectMake(-30, 0, screenWidth, 30.0f)];
            UILabel *topDishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30.0f)];
            topDishesLabel.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0];
            topDishesLabel.text = @"Top Dishes";
            [topDishesHeader addSubview:topDishesLabel];
            return topDishesHeader;
            break;
        }
            //reviews
        case 2: {
            UIView *reviewsHeader = [[UIView alloc] initWithFrame:CGRectMake(-30, 0, screenWidth, 30.0f)];
            UILabel *reviewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30.0f)];
            reviewsLabel.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0];
            reviewsLabel.text = @"Reviews";
            [reviewsHeader addSubview:reviewsLabel];
            return reviewsHeader;
            break;
        }
        default: {
            UIView *dummyHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 30.0f)];
            return dummyHeader;
            break;
        }
    }
}
*/
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
        if (self.reviews[indexPath.row] != [NSNull null]) {
            cell.textLabel.text = self.reviews[indexPath.row][@"publicationName"];
            cell.detailTextLabel.text = self.reviews[indexPath.row][@"headline"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = @"Sorry!";
            cell.detailTextLabel.text = @"There was an error retrieving this review.";
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
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
        NSURL *url = [NSURL URLWithString:self.reviews[indexPath.row][@"url"]];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [webView loadRequest:requestObj];
        UIViewController *webController = [[UIViewController alloc] init];
        [webController.view addSubview:webView];
        [self.navigationController pushViewController:webController animated:YES];
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
    [cell.imageView sd_setImageWithURL:pictureURL
                   placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"]];
    [cell.imageView sd_setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"placeholder-photo.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        cell.imageView.image = [Helpers imageByScalingAndCroppingForSize:cell.imageView.frame.size withImage:image];
    }];
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
    return CGSizeMake(320.0f, 180.0f);
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


- (void)didFinishLoadingFoursquare:(NSDictionary *)response {
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


@end
