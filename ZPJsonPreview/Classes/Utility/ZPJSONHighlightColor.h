//
//  ZPJSONHighlightColor.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *JSONHighlightColorKey;

UIKIT_EXTERN JSONHighlightColorKey const keyWord;
UIKIT_EXTERN JSONHighlightColorKey const key;
UIKIT_EXTERN JSONHighlightColorKey const alink;
UIKIT_EXTERN JSONHighlightColorKey const string;
UIKIT_EXTERN JSONHighlightColorKey const number;
UIKIT_EXTERN JSONHighlightColorKey const boolean;
UIKIT_EXTERN JSONHighlightColorKey const null;
UIKIT_EXTERN JSONHighlightColorKey const unknownText;
UIKIT_EXTERN JSONHighlightColorKey const unknownBackground;
UIKIT_EXTERN JSONHighlightColorKey const jsonBackground;
UIKIT_EXTERN JSONHighlightColorKey const lineBackground;
UIKIT_EXTERN JSONHighlightColorKey const lineText;
UIKIT_EXTERN JSONHighlightColorKey const errorText;

@interface ZPJSONHighlightColor : NSObject

+ (instancetype)defaultHighlightColor;

- (UIColor *)colorKey:(JSONHighlightColorKey)key;

@end

NS_ASSUME_NONNULL_END
