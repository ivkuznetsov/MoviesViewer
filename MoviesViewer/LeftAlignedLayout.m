//
//  LeftAlignedLayout.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "LeftAlignedLayout.h"

@implementation LeftAlignedLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesForElementsInRect = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributesForElementsInRect = [[NSMutableArray alloc] initWithCapacity:attributesForElementsInRect.count];
    CGFloat leftMargin = self.sectionInset.left;
    
    for (UICollectionViewLayoutAttributes *attributes in attributesForElementsInRect) {
        
        BOOL newLine = leftMargin + attributes.frame.size.width > rect.size.width;
        
        if (newLine) {
            leftMargin = self.sectionInset.left;
        }
        CGRect newLeftAlignedFrame = attributes.frame;
        newLeftAlignedFrame.origin.x = leftMargin;
        attributes.frame = newLeftAlignedFrame;
        leftMargin += attributes.frame.size.width;
        [newAttributesForElementsInRect addObject:attributes];
    }
    return newAttributesForElementsInRect;
}

@end