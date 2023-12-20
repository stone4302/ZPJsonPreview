//
//  ZPJSONParser.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/27.
//

#import "ZPJSONParser.h"
#import "ZPJSONException.h"
#import "NSString+ZPJSONObjectKey.h"
#import "NSMutableDictionary+ZPJsonSort.h"

@implementation ZPJSONParser

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _reader = [[ZPJSONDocumentReader alloc] initWithData:data];
    }
    return self;
}

- (ZPJSONValue *)try_parse
{
    @try {
        [self.reader try_consumeWhitespace];
        ZPJSONValue *value = [self try_parseValue];
        
        // ensure only white space is remaining
        NSUInteger whitespace = 0;
        while ([self.reader peekWithOffset:whitespace]) {
            uint8_t next = [self.reader peekWithOffset:whitespace];
            if (next == kJson_space ||
                next == kJson_return ||
                next == kJson_newline ||
                next == kJson_tab) {
                whitespace += 1;
                continue;
            }
            else {
                @throw [ZPJSONException unexpectedCharacter:value ascii:next characterIndex:self.reader.readerIndex + whitespace];
            }
        }
        
        return value;
        
    } @catch (ZPJSONException *exception) {
        if (exception.type == unexpectedCharacter) {
            ZPJSONValue *jsonValue = exception.jsonValue;
            if (!jsonValue || ![jsonValue isKindOfClass:ZPJSONValue.class]) {
                return [ZPJSONValue unknownJsonValue:[self.reader readUnknown:exception.characterIndex]];
            }
            
            ZPJSONValueClass valueClass = jsonValue.valueClass;
            if (valueClass == zp_null ||
                valueClass == zp_number ||
                valueClass == zp_string ||
                valueClass == zp_bool) {
                NSString *wrongString = [self.reader readUnknown:exception.characterIndex];
                [jsonValue appendWrong:wrongString];
                return jsonValue;
            }
            else if (valueClass == zp_array) {
                NSMutableArray *array = jsonValue.arrayValue.mutableCopy;
                ZPJSONValue *last = [array lastObject];
                if (!last || ![last isKindOfClass:ZPJSONValue.class]) {
                    return jsonValue;
                }
                //移除最后一个
                [array removeObject:last];
                NSString *wrongString = [self.reader readUnknown:exception.characterIndex];
                [last appendWrong:wrongString];
                [array addObject:last];
                return [ZPJSONValue arrayJsonValue:array];
            }
            else if (valueClass == zp_object ||
                     valueClass == zp_unknown) {
                return jsonValue;
            }
        } else {
            // 其他异常
            return [exception unknownJsonValue];
        }
    } @finally {
        
    }
}

uint8_t _UInt8(NSString *ascii) {
    NSData *data = [ascii dataUsingEncoding:NSUTF8StringEncoding];
    return ((uint8_t *)data.bytes)[0];
}



#pragma mark - private parse

- (ZPJSONValue *)try_parseValue
{
    NSUInteger whitespace = 0;
    while ([self.reader peekWithOffset:whitespace]) {
        uint8_t byte = [self.reader peekWithOffset:whitespace];
        switch (byte) {
            case '\"':
            {
                [self.reader moveReaderIndex:whitespace];
                return [ZPJSONValue stringJsonValue:[self.reader try_readString]];
            }
            case '{':
            {
                [self.reader moveReaderIndex:whitespace];
                NSDictionary *object = [self try_parseObject];
                return [ZPJSONValue objectJsonValue:object];
            }
            case '[':
            {
                [self.reader moveReaderIndex:whitespace];
                NSArray *array = [self try_parseArray];
                return [ZPJSONValue arrayJsonValue:array];
            }
            case 'f':
            case 't':
            {
                [self.reader moveReaderIndex:whitespace];
                BOOL bl = [self.reader try_readBool];
                return [ZPJSONValue boolJsonValue:bl];
            }
            case 'n':
            {
                [self.reader moveReaderIndex:whitespace];
                [self.reader try_readNull];
                return [ZPJSONValue nullJsonValue];
            }
            case '-':
            case '0'...'9':
            {
                [self.reader moveReaderIndex:whitespace];
                NSString *number = [self.reader try_readNumber];
                return [ZPJSONValue numberJsonValue:number];
            }
            case ' ':
            case '\r':
            case '\n':
            case '\t':
            {
                whitespace += 1;
                continue;
            }
            default:
                @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.reader.readerIndex];
        }
    }
    @throw [ZPJSONException unexpectedEndOfFile];
}

- (NSArray <ZPJSONValue *> *)try_parseArray
{
    uint8_t readByte = [self.reader read];
    NSAssert(readByte == kJson_openbracket, @"readByte must be '['");
    if (readByte != kJson_openbracket) {
        return nil;
    }
    
    @try {
        if (self.depth >= 512) {
            @throw [ZPJSONException tooManyNestedArraysOrDictionaries:self.reader.readerIndex - 1];
        }
        
        self.depth += 1;
        // parse first value or end immediatly
        uint8_t byte = [self.reader try_consumeWhitespace];
        if (byte == kJson_space ||
            byte == kJson_return ||
            byte == kJson_newline ||
            byte == kJson_tab) {
            NSAssert(false, @"Expected that all white space is consumed");
        }
        else if (byte == kJson_closebracket) {
            [self.reader moveReaderIndex:1];
            return @[];
        }
        
        NSMutableArray <ZPJSONValue *> *array = [NSMutableArray arrayWithCapacity:10];
        
        // parse values
        while (true) {
            ZPJSONValue *value = [self try_parseValue];
            if (value) {
                [array addObject:value];
            }
            // consume the whitespace after the value before the comma
            uint8_t byte = [self.reader try_consumeWhitespace];
            if (byte == kJson_space ||
                byte == kJson_return ||
                byte == kJson_newline ||
                byte == kJson_tab) {
                NSAssert(false, @"Expected that all white space is consumed");
            }
            else if (byte == kJson_closebracket) {
                [self.reader moveReaderIndex:1];
                return array.copy;
            }
            else if (byte == kJson_comma) {
                // consume the comma
                [self.reader moveReaderIndex:1];
                // consume the whitespace before the next value
                if ([self.reader try_consumeWhitespace] == kJson_closebracket) {
                    // the foundation json implementation does support trailing commas
                    [self.reader moveReaderIndex:1];
                    return array.copy;
                }
                continue;
            }
            else {
                @throw [ZPJSONException unexpectedCharacter:[ZPJSONValue arrayJsonValue:array] ascii:byte characterIndex:self.reader.readerIndex];
            }
        }
        
    } @catch (ZPJSONException *exception) {
        @throw exception;
    } @finally {
        self.depth -= 1;
    }
}

- (NSDictionary <NSString *, ZPJSONValue *> *)try_parseObject
{
    uint8_t readByte = [self.reader read];
    NSAssert(readByte == kJson_openbrace, @"readByte must be '{'");
    if (readByte != kJson_openbrace) {
        return nil;
    }
    
    @try {
        if (self.depth >= 512) {
            @throw [ZPJSONException tooManyNestedArraysOrDictionaries:self.reader.readerIndex - 1];
        }
        
        self.depth += 1;
        // parse first value or end immediatly
        uint8_t byte = [self.reader try_consumeWhitespace];
        if (byte == kJson_space ||
            byte == kJson_return ||
            byte == kJson_newline ||
            byte == kJson_tab) {
            NSAssert(false, @"Expected that all white space is consumed");
        }
        else if (byte == kJson_closebrace) {
            [self.reader moveReaderIndex:1];
            return @{};
        }
        
        NSMutableDictionary <NSString *, ZPJSONValue *> *object = [NSMutableDictionary dictionaryWithCapacity:20];
        
        while (true) {
            NSString *key = nil;
            
            @try {
                key = [self.reader try_readString];
            } @catch (ZPJSONException *exception) {
                if (exception.type == unexpectedCharacter) {
                    key.zp_json_isWrong = YES;
                    ZPJSONValue *value = [ZPJSONValue unknownJsonValue:[self.reader readUnknown:exception.characterIndex]];
                    [object zpjson_setObject:value forKey:key];
                    return object;
                }
                else {
                    @throw exception;
                }
            }
            
            /// 检查冒号
            uint8_t colon = [self.reader try_consumeWhitespace];
            if (colon != ':') {
                NSUInteger characterIndex = self.reader.readerIndex;
                NSString *readUnknown = [self.reader readUnknown:characterIndex];
                ZPJSONValue *value = [ZPJSONValue unknownJsonValue:readUnknown];
                [object zpjson_setObject:value forKey:key];
                
                @throw [ZPJSONException unexpectedCharacter:[ZPJSONValue objectJsonValue:object] ascii:colon characterIndex:characterIndex];
            }
            
            [self.reader moveReaderIndex:1];
            [self.reader try_consumeWhitespace];
            
            @try {
                
                ZPJSONValue *value = [self try_parseValue];
                [object zpjson_setObject:value forKey:key];
                
                uint8_t commaOrBrace = [self.reader try_consumeWhitespace];
                if (commaOrBrace == kJson_closebrace) {
                    [self.reader moveReaderIndex:1];
                    return object;
                }
                else if (commaOrBrace == kJson_comma) {
                    [self.reader moveReaderIndex:1];
                    if ([self.reader try_consumeWhitespace] == kJson_closebrace) {
                        // the foundation json implementation does support trailing commas
                        [self.reader moveReaderIndex:1];
                        return object;
                    }
                    continue;
                }
                else {
                    NSUInteger characterIndex = self.reader.readerIndex;
                    key.zp_json_isWrong = YES;
                    NSString *readUnknown = [self.reader readUnknown:characterIndex];
                    ZPJSONValue *value = [ZPJSONValue unknownJsonValue:readUnknown];
                    [object zpjson_setObject:value forKey:key];
                    
                    @throw [ZPJSONException unexpectedCharacter:[ZPJSONValue objectJsonValue:object] ascii:commaOrBrace characterIndex:characterIndex];
                }
                
            } @catch (ZPJSONException *exception) {
                /// In the scenario of nested container elements, if the value itself is
                /// incorrectly formatted, it should be handled as an "error rendering".
                ///
                /// However, this kind of processing is currently missing,
                /// and a good way to implement this logic has not been thought of yet.
                ///
                /// For example, if the value of an object is an array or an object,
                /// and there is a missing `]` (array) or `}` (object), then this problem will occur.
                ///
                /// ```json
                /// {
                ///     "key": [
                ///         "123"
                ///     // Missing `]`, which will cause some json content to be missing when rendering.
                /// }
                /// ```
                if (exception.type == unexpectedCharacter) {
                    ZPJSONValue *_jsonValue = exception.jsonValue;
                    if (_jsonValue == nil) {
                        // There is only one possibility to have no value
                        NSString *readUnknown = [self.reader readUnknown:exception.characterIndex - 2];
                        ZPJSONValue *value = [ZPJSONValue unknownJsonValue:readUnknown];
                        [object zpjson_setObject:value forKey:key];
                        
                        _jsonValue = [ZPJSONValue objectJsonValue:object];
                    }
                    @throw [ZPJSONException unexpectedCharacter:_jsonValue ascii:exception.ascii characterIndex:exception.characterIndex];
                }
                else {
                    @throw exception;
                }
            }
        }
    } @finally {
        self.depth -= 1;
    }
}

@end
