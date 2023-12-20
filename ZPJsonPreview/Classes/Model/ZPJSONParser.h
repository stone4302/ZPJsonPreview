//
//  ZPJSONParser.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/27.
//

#import <Foundation/Foundation.h>
#import "ZPJSONDocumentReader.h"
#import "ZPJSONValue.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZPJSONParser : NSObject

@property (nonatomic, strong) ZPJSONDocumentReader *reader;
@property (nonatomic, assign) NSInteger depth;

- (instancetype)initWithData:(NSData *)data;

- (ZPJSONValue *)try_parse;

@end

NS_ASSUME_NONNULL_END
