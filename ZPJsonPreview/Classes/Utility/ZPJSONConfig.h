//
//  ZPJSONConfig.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPJSONConfig : NSObject

// is the object elements will sort by character
@property (nonatomic, assign) BOOL isSortedByCharacter;

+ (instancetype)shareConfig;

@end

NS_ASSUME_NONNULL_END
