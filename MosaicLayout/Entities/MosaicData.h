//
//  MosaicData.h
//  MosaicCollectionView
//
//  Created by Ezequiel A Becerra on 2/17/13.
//  Copyright (c) 2013 Betzerra. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PFFile;

typedef enum {
    kMosaicLayoutTypeUndefined,
    kMosaicLayoutTypeSingle,
    kMosaicLayoutTypeDouble
} MosaicLayoutType;

@interface MosaicData : NSObject

-(id)initWithPFFile:(PFFile *)file publicationName:(NSString *)publicationName andDatePublished:(NSDate *)date;

@property (strong) PFFile *parseFile;
@property (strong) NSString *title;
@property (strong) NSString *yearPublished;
@property (strong) NSString *reviewURL;
@property (assign) BOOL isTopPublication;
@property (assign) BOOL firstTimeShown;
@property (assign) MosaicLayoutType layoutType;
@property (assign) float relativeHeight;
@end
