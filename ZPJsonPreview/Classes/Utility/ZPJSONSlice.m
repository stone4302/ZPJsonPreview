//
//  ZPJSONSlice.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "ZPJSONSlice.h"

@implementation ZPJSONSlice

- (instancetype)initWithLevel:(NSInteger)level expand:(NSMutableAttributedString *)expand folded:(NSMutableAttributedString *)folded
{
    self = [super init];
    if (self) {
        _level = level;
        _expand = expand;
        _folded = folded;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _state = ZPJSONSliceState_expand;
        _foldedTimes = 0;
    }
    return self;
}

- (NSMutableAttributedString *)showContent
{
    switch (self.state) {
        case ZPJSONSliceState_expand:
            return self.expand;
        case ZPJSONSliceState_folded:
            return self.folded;
        default:
            return nil;
    }
}

@end
