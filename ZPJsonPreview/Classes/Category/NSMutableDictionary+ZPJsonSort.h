//
//  NSMutableDictionary+ZPJsonSort.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+ZPJsonSort.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (ZPJsonSort)

- (void)zpjson_setObject:(id)anObject forKey:(NSString *)aKey;

@end

NS_ASSUME_NONNULL_END
