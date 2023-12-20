//
//  ZPJSONHighlightStyle.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import <Foundation/Foundation.h>
#import "ZPJSONHighlightColor.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableDictionary <NSAttributedStringKey, id> * ZPJsonStyleInfos;

// @[expandString, foldString]
typedef NSArray <NSMutableAttributedString *> * ZPJsonArrayAttribute;

@interface ZPJSONHighlightStyle : NSObject

/// The icon of the expand(展开) button.
@property (nonatomic, strong) UIImage *expandIcon;
/// The icon of the fold(折叠) button.
@property (nonatomic, strong) UIImage *foldIcon;
/// Text font in line number area.
@property (nonatomic, strong) UIFont *lineFont;
/// Text font in json preview area.
@property (nonatomic, strong) UIFont *jsonFont;
/// The error text font in preview area.
@property (nonatomic, strong) UIFont *errorFont;
/// Color-related configuration. See `ZPJSONHighlightColor` for details.
@property (nonatomic, strong) ZPJSONHighlightColor *color;
/// Line height of JSON preview area.
@property (nonatomic, assign) CGFloat lineHeight;

@end

NS_ASSUME_NONNULL_END
