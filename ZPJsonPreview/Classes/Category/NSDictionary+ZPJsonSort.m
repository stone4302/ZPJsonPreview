//
//  NSDictionary+ZPJsonSort.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/25.
//

#import "NSDictionary+ZPJsonSort.h"
#import "ZPJSONConfig.h"
#import "ZPJSONValue.h"
#import <objc/runtime.h>

@interface NSDictionary ()

/// 按照添加顺序的键值数组
@property (nonatomic, strong) NSMutableArray *zpjson_orderKeysOfAdd;

@end

@implementation NSDictionary (ZPJsonSort)

/// Put the `.unknown` value in last place.
///
/// Returns a sorted array of keys,
/// conforming to the following rules:
///
/// 1. If `JSONValue.unknown` exists, then it will be the last one in the array.
/// 2. The remaining elements will be sorted by `<`.
/// 过滤掉zp_unknown类型的数据
- (ZPJSONUnknownKeys)zpjson_rankingUnknownKeyLast
{
    if (self.count <= 0) {
        return @[];
    }
    
    NSString *unknownKey = nil;
    NSMutableArray *otherKeys = [NSMutableArray array];
    
    NSArray *allKeys = self.zpjson_orderKeys;
    
    for (NSString *key in allKeys) {
        id value = [self objectForKey:key];
        if (![value isKindOfClass:ZPJSONValue.class]) continue;
        ZPJSONValue *jsonValue = (ZPJSONValue *)value;
        if (jsonValue.valueClass == zp_unknown) {
            unknownKey = key;
            continue;
        }
        [otherKeys addObject:key];
    }
    
    // 将集合转换为数组
    NSMutableArray *result = [NSMutableArray arrayWithArray:otherKeys];
    // 是否按字母顺序排序
    if ([ZPJSONConfig shareConfig].isSortedByCharacter) {
        [result sortUsingSelector:@selector(compare:)];
    }
    
    if (unknownKey) {
        [result addObject:unknownKey];
    }
    
    return result;
}

- (void)zpjson_addKey:(NSString *)aKey
{
    if (!aKey || ![aKey isKindOfClass:NSString.class]) {
        return;
    }
    if (![self.zpjson_orderKeysOfAdd containsObject:aKey]) {
        [self.zpjson_orderKeysOfAdd addObject:aKey];
    }
}

- (NSArray *)zpjson_orderKeys
{
    return self.zpjson_orderKeysOfAdd.copy;
}

- (NSMutableArray *)zpjson_orderKeysOfAdd
{
    NSMutableArray *array = objc_getAssociatedObject(self, _cmd);
    if (!array || ![array isKindOfClass:NSMutableArray.class]) {
        array = [NSMutableArray arrayWithCapacity:0];
        [self setZpjson_orderKeysOfAdd:array];
    }
    return array;
}

- (void)setZpjson_orderKeysOfAdd:(NSMutableArray *)zpjson_orderKeysOfAdd
{
    objc_setAssociatedObject(self, @selector(zpjson_orderKeysOfAdd), zpjson_orderKeysOfAdd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
