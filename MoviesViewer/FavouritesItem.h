//
//  FavouritesItem.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectsContainer.h"

@interface FavouritesItem : UIBarButtonItem

- (instancetype)initWithMovie:(Movie *)movie container:(ObjectsContainer *)container;

@end
