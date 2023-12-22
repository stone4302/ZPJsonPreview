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
        _expandIcon = [UIImage imageNamed:@"zp_json_expand"];
        if (!_expandIcon || ![_expandIcon isKindOfClass:UIImage.class]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ZPJsonPreview" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            _expandIcon = [UIImage imageNamed:@"zp_json_expand" inBundle:bundle compatibleWithTraitCollection:nil];
        }
    }
    return _expandIcon;
}

- (UIImage *)foldIcon
{
    if (!_foldIcon) {
        _foldIcon = [UIImage imageNamed:@"zp_json_folded"];
        if (!_foldIcon || ![_foldIcon isKindOfClass:UIImage.class]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ZPJsonPreview" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            _foldIcon = [UIImage imageNamed:@"zp_json_folded" inBundle:bundle compatibleWithTraitCollection:nil];
        }
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
