//
//  ELocuParser.m
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import "ELocuParser.h"
#import "Menu.h"
#import "Constants.h"

@implementation ELocuParser

- (Menu *)getFormattedEMenuObject:(NSDictionary *)response {
    NSArray *hasMenu = [response valueForKeyPath:@"objects.has_menu"];
    if ([hasMenu[0]  isEqual: @(0)]) {
        return nil;
    } else {
        NSUInteger numberOfMenus = [[response valueForKeyPath:@"objects.menus"][0] count];
        Menu *eMenu = [[Menu alloc] init];
        int i = 0;
        while (i < numberOfMenus) {
            NSString *menuName = [response valueForKeyPath:@"objects.menus"][0][i][@"menu_name"];
            [eMenu.arrayOfMenus addObject:[self constructMenuDictionary:[response valueForKeyPath:@"objects.menus"][0][i] withMenuTitled:menuName forEMenu:eMenu]];
            i++;
        }
        return eMenu;
    }
}

- (NSDictionary *)constructMenuDictionary:(NSDictionary *)tempMenuDict withMenuTitled:(NSString *)menuName forEMenu:(Menu *)eMenu {
    NSMutableArray *finalMenuArray = [[NSMutableArray alloc] init];
    NSMutableArray *sectionsArray = [[NSMutableArray alloc] initWithCapacity:[tempMenuDict[@"sections"] count]];
    
    /* loop through sections of menu */
    for (int i = 0; i < [tempMenuDict[@"sections"] count]; i++) {
        
        /* Keep track of section title and how many dishes are in each section */
        Menu_SectionTitle *sectionTitle = [[Menu_SectionTitle alloc] initWithSectionTitle:tempMenuDict[@"sections"]
                                                                [i][@"section_name"]];
        sectionTitle.numberOfDishes = [tempMenuDict[@"sections"] count];
        [sectionsArray addObject:sectionTitle];
        
        NSArray *contentsArray = [[NSArray alloc] initWithArray:tempMenuDict[@"sections"][i][@"subsections"][0][@"contents"]];
        NSMutableArray *tableViewSectionArray = [[NSMutableArray alloc] initWithCapacity:10];
        for (NSDictionary *itemsDict in contentsArray) {
            if ([itemsDict[@"type"] isEqualToString:@"ITEM"]) {
                //add the item dict
                NSString *dishDescription = itemsDict[@"description"];
                if (dishDescription) {
                    Menu_DishWithDescr *dishWithDescr = [[Menu_DishWithDescr alloc] initWithDishName:itemsDict[@"name"]];
                    dishWithDescr.dishDescription = dishDescription;
                    if (itemsDict[@"price"]) {
                        dishWithDescr.price = itemsDict[@"price"];
                    }
                    [tableViewSectionArray addObject:dishWithDescr];
                } else {
                    Menu_Dish *dish = [[Menu_Dish alloc] initWithDishName:itemsDict[@"name"]];
                    if (itemsDict[@"price"]) {
                        dish.price = itemsDict[@"price"];
                    }
                    [tableViewSectionArray addObject:dish];
                }
            } else if ([itemsDict[@"type"] isEqualToString:@"SECTION_TEXT"]) {
                Menu_SectionDescr *sectionDescription = [[Menu_SectionDescr alloc] initWithSectionDescription:itemsDict[@"text"]];
                [tableViewSectionArray addObject:sectionDescription];
            }
        }
        [finalMenuArray addObject:tableViewSectionArray];
    }
    return [[NSDictionary alloc] initWithObjectsAndKeys:menuName, kMenu_menuName, sectionsArray, kMenu_sectionArray, finalMenuArray, kMenu_menuArray, nil];
}

@end
