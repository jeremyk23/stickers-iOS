//
//  EMenu.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu_SectionTitle.h"
#import "Menu_SectionDescr.h"
#import "Menu_Dish.h"
#import "Menu_DishWithDescr.h"

/* EMenu is a class for displaying the menu in a UITableView. Each restaurant can have multiple menus. (e.g breakfast lunch and dinner). These multiple menus are stored in the single @property, arrayOfRestaurants.
    
 THIS IS WRONG FROM HERE DOWN. NEED TO FIX.   
 Each object in arrayOfRestaurants is a dictionary which as 3 keys, sectionArray, menuArray, and menuName.
    
 
    |arrayOfRestaurants
    |----sectionArray
    |--------sectionArray           //THIS IS DUMB. Should fix.
    |------------EMenu_SectionTitle
    |----------------.numberOfDishes
    |----------------.sectionTitle
    |----menuArray
    |--------EMenu_SectionDescr
    |------------.sectionDescription
    |--------EMenu_DishWithDescr
    |------------.dishName
    |------------.dishDescription
    |------------.price
    |------------.rating
    |----menuName
    |--------menuName
 
 */

@interface Menu : NSObject

@property (nonatomic, strong) NSMutableArray *arrayOfMenus;

@end
