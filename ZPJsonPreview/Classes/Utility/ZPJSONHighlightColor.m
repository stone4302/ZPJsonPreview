//
//  ZPJSONHighlightColor.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "ZPJSONHighlightColor.h"

JSONHighlightColorKey const keyWord = @"keyWord";
JSONHighlightColorKey const key = @"key";
JSONHighlightColorKey const alink = @"alink";
JSONHighlightColorKey const string = @"string";
JSONHighlightColorKey const number = @"number";
JSONHighlightColorKey const boolean = @"boolean";
JSONHighlightColorKey const null = @"null";
JSONHighlightColorKey const unknownText = @"unknownText";
JSONHighlightColorKey const unknownBackground = @"unknownBackground";
JSONHighlightColorKey const jsonBackground = @"jsonBackground";
JSONHighlightColorKey const lineBackground = @"lineBackground";
JSONHighlightColorKey const lineText = @"lineText";
JSONHighlightColorKey const errorText = @"errorText";

@implementation ZPJSONHighlightColor

+ (instancetype)defaultHighlightColor
{
    ZPJSONHighlightColor *colorConfig = [[ZPJSONHighlightColor alloc] init];
    
    return colorConfig;
}

- (UIColor *)colorKey:(JSONHighlightColorKey)key
{
    NSString *colorHex = [self.defaultHighlightColor objectForKey:key];
    if (!colorHex || ![colorHex isKindOfClass:NSString.class] || colorHex.length <= 0) {
        colorHex = @"#333333";
    }
    return [self colorWithHexString:colorHex alpha:1.0];
}

- (NSDictionary <JSONHighlightColorKey, NSString *> *)defaultHighlightColor
{
    return @{
        keyWord : @"#333333",
        key : @"#B72E22",
        alink : @"#1E4A9C",
        string : @"#2D694C",
        number : @"#CC9115",
        boolean : @"#72AAD3",
        null : @"#EA2E22",
        unknownText : @"#D5412E",
        unknownBackground : @"#FBE3E4",
        jsonBackground : @"#FFFFFF",
        lineBackground : @"#EDEDED",
        lineText : @"#A3A3A3",
        errorText : @"#FF3329"
    };
}

- (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0x"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] < 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

@end
