//
//  NSData+ZPJSONEncode.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ZPJSONEncode)

+ (NSData *)zpjson_dataWithJson:(id)json;

@end

NS_ASSUME_NONNULL_END
