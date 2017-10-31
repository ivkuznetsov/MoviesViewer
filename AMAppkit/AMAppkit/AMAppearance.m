//
//  AMAppearance.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 29/01/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMAppearance.h"

@interface NSInvocation(Copy)

- (id)copy;

@end

@implementation NSInvocation(Copy)

- (id)copy {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
    NSUInteger numberOfArguments = [[self methodSignature] numberOfArguments];
    
    [invocation setTarget:self.target];
    [invocation setSelector:self.selector];
    
    if (numberOfArguments > 2) {
        for (int i = 0; i < (numberOfArguments - 2); i++) {
            char buffer[sizeof(intmax_t)];
            [self getArgument:(void *)&buffer atIndex:i + 2];
            [invocation setArgument:(void *)&buffer atIndex:i + 2];
        }
    }
    return invocation;
}

@end


@interface AMAppearance()

@property (nonatomic) Class classObject;
@property (nonatomic) NSMutableArray *invocations;

@end

@implementation AMAppearance

+ (instancetype)appearanceForClass:(Class)classObject {
    static NSMutableDictionary *dictionary = nil;
    
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
    }
    
    NSString *key = NSStringFromClass(classObject);
    
    if (!dictionary[key]) {
        AMAppearance *appearance = [[self alloc] initWithClass:classObject];
        dictionary[key] = appearance;
    }
    return dictionary[key];
}

- (instancetype)initWithClass:(Class)classObject {
    if (self = [super init]) {
        _classObject = classObject;
        _invocations = [NSMutableArray array];
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_classObject instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setTarget:nil];
    [anInvocation retainArguments];
    
    // add the invocation to the array
    [self.invocations addObject:anInvocation];
}

- (void)startForwarding:(id)sender {
    for (NSInvocation *invocation in self.invocations) {
        
        NSInvocation *targetInvocation = [invocation copy];
        [targetInvocation setTarget:sender];
        [targetInvocation invoke];
        targetInvocation = nil;
    }
}

@end
