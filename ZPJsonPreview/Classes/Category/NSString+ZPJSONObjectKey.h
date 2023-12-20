//
//  NSString+ZPJSONObjectKey.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ZPJSONObjectKey)

/// Is the key wrong.
@property (nonatomic, assign) BOOL zp_json_isWrong;

@end

NS_ASSUME_NONNULL_END
