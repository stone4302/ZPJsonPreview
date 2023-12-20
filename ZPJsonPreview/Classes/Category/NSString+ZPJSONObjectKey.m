//
//  NSString+ZPJSONObjectKey.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/8.
//

#import "NSString+ZPJSONObjectKey.h"
#import <objc/runtime.h>

@implementation NSString (ZPJSONObjectKey)

- (void)setZp_json_isWrong:(BOOL)zp_json_isWrong
{
    objc_setAssociatedObject(self, @selector(zp_json_isWrong), @(zp_json_isWrong), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)zp_json_isWrong
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    BOOL bl = NO;
    if ([number respondsToSelector:@selector(boolValue)]) {
        bl = [number boolValue];
    }
    return bl;
}

@end
