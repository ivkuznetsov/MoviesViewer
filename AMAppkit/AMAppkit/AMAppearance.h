//
//  AMAppearance.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 29/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAppearance : NSObject

+ (instancetype)appearanceForClass:(Class)classObject;
- (void)startForwarding:(id)sender;

@end
