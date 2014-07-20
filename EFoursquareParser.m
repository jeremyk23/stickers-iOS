//
//  EFoursquareParser.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/16/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "EFoursquareParser.h"
#import "Menu.h"
#import "Constants.h"

@interface EFoursquareParser ()
@end

@implementation EFoursquareParser

- (id)init {
    self = [super init];
    if (self) {
        //custom stuff
    }
    return self;
}

- (Menu *)getFormattedEMenuObject:(NSDictionary *)response {
    Menu *eMenu;
    NSString *platformProvider = [response valueForKeyPath:@"menu.provider.name"];
    if ([platformProvider isEqualToString: @"singleplatform"]) {
        eMenu = [self createEMenuWithResponse:response];
    } else {
        eMenu = nil;
    }
    return eMenu;
}

- (Menu *)createEMenuWithResponse:(NSDictionary *)response {
    int noOfMenus = [response[@"menu"][@"menus"][@"count"] intValue];
    //menu data is unavailable
    if (noOfMenus == 0) {
        return nil;
    } else {
        Menu *eMenu = [[Menu alloc] init];
        int i = 0;
        while (i < noOfMenus) {
            NSString *menuName = response[@"menu"][@"menus"][@"items"][i][@"name"];
            NSArray *tempMenuArray = [[NSArray alloc] initWithArray:response[@"menu"][@"menus"][@"items"][i][@"entries"][@"items"]];
            NSDictionary *menuDictionary = [self constructMenuDictionary:tempMenuArray withMenuTitled:menuName forEMenu:eMenu];
            [eMenu.arrayOfMenus addObject:menuDictionary];
            i++;
        }
        return eMenu;
    }
}

- (NSDictionary *)constructMenuDictionary:(NSArray *)tempMenuArray withMenuTitled:(NSString *)menuName forEMenu:(Menu *)eMenu {
    NSMutableArray *finalMenuArray = [[NSMutableArray alloc] init];
    NSMutableArray *sectionsArray = [[NSMutableArray alloc] initWithCapacity:tempMenuArray.count];
    //Loop through sections of the menu
    for (int i = 0; i < tempMenuArray.count; i++) {
        
        /* Keep track of section title and how many dishes are in each section */
        Menu_SectionTitle *sectionTitle = [[Menu_SectionTitle alloc] initWithSectionTitle:tempMenuArray[i][@"name"]];
        sectionTitle.numberOfDishes = [tempMenuArray[i][@"entries"][@"count"] intValue];
        [sectionsArray addObject:sectionTitle];
        
        /*If Section description exists, add it it to finalMenuArray */
        NSString *sectionDescription = tempMenuArray[i][@"description"];
        if (sectionDescription) {
            Menu_SectionDescr *sectionTitleWithDescr = [[Menu_SectionDescr alloc] initWithSectionDescription:sectionDescription];
            [finalMenuArray addObject:sectionTitleWithDescr];
        }
        
        /* add dishes in current section */
        for (NSDictionary *itemDict in tempMenuArray[i][@"entries"][@"items"]) {
            NSString *dishDescription = itemDict[@"description"];
            if (dishDescription == nil) {
                Menu_Dish *dish =[[Menu_Dish alloc] initWithDishName:itemDict[@"name"]];
                if (itemDict[@"price"] != nil) {
                    dish.price = itemDict[@"price"];
                } else {
                    dish.price = @"";
                }
                [finalMenuArray addObject:dish];
            } else {
                Menu_DishWithDescr *dishWithDescr =[[Menu_DishWithDescr alloc] initWithDishName:itemDict[@"name"]];
                dishWithDescr.dishDescription = dishDescription;
                if (itemDict[@"price"] != nil) {
                    dishWithDescr.price = itemDict[@"price"];
                } else {
                    dishWithDescr.price = @"";
                }
                [finalMenuArray addObject:dishWithDescr];
            }
        }
    }
    NSDictionary *menuDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:menuName, kMenu_menuName, sectionsArray, kMenu_sectionArray, finalMenuArray, kMenu_menuArray, nil];
    return menuDictionary;
}


- (NSString *)getHoursWithTimes:(NSArray *)restaurantTimes {
    NSString *temp = @"";
    for (int i =0; i < restaurantTimes.count; i++) {
        if (i > 0) {
            temp = [temp stringByAppendingFormat:@" | "];
        }
        NSArray *temp2 = restaurantTimes[i][@"days"];
        NSString *tempDay = @"";
        if (temp2.count != 1) {
            for (int a =0; a < temp2.count; a += (temp2.count -1)) {
                if (a > 0) {
                    tempDay = [tempDay stringByAppendingFormat:@" - "];
                }
                //            NSLog(@"%@", restaurantTimes[i][@"days"][a]);
                NSString *temp3 = [NSString stringWithFormat:@"%@", restaurantTimes[i][@"days"][a]];
                if ([temp3 isEqualToString: @"1"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"M"];
                }
                else if ([temp3 isEqualToString: @"2"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"T"];
                }
                else if ([temp3 isEqualToString: @"3"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"W"];
                }
                else if ([temp3 isEqualToString: @"4"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"R"];
                }
                else if ([temp3 isEqualToString: @"5"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"F"];
                }
                else if ([temp3 isEqualToString: @"6"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"Sat"];
                }
                else if ([temp3 isEqualToString: @"7"]) {
                    tempDay = [tempDay stringByAppendingFormat:@"Sun"];
                }
            }
        } else {
            NSString *temp3 = [NSString stringWithFormat:@"%@", restaurantTimes[i][@"days"][0]];
            if ([temp3 isEqualToString: @"1"]) {
                tempDay = [tempDay stringByAppendingFormat:@"M"];
            }
            else if ([temp3 isEqualToString: @"2"]) {
                tempDay = [tempDay stringByAppendingFormat:@"T"];
            }
            else if ([temp3 isEqualToString: @"3"]) {
                tempDay = [tempDay stringByAppendingFormat:@"W"];
            }
            else if ([temp3 isEqualToString: @"4"]) {
                tempDay = [tempDay stringByAppendingFormat:@"R"];
            }
            else if ([temp3 isEqualToString: @"5"]) {
                tempDay = [tempDay stringByAppendingFormat:@"F"];
            }
            else if ([temp3 isEqualToString: @"6"]) {
                tempDay = [tempDay stringByAppendingFormat:@"Sat"];
            }
            else if ([temp3 isEqualToString: @"7"]) {
                tempDay = [tempDay stringByAppendingFormat:@"Sun"];
            }
        }
        temp = [temp stringByAppendingFormat:@"%@", tempDay];
        NSArray *temp4 = restaurantTimes[i][@"open"];
        for (int b =0; b < temp4.count; b++) {
            if (b > 0) {
                temp = [temp stringByAppendingFormat:@", "];
            }
            
            NSString *start = [temp4[b][@"start"] substringToIndex:2];
            NSString *start2 = [temp4[b][@"start"] substringFromIndex:2];
            if ([[start substringToIndex:1] isEqualToString:@"+"]) {
                start = [temp4[b][@"start"] substringWithRange:NSMakeRange(1,2)];
                start2 = [start2 substringFromIndex:1];
            }
            if ([[start substringToIndex:1] isEqualToString:@"0"]) {
                start = [start substringFromIndex:1];
            }
            
            NSString *end = [temp4[b][@"end"] substringToIndex:2];
            NSString *end2 = [temp4[b][@"end"] substringFromIndex:2];
            
            if ([[end substringToIndex:1] isEqualToString:@"+"]) {
                end = [temp4[b][@"end"] substringWithRange:NSMakeRange(1,2)];
                end2 = [end2 substringFromIndex:1];
            }
            if ([[end substringToIndex:1] isEqualToString:@"0"]) {
                end = [end substringFromIndex:1];
            }
            temp = [temp stringByAppendingFormat:@" %@:%@", start, start2];
            temp = [temp stringByAppendingFormat:@" - %@:%@", end, end2];
        }
    }
    return temp;
}

+ (NSURL *)getPhotoClosestTo:(float)width byHeight:(float)height withResponse:(NSDictionary *)response {
    float aspectRatioToCompare = width/height;
    //set the first photo as initial closest match
    float bestPhotoWidth = [response[@"photos"][@"items"][0][@"width"] floatValue];
    float closestMatch = bestPhotoWidth / [response[@"photos"][@"items"][0][@"height"] floatValue];
    int closestMatchIndex = 0;
    
    BOOL goodWidthFound = TRUE;
    if (bestPhotoWidth < 640) {
        goodWidthFound = FALSE;
    }
    
    int i = 1;
    while (i < [response[@"photos"][@"items"] count]) {
        float photoWidth = [response[@"photos"][@"items"][i][@"width"] floatValue];
        if (photoWidth >= width) {
            float photoAspectRatio = photoWidth / [response[@"photos"][@"items"][i][@"height"] floatValue];
            double delta = fabsf(photoAspectRatio - aspectRatioToCompare);
            //an exact match, choose this photo and break
            if (delta == 0) {
                closestMatchIndex = i;
                break;
            } else if (delta < closestMatch) {
                closestMatch = delta;
                closestMatchIndex = i;
            }
            //if the initial picture selected was < specified width passed in, check to see if this picture is equal to or closer to specified width
        } else if (goodWidthFound == FALSE) {
            if (photoWidth - bestPhotoWidth > 0) {
                bestPhotoWidth = photoWidth;
                closestMatchIndex = i;
                if (bestPhotoWidth >= 640) {
                    goodWidthFound = TRUE;
                }
            }
        }
        i++;
    }
    NSDictionary *photoDict = response[@"photos"][@"items"][closestMatchIndex];
    NSString *imageStr = photoDict[@"prefix"];
    NSString *widthByHeight = [NSString stringWithFormat:@"%dx%d", (int)width, (int)height];
    NSString *suffix = [NSString stringWithFormat:@"%@/%@", widthByHeight, [photoDict[@"suffix"] substringFromIndex:1]];
    imageStr = [imageStr stringByAppendingString:suffix];
    NSURL *imageURL = [NSURL URLWithString:imageStr];
    return imageURL;
}

+ (NSArray *)returnRestaurantsArray:(NSDictionary *)response {
    NSArray *restaurantsArray;
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    if ([response count] != 0 ) {
        restaurantsArray = [response valueForKey:@"groups"][0][@"items"];
    }
    //manual filtering. should change later
    for (int i =0; i < restaurantsArray.count; i++) {
        //check if address exists
        if (restaurantsArray[i][@"venue"][@"location"][@"address"] != nil) {
            NSArray *categoriesArray = restaurantsArray[i][@"venue"][@"categories"];
            //check if place is categorize
            if ([categoriesArray count] != 0) {
                //check if its a food-related place
                NSString *urlPrefix = categoriesArray[0][@"icon"][@"prefix"];
                if ([urlPrefix rangeOfString:@"categories_v2/food"].location != NSNotFound) {
                    [filteredArray addObject:restaurantsArray[i]];
                }
            }
        }
    }
    NSArray *returnArray = [NSArray arrayWithArray:filteredArray];
    return returnArray;
}

+ (NSArray *)returnProfessionalTips:(NSDictionary *)response {
    NSMutableArray *professionalTips = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSDictionary *tip in response[@"tips"][@"groups"][0][@"items"]) {
        if (tip[@"user"][@"type"]) {
            [professionalTips addObject:@{@"name": tip[@"user"][@"firstName"], @"tip": tip[@"text"]}];
        }
    }
    return (NSArray *)professionalTips;
}

@end

