//
//  NSMutableDictionary+ZPJsonSort.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import "NSMutableDictionary+ZPJsonSort.h"

@implementation NSMutableDictionary (ZPJsonSort)

- (void)zpjson_setObject:(id)anObject forKey:(NSString *)aKey
{
    if (anObject && aKey && [aKey isKindOfClass:NSString.class]) {
        [self setObject:anObject forKey:aKey];
        [self zpjson_addKey:aKey];
    }
}

@end
