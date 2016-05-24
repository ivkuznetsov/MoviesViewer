//
//  UIView+Frame.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

- (CGPoint)origin {
	return self.frame.origin;
}

- (CGSize)size {
	return self.frame.size;
}

- (CGFloat)x {
	return self.frame.origin.x;
}

- (CGFloat)y {
	return self.frame.origin.y;
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setOrigin:(CGPoint)newOrigin {
	CGRect selfFrame = self.frame;
	selfFrame.origin = newOrigin;
	self.frame = selfFrame;
}

- (void)setSize:(CGSize)newSize {
	CGRect selfFrame = self.frame;
	selfFrame.size = newSize;
	self.frame = selfFrame;
}

- (void)setX:(CGFloat)newX {
	CGRect selfFrame = self.frame;
	selfFrame.origin.x = newX;
	self.frame = selfFrame;
}

- (void)setY:(CGFloat)newY {
	CGRect selfFrame = self.frame;
	selfFrame.origin.y = newY;
	self.frame = selfFrame;
}

- (void)setWidth:(CGFloat)newWidth {
	CGRect selfFrame = self.frame;
	selfFrame.size.width = newWidth;
	self.frame = selfFrame;
}

- (void)setHeight:(CGFloat)newHeight {
	CGRect selfFrame = self.frame;
	selfFrame.size.height = newHeight;
	self.frame = selfFrame;
}

@end
