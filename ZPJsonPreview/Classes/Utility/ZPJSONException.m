//
//  ZPJSONException.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/7.
//

#import "ZPJSONException.h"

static NSString * const kZPJSONExceptionName = @"com.json.exception";

static NSString * const kZPJSONExceptionReason = @"custom reason";

@implementation ZPJSONException

+ (instancetype)unexpectedEndOfFile
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = unexpectedEndOfFile;
    return exception;
}

+ (instancetype)unexpectedCharacter:(ZPJSONValue *)jsonValue ascii:(uint8_t)ascii characterIndex:(NSUInteger)characterIndex
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = unexpectedCharacter;
    exception.jsonValue = jsonValue;
    exception.ascii = ascii;
    exception.characterIndex = characterIndex;
    return exception;
}

+ (instancetype)unescapedControlCharacterInString:(uint8_t)ascii inString:(NSString *)inString index:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = unescapedControlCharacterInString;
    exception.ascii = ascii;
    exception.inString = inString;
    exception.index = index;
    return exception;
}

+ (instancetype)tooManyNestedArraysOrDictionaries:(NSUInteger)characterIndex
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = tooManyNestedArraysOrDictionaries;
    exception.characterIndex = characterIndex;
    return exception;
}

+ (instancetype)invalidHexDigitSequence:(NSString *)hexString index:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = invalidHexDigitSequence;
    exception.hexString = hexString;
    exception.index = index;
    return exception;
}

+ (instancetype)numberWithLeadingZero:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = numberWithLeadingZero;
    exception.index = index;
    return exception;
}

+ (instancetype)unexpectedEscapedCharacter:(uint8_t)ascii inString:(NSString *)inString index:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = unexpectedEscapedCharacter;
    exception.ascii = ascii;
    exception.inString = inString;
    exception.index = index;
    return exception;
}

+ (instancetype)expectedLowSurrogateUTF8SequenceAfterHighSurrogate:(NSString *)inString index:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = expectedLowSurrogateUTF8SequenceAfterHighSurrogate;
    exception.inString = inString;
    exception.index = index;
    return exception;
}

+ (instancetype)couldNotCreateUnicodeScalarFromUInt32:(NSString *)inString index:(NSUInteger)index unicodeValue:(uint32_t)unicodeValue
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = couldNotCreateUnicodeScalarFromUInt32;
    exception.inString = inString;
    exception.index = index;
    exception.unicodeValue = unicodeValue;
    return exception;
}

#pragma mark - 转义序列异常

+ (instancetype)unexpectedEscapedCharacter_Sequence:(uint8_t)ascii index:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = unexpectedEscapedCharacter_Sequence;
    exception.ascii = ascii;
    exception.index = index;
    return exception;
}

+ (instancetype)expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence:(NSUInteger)index
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence;
    exception.index = index;
    return exception;
}

+ (instancetype)couldNotCreateUnicodeScalarFromUInt32_Sequence:(NSUInteger)index unicodeValue:(uint32_t)unicodeValue
{
    ZPJSONException *exception = [[ZPJSONException alloc] initWithName:kZPJSONExceptionName reason:kZPJSONExceptionReason userInfo:nil];
    exception.type = couldNotCreateUnicodeScalarFromUInt32_Sequence;
    exception.index = index;
    exception.unicodeValue = unicodeValue;
    return exception;
}

#pragma mark - 对象方法

- (ZPJSONValue *)unknownJsonValue
{
    NSString *unknownValue = @"json结构解析异常";
    
    switch (self.type) {
        case unescapedControlCharacterInString:
        {
            unknownValue = [NSString stringWithFormat:@"json结构解析异常：异常index大概是%ld，异常字符为「 %@ 」", self.index, self.inString];
        }
            break;
            
        default:
            break;
    }
    
    ZPJSONValue *value = [ZPJSONValue unknownJsonValue:unknownValue];
    return value;
}

@end

