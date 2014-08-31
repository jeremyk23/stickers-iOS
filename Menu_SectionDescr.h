//
//  EMenu_SectionTitleWithDescr.h
//  Entree
//
//  Created by Jeremy Klein Sr on 5/17/14.
//  Copyright (c) 2014 Entree. All rights reserved.
//

// #import <Foundation/Foundation.h>
#import "Menu_MenuType.h"

@interface Menu_SectionDescr : Menu_MenuType

@property (nonatomic, strong) NSString *sectionDescription;

- (id)initWithSectionDescription:(NSString *)description;

@end
