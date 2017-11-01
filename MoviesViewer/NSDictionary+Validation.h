//
//  NSDictionary+Validation.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Validation)

- (id)validObjectForKey:(id)key;

@end