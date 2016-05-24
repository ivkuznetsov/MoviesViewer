//
//  NSObject+ClassName.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSObject+ClassName.h"
#import <objc/runtime.h>

@implementation NSObject (ClassName)

- (NSString *)className {
	return [NSString stringWithUTF8String:class_getName([self class])];
}

+ (NSString *)className {
	return [NSString stringWithUTF8String:class_getName(self)];
}

@end