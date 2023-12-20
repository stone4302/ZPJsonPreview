//
//  ZPJSONDecorator.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import <Foundation/Foundation.h>
#import "ZPJSONHighlightStyle.h"
#import "ZPJSONSlice.h"
#import "ZPJSONError.h"

typedef NSArray <ZPJSONSlice *> * ZPJSONSlices;
typedef NSMutableArray<ZPJSONSlice *> * ZPJSONMutSlices;

NS_ASSUME_NONNULL_BEGIN

@interface ZPJSONDecorator : NSObject

@property (nonatomic, strong, readonly) ZPJSONHighlightStyle *style;
@property (nonatomic, strong, readonly) ZPJSONSlices slices;
@property (nonatomic, strong, readonly) ZPJSONError *error;

@property (nonatomic, strong, readonly) NSMutableAttributedString *wrapString;

+ (instancetype)decoratorWithJson:(id)json
                            style:(ZPJSONHighlightStyle *)style;

+ (instancetype)decoratorWithJson:(id)json
                    judgmentValid:(BOOL)judgmentValid
                            style:(ZPJSONHighlightStyle *)style;

- (BOOL)isExpandOrFoldString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
