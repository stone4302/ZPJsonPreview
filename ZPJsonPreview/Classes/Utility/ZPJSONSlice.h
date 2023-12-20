//
//  ZPJSONSlice.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

// Used to represent a certain part of JSON

#import <Foundation/Foundation.h>
#import "ZPJSONHighlightStyle.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZPJSONSliceState) {
    ZPJSONSliceState_expand, // 张开
    ZPJSONSliceState_folded // 折叠
};

@interface ZPJSONSlice : NSObject

/// The current display state of the slice. The default is `.expand`.
@property (nonatomic, assign) ZPJSONSliceState state;

/// The number of times the slice was folded.
///
/// The initial value is 0, which means it is not folded.
/// Each time the slice is folded, the value increases by 1.
@property (nonatomic, assign) NSInteger foldedTimes;

/// Position in the complete structure.
@property (nonatomic, assign) NSInteger lineNumber;

/// Indentation level.
@property (nonatomic, assign) NSInteger level;

/// The complete content of the JSON slice in the expanded state.
@property (nonatomic, strong) NSMutableAttributedString *expand;

/// The summary content of the JSON slice in the folded state.
@property (nonatomic, strong) NSMutableAttributedString *folded;

- (NSMutableAttributedString *)showContent;

- (instancetype)initWithLevel:(NSInteger)level expand:(NSMutableAttributedString *)expand folded:(NSMutableAttributedString *)folded;

@end

NS_ASSUME_NONNULL_END
