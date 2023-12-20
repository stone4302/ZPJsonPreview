//
//  ZPJSONConfig.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import "ZPJSONConfig.h"

@implementation ZPJSONConfig

+ (instancetype)shareConfig
{
    static ZPJSONConfig *config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[ZPJSONConfig alloc] init];
    });
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isSortedByCharacter = NO;
    }
    return self;
}

@end
