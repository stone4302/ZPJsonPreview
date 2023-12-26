//
//  ZPJSONDecorator.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "ZPJSONDecorator.h"
#import "NSDictionary+ZPJsonSort.h"
#import "NSString+ZPJsonValidURL.h"
#import "NSString+ZPJSONObjectKey.h"
#import "NSData+ZPJSONEncode.h"
#import "ZPJSONException.h"
#import "ZPJSONValue.h"
#import "ZPJSONSlice.h"
#import "ZPJSONParser.h"

typedef void(^ZPJSONAppendBlock)(NSMutableAttributedString *expand, NSMutableAttributedString *fold);

typedef NSMutableAttributedString *(^ZPJSONCKeyAttBlock)(NSString *key, BOOL isNeedColon);

NSString* Init1String(NSString *str1) {
    return [NSString stringWithFormat:@"%@",str1];
}

NSString* Init2String(NSString *str1, NSString *str2) {
    return [NSString stringWithFormat:@"%@%@",str1, str2];
}

NSString* Init3String(NSString *str1, NSString *str2, NSString *str3) {
    return [NSString stringWithFormat:@"%@%@%@",str1, str2, str3];
}

NSMutableAttributedString* AttributedString(NSString *string, ZPJsonStyleInfos attributes) {
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

@interface ZPJSONDecorator ()

/// Current number of indent
@property (nonatomic, assign) NSUInteger indent;

@property (nonatomic, strong) ZPJSONHighlightStyle *style;
@property (nonatomic, strong) ZPJSONSlices slices;
@property (nonatomic, strong) ZPJSONError *error;

@end

@implementation ZPJSONDecorator

+ (instancetype)decoratorWithJson:(id)json
                            style:(ZPJSONHighlightStyle *)style
{
    return [self decoratorWithJson:json judgmentValid:YES style:style];
}

+ (instancetype)decoratorWithJson:(id)json
                    judgmentValid:(BOOL)judgmentValid
                            style:(ZPJSONHighlightStyle *)style
{
    NSData *data = [NSData zpjson_dataWithJson:json];
    
    if (!data || ![data isKindOfClass:NSData.class]) {
        return [self decoratorWithError:nil];
    }
    
    if (judgmentValid) {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableContainers) error:&error];
        if (error || !jsonObject) {
            return [self decoratorWithError:error];
        }
    }
    
    ZPJSONDecorator *decorator = [[ZPJSONDecorator alloc] initWithStyle:style];
    decorator.slices = [decorator createSlicesFromData:data];
    return decorator;
}

+ (ZPJSONDecorator *)decoratorWithError:(NSError *)error
{
    if (!error || ![error isKindOfClass:NSError.class]) {
        error = [NSError errorWithDomain:@"com.json.decorator" code:-1 userInfo:@{
            NSLocalizedDescriptionKey : @"解析的json文件错误"
        }];
    }
    
    ZPJSONDecorator *decorator = [[ZPJSONDecorator alloc] initWithStyle:[ZPJSONHighlightStyle new]];
    decorator.error = [ZPJSONError jsonError:error];
    return decorator;
}

- (instancetype)initWithStyle:(ZPJSONHighlightStyle *)style
{
    self = [super init];
    if (self) {
        _indent = 0;
        _style = style;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indent = 0;
    }
    return self;
}

- (ZPJSONSlices)createSlicesFromData:(NSData *)data
{
    ZPJSONValue *jsonValue = [self createJSONValueFromData:data];
    return [self createJSONSlices:jsonValue];
}

- (ZPJSONValue *)createJSONValueFromData:(NSData *)data
{
    ZPJSONValue *jsonValue = nil;
    
    @try {
        ZPJSONParser *parser = [[ZPJSONParser alloc] initWithData:data];
        jsonValue = [parser try_parse];
        
    } @catch (ZPJSONException *exception) {
        if ([exception isKindOfClass:ZPJSONException.class]) {
            self.error = [ZPJSONError jsonErrorWithException:exception];
        }
    } @finally {
        return jsonValue;
    }
}

- (ZPJSONSlices)createJSONSlices:(ZPJSONValue *)jsonValue
{
    ZPJSONSlices slices = [self processJSONValueRecursively:jsonValue currentSlicesCount:0 isNeedIndent:NO isNeedComma:NO];
    return slices;
}

#pragma mark - 递归处理JSON值

- (ZPJSONSlices)processJSONValueRecursively:(ZPJSONValue *)jsonValue
              currentSlicesCount:(NSInteger)currentSlicesCount
                    isNeedIndent:(BOOL)isNeedIndent
                     isNeedComma:(BOOL)isNeedComma
{
    if (!jsonValue || ![jsonValue isKindOfClass:ZPJSONValue.class]) {
        return @[];
    }
    
    __block ZPJSONMutSlices resultArray = [NSMutableArray array];
    
    ZPJSONAppendBlock _append = ^(NSMutableAttributedString *expand, NSMutableAttributedString *fold){
        ZPJSONSlice *slice = [[ZPJSONSlice alloc] initWithLevel:self.indent expand:expand folded:fold];
        [resultArray addObject:slice];
    };
    
    switch ([jsonValue valueClass]) {
        // MARK: array
        case zp_array:
        {
            ZPJsonArrayAttribute startAttribute = [self createArrayStartAttribute:isNeedIndent isNeedComma:isNeedComma];
            
            NSMutableAttributedString *startExpand = [startAttribute firstObject];
            NSMutableAttributedString *startFold = [startAttribute lastObject];
            
            _append(startExpand, startFold);
            
            dispatch_block_t _appendArrayEnd = ^{
                NSMutableAttributedString *endExpand = [self createArrayEndAttribute:isNeedComma];
                _append(endExpand, nil);
            };
            
            NSUInteger arrCount = [jsonValue.arrayValue count];
            if (arrCount <= 0) {
                // If the array is empty, add the end flag directly.
                _appendArrayEnd();
                return resultArray.copy;
            }
            
            [self incIndent];
            
            // Process each value
            for (int i=0; i<arrCount; i++) {
                id value = [jsonValue.arrayValue objectAtIndex:i];
                BOOL _isNeedComma = i != (arrCount - 1);
                ZPJSONSlices slices = [self processJSONValueRecursively:value currentSlicesCount:currentSlicesCount + resultArray.count isNeedIndent:YES isNeedComma:_isNeedComma];
                [resultArray addObjectsFromArray:slices];
            }
            
            [self decIndent];
            
            // The end node is added only if the array is correct.
            ZPJSONValue *lastValue = [jsonValue.arrayValue lastObject];
            if ([lastValue isRight]) {
                _appendArrayEnd();
            }
            return resultArray.copy;
        }
        // MARK: object
        case zp_object:
        {
            ZPJsonArrayAttribute startAttribute = [self createObjectStartAttribute:isNeedIndent isNeedComma:isNeedComma];
            
            NSMutableAttributedString *startExpand = [startAttribute firstObject];
            NSMutableAttributedString *startFold = [startAttribute lastObject];
            
            _append(startExpand, startFold);
            
            dispatch_block_t _appendObjectEnd = ^{
                NSMutableAttributedString *endExpand = [self createObjectEndAttribute:isNeedComma];
                _append(endExpand, nil);
            };
            
            NSUInteger objectCount = [jsonValue.objectValue count];
            if (objectCount <= 0) {
                // If the object is empty, add the end flag directly.
                _appendObjectEnd();
                return resultArray.copy;
            }
            
            // Sorting the key.
            // The order of displaying each time the bail is taken is consistent.
            ZPJSONUnknownKeys sortKeys = [jsonValue.objectValue zpjson_rankingUnknownKeyLast];
            
            [self incIndent];
            
            // Process each value
            NSUInteger sortKeysCount = sortKeys.count;
            for (int i=0; i<sortKeysCount; i++) {
                NSString *objectKey = [sortKeys objectAtIndex:i];
                ZPJSONValue *value = [jsonValue.objectValue objectForKey:objectKey];
                if (!value || ![value isKindOfClass:ZPJSONValue.class]) {
                    continue;
                }
                
                ZPJSONCKeyAttBlock _createKeyAttribute = ^(NSString *key, BOOL isNeedColon) {
                    NSMutableAttributedString *keyAttribute = AttributedString(key, [self keyStyle]);
                    if (isNeedColon) {
                        [keyAttribute appendAttributedString:[self colonAttributeString]];
                    }
                    return keyAttribute;
                };
                
                // Different treatment according to different situations
                if ([value isRight] == valueState_wrong) {
                    ZPJSONSlices slices = [self processJSONValueRecursively:value currentSlicesCount:currentSlicesCount + resultArray.count isNeedIndent:YES isNeedComma:NO];
                    if (objectKey.zp_json_isWrong) {
                        [resultArray addObjectsFromArray:slices];
                    } else {
                        NSString *string = Init2String([self writeIndent], Init3String(@"\"", objectKey, @"\""));
                        NSMutableAttributedString *expand = _createKeyAttribute(string, NO);
                        
                        ZPJSONSlice *firstSlice = [slices firstObject];
                        if (firstSlice && [firstSlice isKindOfClass:ZPJSONSlice.class]) {
                            [expand appendAttributedString:firstSlice.expand];
                        }
                        
                        _append(expand, nil);
                    }
                }
                else if ([value isRight] == valueState_right_true || [value isRight] == valueState_right_false) {
                    NSString *string = Init2String([self writeIndent], Init3String(@"\"", objectKey, @"\""));
                    
                    BOOL nextIsRight = NO;
                    if (i < sortKeys.count - 1) {
                        ZPJSONValue *nextValue = [jsonValue.objectValue objectForKey:[sortKeys objectAtIndex:i + 1]];
                        if ([nextValue isRight] == valueState_right_true || [nextValue isRight] == valueState_right_false) {
                            nextIsRight = YES;
                        }
                    }
                    /// 不是最后一个&&下一个isRight=right就需要逗号
                    BOOL _isNeedComma = (i != (objectCount - 1)) && nextIsRight;
                    
                    NSMutableAttributedString *expand = _createKeyAttribute(string, true);
                    
                    BOOL isContainer = [value isRight] == valueState_right_true;
                    if (isContainer) {
                        NSMutableAttributedString *fold = _createKeyAttribute(string, true);
                        // Get the content of the subvalue
                        ZPJSONMutSlices slices = [self processJSONValueRecursively:value currentSlicesCount:currentSlicesCount + resultArray.count isNeedIndent:false isNeedComma:_isNeedComma].mutableCopy;
                        if (slices.count > 0) {
                            ZPJSONSlice *startSlice = [slices firstObject];
                            [slices removeObject:startSlice];
                            
                            [expand appendAttributedString:startSlice.expand];
                            NSMutableAttributedString *valueFold = startSlice.folded;
                            if (valueFold) {
                                [fold appendAttributedString:valueFold];
                            }
                            
                            _append(expand, fold);
                        }
                        [resultArray addObjectsFromArray:slices];
                    }
                    else {
                        NSMutableAttributedString *fold = nil;
                        // Get the content of the subvalue
                        NSArray *slices = [self processJSONValueRecursively:value currentSlicesCount:0 isNeedIndent:false isNeedComma:_isNeedComma];
                        // Usually there is only one value for `slices` in this case,
                        // so only the first value is taken
                        ZPJSONSlice *slice = [slices firstObject];
                        if (slice) {
                            [expand appendAttributedString:slice.expand];
                            NSMutableAttributedString *valueFold = slice.folded;
                            if (valueFold) {
                                fold = _createKeyAttribute(string, true);
                                if (fold) {
                                    [fold appendAttributedString:valueFold];
                                }
                            }
                            
                            _append(expand, fold);
                        }
                    }
                }
            }
            
            [self decIndent];
            
            // The end node is added only if the object is correct.
            NSString *lastKey = [sortKeys lastObject];
            ZPJSONValue *lastJsonValue = [jsonValue.objectValue objectForKey:lastKey];
            if ([lastJsonValue isKindOfClass:ZPJSONValue.class] && [lastJsonValue isRight]) {
                _appendObjectEnd();
            }
            return resultArray.copy;
        }
        // MARK: string
        case zp_string:
        {
            NSString *indent = isNeedIndent ? [self writeIndent] : @"";
            NSString *string = Init2String(indent, Init3String(@"\"", jsonValue.stringValue, @"\""));
            NSMutableAttributedString *expand = [NSMutableAttributedString new];
            ZPJSONValidURL *url = [jsonValue.stringValue zp_json_validURL];
            if (url) {
                expand = AttributedString(string, [self linkStyle]);
                NSString *urlString = url.urlString;
                NSRange range = NSMakeRange(indent.length + 1, urlString.length);
                [expand addAttribute:NSLinkAttributeName value:urlString range:range];
                [expand addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
            } else {
                expand = AttributedString(string, [self stringStyle]);
            }
            
            if (isNeedComma) {
                [expand appendAttributedString:[self commaAttributeString]];
            }
            
            if (jsonValue.wrong) {
                [expand appendAttributedString:[self createUnknownAttributedString:jsonValue.wrong]];
            }
            
            _append(expand, nil);
            return resultArray.copy;
        }
        // MARK: number
        case zp_number:
        {
            NSString *indent = isNeedIndent ? [self writeIndent] : @"";
            NSString *string = Init2String(indent, jsonValue.numberValue);
            NSMutableAttributedString *expand = AttributedString(string, [self numberStyle]);
            
            if (isNeedComma) {
                [expand appendAttributedString:[self commaAttributeString]];
            }
            
            if (jsonValue.wrong) {
                [expand appendAttributedString:[self createUnknownAttributedString:jsonValue.wrong]];
            }
            
            _append(expand, nil);
            return resultArray;
        }
        // MARK: bool
        case zp_bool:
        {
            NSString *indent = isNeedIndent ? [self writeIndent] : @"";
            NSString *string = Init2String(indent, jsonValue.boolValue == YES ? @"true" : @"false");
            NSMutableAttributedString *expand = AttributedString(string, [self boolStyle]);
            
            if (isNeedComma) {
                [expand appendAttributedString:[self commaAttributeString]];
            }
            
            if (jsonValue.wrong) {
                [expand appendAttributedString:[self createUnknownAttributedString:jsonValue.wrong]];
            }
            
            _append(expand, nil);
            return resultArray;
        }
        // MARK: null
        case zp_null:
        {
            NSString *indent = isNeedIndent ? [self writeIndent] : @"";
            NSString *string = Init2String(indent, @"null");
            NSMutableAttributedString *expand = AttributedString(string, [self nullStyle]);
            
            if (isNeedComma) {
                [expand appendAttributedString:[self commaAttributeString]];
            }
            
            if (jsonValue.wrong) {
                [expand appendAttributedString:[self createUnknownAttributedString:jsonValue.wrong]];
            }
            
            _append(expand, nil);
            return resultArray;
        }
        // MARK: unknown
        case zp_unknown:
        {
            NSString *indent = isNeedIndent ? [self writeIndent] : @"";
            NSMutableAttributedString *expand = AttributedString(indent, [self unknownStyle]);
            [expand appendAttributedString:[self createUnknownAttributedString:jsonValue.unknownValue]];
            _append(expand, nil);
            return resultArray;
        }
        default:
            break;
    }
    
    return resultArray.copy;
}

#pragma mark - public

- (NSMutableAttributedString *)wrapString
{
    return AttributedString(@"\n", [self createStyle:nil other:nil]);
}

- (BOOL)isExpandOrFoldString:(NSString *)string
{
    if (!string || ![string isKindOfClass:NSString.class]) {
        return NO;
    }
    if ([string isEqualToString:self.expandIconString.string]) {
        return YES;
    }
    if ([string isEqualToString:self.foldIconString.string]) {
        return YES;
    }
    return NO;
}

#pragma mark - Indent

// Fixed value of the number of contractions per increase or decrease(每次增加或减少收缩次数的固定值)

static NSUInteger const kZPIndentAmount = 1;

/// 加
- (void)incIndent
{
    self.indent += kZPIndentAmount;
}

/// 减
- (void)decIndent
{
    self.indent -= kZPIndentAmount;
}

/// 返回包含indent个制表符（tab）字符串
- (NSString *)writeIndent
{
    NSMutableString *writeIndent = [NSMutableString string];
    NSUInteger count = 0;
    while (count < self.indent) {
        [writeIndent appendString:@"\t"];
        count ++;
    }
    return writeIndent.copy;
}

#pragma mark - Attribute
/**
 * isNeedIndent : 需要缩进
 * isNeedComma : 需要逗号
 */

- (NSMutableAttributedString *)createUnknownAttributedString:(NSString *)string {
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return AttributedString(newString, [self unknownStyle]);
}

/// Create an attribute string of "array - start node"
- (ZPJsonArrayAttribute)createArrayStartAttribute:(BOOL)isNeedIndent isNeedComma:(BOOL)isNeedComma {
    return [self createStartAttribute:@"[" fold:@"[Array...]" isNeedIndent:isNeedIndent isNeedComma:isNeedComma];
}

/// Create an attribute string of "Array - End Node"
- (NSMutableAttributedString *)createArrayEndAttribute:(BOOL)isNeedComma
{
    return [self createEndAttribute:@"]" isNeedComma:isNeedComma];
}

/// Create an attribute string of "Object - Start Node"
- (ZPJsonArrayAttribute)createObjectStartAttribute:(BOOL)isNeedIndent isNeedComma:(BOOL)isNeedComma
{
    return [self createStartAttribute:@"{" fold:@"{Object...}" isNeedIndent:isNeedIndent isNeedComma:isNeedComma];
}

/// Create an attribute string of "object - end node"
- (NSMutableAttributedString *)createObjectEndAttribute:(BOOL)isNeedComma
{
    return [self createEndAttribute:@"}" isNeedComma:isNeedComma];
}

/// Create an attribute string of "keyword".
///
/// - Parameter key: keyword
/// - Returns: `AttributedString` object.
- (NSMutableAttributedString *)createKeywordAttribute:(NSString *)key
{
    return AttributedString(Init1String(key), [self keyWordStyle]);
}

/// Create an attribute string of "begin node".
///
/// - Parameters:
///   - expand: String when expand.
///   - fold: String when folded.
///   - isNeedIndent: Indentation required.
///   - isNeedComma: Comma required.
/// - Returns: `AttributedString` object.
- (ZPJsonArrayAttribute)createStartAttribute:(NSString *)expand fold:(NSString *)fold isNeedIndent:(BOOL)isNeedIndent isNeedComma:(BOOL)isNeedComma
{
    NSString *indent = isNeedIndent ? self.writeIndent : @"";
    
    NSMutableAttributedString *expandString = AttributedString(Init3String(indent, @" ", expand), [self startStyle]);
    
    NSMutableAttributedString *foldString = AttributedString(Init2String(fold, (isNeedComma ? @"," : @"")), [self placeholderStyle]);
    
    [foldString insertAttributedString:[self createKeywordAttribute:Init2String(indent, @" ")] atIndex:0];
    [expandString insertAttributedString:[self foldIconString] atIndex:indent.length];
    [foldString insertAttributedString:[self expandIconString] atIndex:indent.length];
    
    return @[expandString, foldString];
}

/// Create an attribute string of "end node".
///
/// - Parameters:
///   - key: Node characters, such as `}` or `]`.
///   - isNeedComma: Comma required.
/// - Returns: `AttributedString` object.
- (NSMutableAttributedString *)createEndAttribute:(NSString *)key isNeedComma:(BOOL)isNeedComma
{
    NSString *indent = [self writeIndent];
    
    NSString *string = Init2String(key, (isNeedComma ? @"," : @""));
    NSString *endString = Init2String(indent, string);
    
    return AttributedString(endString, [self startStyle]);
}

/// Create an `AttributedString` object for displaying image.
///
/// - Parameter image: The image to be displayed.
/// - Returns: `AttributedString` object.
- (NSMutableAttributedString *)createIconAttributedStringWithImage:(UIImage *)image
{
    NSTextAttachment *expandAttach = [[NSTextAttachment alloc] init];
    expandAttach.image = image;
    
    UIFont *font = self.style.jsonFont;
    CGFloat y = (self.style.lineHeight - font.lineHeight + 1) + font.descender;
    expandAttach.bounds = CGRectMake(0, y, font.ascender, font.ascender);
    
    return [NSAttributedString attributedStringWithAttachment:expandAttach].mutableCopy;
}

- (ZPJsonStyleInfos)createStyle:(UIColor *)foregroundColor other:(ZPJsonStyleInfos)other
{
    ZPJsonStyleInfos newStyle = [NSMutableDictionary dictionary];
    
    if ([self.style.jsonFont isKindOfClass:UIFont.class]) {
        [newStyle setObject:self.style.jsonFont forKey:NSFontAttributeName];
    }
    
    if ([foregroundColor isKindOfClass:UIColor.class]) {
        [newStyle setObject:foregroundColor forKey:NSForegroundColorAttributeName];
    }
    
    CGFloat lineHeightMultiple = 1;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (@available(iOS 15.0, *)) {
        paragraphStyle.usesDefaultHyphenation = NO;
    }
    paragraphStyle.lineHeightMultiple = lineHeightMultiple;
    paragraphStyle.maximumLineHeight = self.style.lineHeight;
    paragraphStyle.minimumLineHeight = self.style.lineHeight;
    paragraphStyle.lineSpacing = 0;
    
    [newStyle setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    CGFloat baselineOffset = (self.style.lineHeight - self.style.jsonFont.lineHeight) + 1;
    [newStyle setObject:@(baselineOffset) forKey:NSBaselineOffsetAttributeName];
    
    NSArray *otherKeys = other.allKeys;
    for (NSAttributedStringKey key in otherKeys) {
        id objc = [other objectForKey:key];
        if (objc) {
            [newStyle setObject:objc forKey:key];
        }
    }
    
    return newStyle;
}

#pragma mark - private Attribute String

- (NSMutableAttributedString *)foldIconString
{
    return [self createIconAttributedStringWithImage:self.style.foldIcon];
}

- (NSMutableAttributedString *)expandIconString
{
    return [self createIconAttributedStringWithImage:self.style.expandIcon];
}

/// An attribute string of ","
- (NSMutableAttributedString *)commaAttributeString
{
    return [self createKeywordAttribute:@","];
}

/// An attribute string of ":"
- (NSMutableAttributedString *)colonAttributeString
{
    return [self createKeywordAttribute:@" : "];
}

#pragma mark - private style
// NSMutableDictionary <NSAttributedStringKey, id>

#define zp_colorStyle(key) [self.style.color colorKey:key]

- (ZPJsonStyleInfos)startStyle
{
    return [self createStyle:zp_colorStyle(keyWord) other:nil];
}

- (ZPJsonStyleInfos)keyWordStyle
{
    return [self createStyle:zp_colorStyle(keyWord) other:nil];
}

- (ZPJsonStyleInfos)keyStyle
{
    return [self createStyle:zp_colorStyle(key) other:nil];
}

- (ZPJsonStyleInfos)linkStyle
{
    return [self createStyle:zp_colorStyle(alink) other:nil];
}

- (ZPJsonStyleInfos)stringStyle
{
    return [self createStyle:zp_colorStyle(string) other:nil];
}

- (ZPJsonStyleInfos)numberStyle
{
    return [self createStyle:zp_colorStyle(number) other:nil];
}

- (ZPJsonStyleInfos)boolStyle
{
    return [self createStyle:zp_colorStyle(boolean) other:nil];
}

- (ZPJsonStyleInfos)nullStyle
{
    return [self createStyle:zp_colorStyle(null) other:nil];
}

- (ZPJsonStyleInfos)placeholderStyle
{
    ZPJsonStyleInfos other = @{
        NSBackgroundColorAttributeName : zp_colorStyle(lineBackground)
    }.mutableCopy;
    return [self createStyle:zp_colorStyle(lineText) other:other];
}

- (ZPJsonStyleInfos)unknownStyle
{
    ZPJsonStyleInfos other = @{
        NSBackgroundColorAttributeName : zp_colorStyle(unknownBackground)
    }.mutableCopy;
    return [self createStyle:zp_colorStyle(unknownText) other:other];
}

@end
