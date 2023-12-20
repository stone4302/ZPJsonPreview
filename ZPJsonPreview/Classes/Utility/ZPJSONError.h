//
//  ZPJSONError.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/20.
//

#import <Foundation/Foundation.h>
#import "ZPJSONException.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZPJSONError : NSObject

@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) ZPJSONException *exception;

+ (instancetype)jsonError:(NSError *)error;

+ (instancetype)jsonErrorWithException:(ZPJSONException *)exception;

@end

NS_ASSUME_NONNULL_END
