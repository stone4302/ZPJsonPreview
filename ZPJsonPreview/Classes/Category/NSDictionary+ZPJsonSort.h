//
//  NSDictionary+ZPJsonSort.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSArray <NSString *> * ZPJSONUnknownKeys;

@interface NSDictionary (ZPJsonSort)

@property (nonatomic, copy, readonly) NSArray *zpjson_orderKeys;

- (ZPJSONUnknownKeys)zpjson_rankingUnknownKeyLast;

- (void)zpjson_addKey:(NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
