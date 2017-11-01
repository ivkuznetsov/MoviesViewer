//
//  AMNotification.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 26/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMNotification.h"

@implementation AMNotification

+ (instancetype)makeWithUpdated:(NSSet *)updated {
    return [[self alloc] initWithCreated:nil updated:updated deleted:nil sender:nil userInfo:nil];
}

- (instancetype)initWithCreated:(NSSet *)created updated:(NSSet *)updated deleted:(NSSet *)deleted sender:(id)sender userInfo:(NSDictionary *)userInfo {
    if (self = [super init]) {
        _created = created;
        _updated = updated;
        _deleted = deleted;
        _sender = sender;
        _userInfo = userInfo;
    }
    return self;
}

@end
