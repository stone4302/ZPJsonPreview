//
//  NSString+ZPJsonValidURL.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZPJSONValidURL : NSObject

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, assign) BOOL isIP;

- (instancetype)initWithUrlString:(NSString *)urlString isIP:(BOOL)isIP;

- (NSURL *)openingURL;

@end

@interface NSString (ZPJsonValidURL)

- (ZPJSONValidURL *)zp_json_validURL;

+ (NSDictionary *)zp_json_data_test;

@end

NS_ASSUME_NONNULL_END
