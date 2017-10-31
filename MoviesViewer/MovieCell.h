//
//  MovieCell.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "BaseCell.h"

@interface MovieCell : BaseCell

@property (nonatomic) Movie *movie;

+ (CGSize)sizeForContentWidth:(CGFloat)width space:(CGFloat)space;

@end
