//
//  AMNotification.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMObservable;

@interface AMNotification : NSObject

@property (nonatomic) NSSet *created;
@property (nonatomic) NSSet *updated;
@property (nonatomic) NSSet *deleted;
@property (nonatomic) id sender;
@property (nonatomic) id object;
@property (nonatomic) NSDictionary *userInfo;

+ (instancetype)makeWithUpdated:(NSSet *)updated;
- (instancetype)initWithCreated:(NSSet *)created updated:(NSSet *)updated deleted:(NSSet *)deleted sender:(id)sender userInfo:(NSDictionary *)userInfo;

@end
