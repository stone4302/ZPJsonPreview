//
//  ZPJSONException.h
//  ZPAlexProject
//
//  Created by Alex on 2023/12/7.
//

#import <Foundation/Foundation.h>
#import "ZPJSONValue.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZPJSONExceptionType) {
    unexpectedEndOfFile,
    unexpectedCharacter,
    unescapedControlCharacterInString,
    tooManyNestedArraysOrDictionaries,
    invalidHexDigitSequence,
    numberWithLeadingZero,
    unexpectedEscapedCharacter,
    expectedLowSurrogateUTF8SequenceAfterHighSurrogate,
    couldNotCreateUnicodeScalarFromUInt32,
    /// 转义序列异常
    unexpectedEscapedCharacter_Sequence,
    expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence,
    couldNotCreateUnicodeScalarFromUInt32_Sequence
};

@interface ZPJSONException : NSException

/// 是否向上传递
@property (nonatomic, assign) BOOL isHandUp;

@property (nonatomic, assign) ZPJSONExceptionType type;

@property (nonatomic, strong) ZPJSONValue *jsonValue;
@property (nonatomic, assign) uint8_t ascii;
@property (nonatomic, assign) NSUInteger characterIndex;

@property (nonatomic, copy) NSString *inString;
@property (nonatomic, copy) NSString *hexString;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, assign) uint32_t unicodeValue;

+ (instancetype)unexpectedEndOfFile;

+ (instancetype)unexpectedCharacter:(ZPJSONValue * __nullable)jsonValue ascii:(uint8_t)ascii characterIndex:(NSUInteger)characterIndex;

+ (instancetype)unescapedControlCharacterInString:(uint8_t)ascii inString:(NSString *)inString index:(NSUInteger)index;

+ (instancetype)tooManyNestedArraysOrDictionaries:(NSUInteger)characterIndex;

+ (instancetype)invalidHexDigitSequence:(NSString *)hexString index:(NSUInteger)index;

+ (instancetype)numberWithLeadingZero:(NSUInteger)index;

+ (instancetype)unexpectedEscapedCharacter:(uint8_t)ascii inString:(NSString *)inString index:(NSUInteger)index;

+ (instancetype)expectedLowSurrogateUTF8SequenceAfterHighSurrogate:(NSString *)inString index:(NSUInteger)index;

+ (instancetype)couldNotCreateUnicodeScalarFromUInt32:(NSString *)inString index:(NSUInteger)index unicodeValue:(uint32_t)unicodeValue;

#pragma mark - 转义序列异常

+ (instancetype)unexpectedEscapedCharacter_Sequence:(uint8_t)ascii index:(NSUInteger)index;

+ (instancetype)expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence:(NSUInteger)index;

+ (instancetype)couldNotCreateUnicodeScalarFromUInt32_Sequence:(NSUInteger)index unicodeValue:(uint32_t)unicodeValue;

#pragma mark - 对象方法

- (ZPJSONValue *)unknownJsonValue;

@end

NS_ASSUME_NONNULL_END
