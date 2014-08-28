//
//  RestaurantTableViewCell.m
//  Entree
//
//  Created by Jeremy Klein Sr on 7/3/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//


#import "RestaurantTableViewCell.h"

#define CONTENT_HEIGHT 220.0f;
#define ROW_HEIGHT 245.0f

@implementation RestaurantTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat numLabelWidth = 40.0f;
        CGFloat numLabelHeigth = 44.0f;
        CGFloat textLabelWidth = 100.0f;
        CGFloat padding = 10.0f;
        
        // Initialization code
        self.opaque = NO;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.clipsToBounds = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *dropshadowView = [[UIView alloc] init];
        dropshadowView.backgroundColor = [UIColor whiteColor];
        dropshadowView.frame = CGRectMake( 20.0f, 0.0f, 280.0f, ROW_HEIGHT);
        [self.contentView addSubview:dropshadowView];
        
        CALayer *layer = dropshadowView.layer;
        layer.masksToBounds = NO;
        layer.shadowRadius = 3.0f;
        layer.shadowOpacity = 0.5f;
        layer.shadowOffset = CGSizeMake( 0.0f, 1.0f);
        layer.shouldRasterize = YES;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.imageView.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 180.0f);
//        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        UIImageView *gradientOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_parse2.png"]];
//        gradientOverlay.frame = self.imageView.frame;
//        gradientOverlay.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView bringSubviewToFront:self.imageView];
        
//        [self.contentView addSubview:gradientOverlay];
//        [self.contentView bringSubviewToFront:gradientOverlay];
        
        self.avgScoreLabel = [[BBLabel alloc] initWithFrame:CGRectMake(20 + self.imageView.frame.size.width - 80.0f - padding , -10.0f, 80.0f, 80.0f)];
        self.avgScoreLabel.textAlignment = NSTextAlignmentRight;
        self.avgScoreLabel.font = [UIFont fontWithName:@"GillSans" size:18.0f];
        self.avgScoreLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.avgScoreLabel];
        
        self.numberOfReviews = [[BBLabel alloc] initWithFrame:CGRectOffset(self.avgScoreLabel.frame, 0, numLabelHeigth/2)];
        self.numberOfReviews.font = [UIFont fontWithName:@"GillSans" size:14.0f];
        self.numberOfReviews.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.numberOfReviews];
        
        self.restaurantNameLabel = [[BBLabel alloc] initWithFrame:CGRectMake( 20.0f + padding, CGRectGetMaxY(self.imageView.frame), self.imageView.frame.size.width - 50.0f, 44.0f)];
        self.restaurantNameLabel.backgroundColor = [UIColor clearColor];
        self.restaurantNameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.restaurantNameLabel];
        
        self.restaurantCuisine = [[BBLabel alloc] initWithFrame:CGRectOffset(self.restaurantNameLabel.frame, 0, numLabelHeigth/2)];
        self.restaurantCuisine.backgroundColor = [UIColor clearColor];
        self.restaurantCuisine.textColor = [UIColor blackColor];
        self.restaurantCuisine.font = [UIFont fontWithName:@"GillSans" size:14.0f];
        [self.contentView addSubview:self.restaurantCuisine];
        
        self.priceLabel = [[BBLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageView.frame) - self.imageView.frame.size.width/2 - padding, CGRectGetMaxY(self.imageView.frame), self.imageView.frame.size.width/2, 44.0f)];
        self.priceLabel.font = [UIFont fontWithName:@"GillSans" size:14.0f];
        self.priceLabel.textColor = [UIColor blackColor];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.priceLabel];
        
        self.addressLabel = [[BBLabel alloc] initWithFrame:CGRectOffset(self.priceLabel.frame, 0, numLabelHeigth/2)];
        self.addressLabel.font = [UIFont fontWithName:@"GillSans" size:14.0f];
        self.addressLabel.textColor = [UIColor blackColor];
        self.addressLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.addressLabel];
        
        [self.contentView bringSubviewToFront:self.addressLabel];
        
        UIView *cellSeparator = [[UIView alloc] initWithFrame:CGRectMake(20.0f, ROW_HEIGHT - 5.0f, self.imageView.frame.size.width, 5.0f)];
        cellSeparator.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:cellSeparator];
    }
    
    return self;
}

- (void)setDollarSign:(NSNumber *)priceTier {
    NSString *dollarSign;
    switch ([priceTier intValue]) {
        case 1:
            dollarSign = @"$";
            break;
        case 2:
            dollarSign = @"$$";
            break;
        case 3:
            dollarSign = @"$$$";
            break;
        case 4:
            dollarSign = @"$$$$";
            break;
            
        default:
            dollarSign = @"";
            break;
    }
    self.priceLabel.text = dollarSign;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 180.0f);
}

+ (CGFloat)rowHeight {
    return ROW_HEIGHT;
}

@end

