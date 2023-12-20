//
//  ZPJSONHighlightStyle.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "ZPJSONHighlightStyle.h"

@implementation ZPJSONHighlightStyle

- (UIImage *)expandIcon
{
    if (!_expandIcon) {
        _expandIcon = [UIImage imageNamed:@"zp_json_expand.png"];
    }
    return _expandIcon;
}

- (UIImage *)foldIcon
{
    if (!_foldIcon) {
        _foldIcon = [UIImage imageNamed:@"zp_json_folded.png"];
    }
    return _foldIcon;
}

- (UIFont *)lineFont
{
    if (!_lineFont) {
        _lineFont = [UIFont fontWithName:@"Helvetica Neue" size:16];
    }
    return _lineFont;
}

- (UIFont *)jsonFont
{
    if (!_jsonFont) {
        _jsonFont = [UIFont fontWithName:@"Helvetica Neue" size:16];
    }
    return _jsonFont;
}

- (UIFont *)errorFont
{
    if (!_errorFont) {
        _errorFont = [UIFont fontWithName:@"Helvetica Neue" size:16];
    }
    return _errorFont;
}

- (ZPJSONHighlightColor *)color
{
    if (!_color) {
        _color = [ZPJSONHighlightColor defaultHighlightColor];
    }
    return _color;
}

- (CGFloat)lineHeight
{
    return 24.0;
}

@end
