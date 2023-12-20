//
//  ZPJSONDocumentReader.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/28.
//

#import "ZPJSONDocumentReader.h"
#import "ZPJSONException.h"

typedef NS_ENUM(NSUInteger, ZPJSONControlCharacter) {
    zpjson_operand, //操作数
    zpjson_decimalPoint, //小数点
    zpjson_exp, //输出
    zpjson_expOperator //输出运算符
};

@interface ZPJSONDocumentReader ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) NSUInteger readerIndex;

// array.count
@property (nonatomic, assign) NSUInteger dataLength;
@end

@implementation ZPJSONDocumentReader

static uint8_t * _dataBytes(NSData * data) {
    return (uint8_t *)data.bytes;
}

static uint8_t * _subDataBytes(NSData * data, NSUInteger start, NSUInteger end) {
    if (end <= start) {
        return nil;
    }
    NSRange range = NSMakeRange(start, end - start + 1);
    NSData *subData = [data subdataWithRange:range];
    return (uint8_t *)subData.bytes;
}

static NSData * _subData(NSData * data, NSUInteger start, NSUInteger end) {
    if (end < start) {
        return nil;
    }
    NSRange range = NSMakeRange(start, end - start + 1);
    NSData *subData = [data subdataWithRange:range];
    return subData;
}

static NSData * _suffixData(NSData * data, NSUInteger from) {
    NSUInteger dataLength = data.length;
    if (from > dataLength - 1) {
        return nil;
    }
    NSRange range = NSMakeRange(from, dataLength - from + 1);
    NSData *subData = [data subdataWithRange:range];
    return subData;
}

static NSString * _addString(NSString *str1, NSString *str2) {
    return [NSString stringWithFormat:@"%@%@", str1, str2];
}

static NSString * _dataToString(NSData *data, NSStringEncoding encoding) {
    return [[NSString alloc] initWithData:data encoding:(encoding)];
}

#pragma mark - 常量

static NSData * _true(void) {
    uint8_t bytes[] = {'t', 'r', 'u', 'e'};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

static NSData * _trueSub(void) {
    uint8_t bytes[] = {'r', 'u', 'e'};
    NSData *data = [NSData dataWithBytes:bytes length:3];
    return data;
}

static NSData * _false(void) {
    uint8_t bytes[] = {'f', 'a', 'l', 's', 'e'};
    NSData *data = [NSData dataWithBytes:bytes length:5];
    return data;
}

static NSData * _falseSub(void) {
    uint8_t bytes[] = {'a', 'l', 's', 'e'};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

static NSData * _null(void) {
    uint8_t bytes[] = {'n', 'u', 'l', 'l'};
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

#pragma mark - 实例、类方法

+ (uint8_t)hexAsciiTo4Bits:(uint8_t)ascii
{
    switch (ascii) {
        case 48 ... 57:
            return ascii - 48;
        case 65 ... 70:
            // uppercase letters
            return ascii - 55;
        case 97 ... 102:
            // lowercase letters
            return ascii - 87;
        default:
            return 0;
    }
}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        _data = data;
        
    }
    return self;
}

#pragma mark - public

- (BOOL)isEOF
{
    return self.readerIndex >= self.dataLength;
}

- (uint8_t)read
{
    if (self.readerIndex >= self.dataLength) {
        self.readerIndex = self.dataLength;
        return 0;
    }
    
    @try {
        return _dataBytes(self.data)[self.readerIndex];
    } @finally {
        self.readerIndex += 1;
    }
}

- (uint8_t)peekWithOffset:(NSUInteger)offset
{
    if (self.readerIndex + offset >= self.dataLength) {
        return 0;//NUL
    }
    return _dataBytes(self.data)[self.readerIndex + offset];
}

- (void)moveReaderIndex:(NSUInteger)offset
{
    self.readerIndex += offset;
}

/// 过滤空白字节
- (uint8_t)try_consumeWhitespace
{
    NSInteger whitespace = 0;
    
    while ([self peekWithOffset:whitespace]) {
        uint8_t ascii = [self peekWithOffset:whitespace];
        if (ascii == kJson_space ||
            ascii == kJson_return ||
            ascii == kJson_newline ||
            ascii == kJson_tab) {
            whitespace += 1;
            continue;
        } else {
            [self moveReaderIndex:whitespace];
            return ascii;
        }
    }
    
    @throw [ZPJSONException unexpectedEndOfFile];
}

- (NSString *)try_readString
{
    return [self try_readUTF8StringTillNextUnescapedQuote];
}

- (NSString *)try_readNumber
{
    return [self try_parseNumber];
}

- (BOOL)try_readBool
{
    uint8_t byte = [self read];
    switch (byte) {
        case 't':
        {
            [self try_readGenericValue:_trueSub()];
            return true;
        }
        case 'f':
        {
            [self try_readGenericValue:_falseSub()];
            return false;
        }
            
        default:
        {
            NSAssert(false, @"Expected to have `t` or `f` as first character");
            return false;
        }
    }
}

- (void)try_readNull
{
    [self try_readGenericValue:_null()];
}

- (NSString *)readUnknown:(NSUInteger)index
{
    index = MIN(index, MAX(self.dataLength, 1) - 1);
    NSString *string = _dataToString(_subData(self.data, index, self.dataLength - 1), NSUTF8StringEncoding);
    return string;
}

#pragma mark - private

- (NSString *)makeStringFast:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

- (void)try_readGenericValue:(NSData *)value
{
    uint8_t *bytes = (uint8_t *)value.bytes;
    for (int index = 0; index<value.length; index++) {
        uint8_t ascii = bytes[index];
        if ([self read] == ascii) {
            continue;
        }
        NSUInteger offset = MIN(2 + index, self.readerIndex);
        @throw [ZPJSONException unexpectedCharacter:nil ascii:[self peekWithOffset:-offset] characterIndex:self.readerIndex - offset];
    }
}
///读取UTF8字符串直到下一个转义符引用
- (NSString *)try_readUTF8StringTillNextUnescapedQuote
{
    uint8_t byte = [self read];
    if (byte != kJson_quote) {
        @throw [ZPJSONException unexpectedCharacter:nil ascii:[self peekWithOffset:-1] characterIndex:self.readerIndex - 1];
    }
    
    NSUInteger stringStartIndex = self.readerIndex;
    NSUInteger copy = 0;
    NSString *output = nil;
    
    while ([self peekWithOffset:copy]) {
        uint8_t byte = [self peekWithOffset:copy];
        switch (byte) {
            case '\"':
            {
                [self moveReaderIndex:copy + 1];
                NSString *result = output;
                NSString *copyString = _dataToString(_subData(self.data, stringStartIndex, stringStartIndex + copy - 1), NSUTF8StringEncoding);
                if (result == nil) {
                    // if we don't have an output string we create a new string
                    return copyString;
                }
                result = _addString(result, copyString);
                return result;
            }
            case 0 ... 31:
            {
                // All Unicode characters may be placed within the
                // quotation marks, except for the characters that must be escaped:
                // quotation mark, reverse solidus, and the control characters (U+0000
                // through U+001F).
                NSString *string = output ?: @"";
                NSUInteger errorIndex = self.readerIndex + copy;
                NSString *makeStringFast = [self makeStringFast:_subData(self.data, stringStartIndex, errorIndex)];
                string = _addString(string, makeStringFast);
                @throw [ZPJSONException unescapedControlCharacterInString:byte inString:string index:errorIndex];
                
            }
            case '\\':
            {
                [self moveReaderIndex:copy];
                if (output != nil) {
                    NSString *makeStringFast = [self makeStringFast:_subData(self.data, stringStartIndex, stringStartIndex + copy - 1)];
                    output = _addString(output, makeStringFast);
                } else {
                    output = [self makeStringFast:_subData(self.data, stringStartIndex, stringStartIndex + copy - 1)];
                }
                
                NSUInteger escapedStartIndex = self.readerIndex;
                
                @try {
                    NSString *escaped = [self try_parseEscapeSequence];
                    output = _addString(output, escaped);
                    stringStartIndex = self.readerIndex;
                    copy = 0;
                } @catch (ZPJSONException *exception) {
                    if (exception.type == unexpectedEscapedCharacter_Sequence) {
                        NSString *string = [self makeStringFast:_subData(self.data, escapedStartIndex, self.readerIndex - 1)];
                        output = _addString(output, string);
                        @throw [ZPJSONException unexpectedEscapedCharacter:exception.ascii inString:output index:exception.index];
                    }
                    else if (exception.type == expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence) {
                        NSString *string = [self makeStringFast:_subData(self.data, escapedStartIndex, self.readerIndex - 1)];
                        output = _addString(output, string);
                        @throw [ZPJSONException expectedLowSurrogateUTF8SequenceAfterHighSurrogate:output index:exception.index];
                    }
                    else if (exception.type == couldNotCreateUnicodeScalarFromUInt32_Sequence) {
                        NSString *string = [self makeStringFast:_subData(self.data, escapedStartIndex, self.readerIndex - 1)];
                        output = _addString(output, string);
                        @throw [ZPJSONException couldNotCreateUnicodeScalarFromUInt32:output index:exception.index unicodeValue:exception.unicodeValue];
                    }
                    else {
                        copy += 1;
                        continue;
                    }
                } @finally {
                    
                }
            }
            default:
                copy += 1;
                break;
        }
    }
    @throw [ZPJSONException unexpectedEndOfFile];
}

- (NSString *)try_parseEscapeSequence
{
    uint8_t byte = [self read];
    NSAssert(byte == kJson_backslash, @"Expected to have an backslash first");
    if (byte != kJson_backslash) {
        return nil;
    }
    if (byte == 0) {
        @throw [ZPJSONException unexpectedEndOfFile];
    }
    switch (byte) {
        case 0x22: return @"\"";
        case 0x5C: return @"\\";
        case 0x2F: return @"/";
        case 0x62: return @"\\u{08}"; // \b
        case 0x66: return @"\\u{0C}"; // \f
        case 0x6E: return @"\\u{0A}"; // \n
        case 0x72: return @"\\u{0D}"; // \r
        case 0x74: return @"\\u{09}"; // \t
        case 0x75:
        {
            NSString *character = [self try_parseUnicodeSequence];
            return character;
        }
        default:
            @throw [ZPJSONException unexpectedEscapedCharacter_Sequence:byte index:self.readerIndex - 1];
    }
}

- (NSString *)try_parseUnicodeSequence
{
    // we build this for utf8 only for now.
    uint16_t bitPattern = [self try_parseUnicodeHexSequence];
    
    /**
     如果两个相应位都为 1，则结果位为 1。
     否则，结果位为 0。
     */
    // check if high surrogate
    uint16_t isFirstByteHighSurrogate = bitPattern & 0xFC00; // nil everything except first six bits
    if (isFirstByteHighSurrogate == 0xD800) {
        // if we have a high surrogate we expect a low surrogate next
        uint16_t highSurrogateBitPattern = bitPattern;
        uint8_t escapeChar = [self read];
        uint8_t uChar = [self read];
        if (escapeChar <= 0 || uChar <= 0) {
            @throw [ZPJSONException unexpectedEndOfFile];
        }
        
        if (escapeChar != '\\' || uChar != 'u') {
            @throw [ZPJSONException expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence:self.readerIndex - 1];
        }
        
        uint16_t lowSurrogateBitBattern = [self try_parseUnicodeHexSequence];
        uint16_t isSecondByteLowSurrogate = lowSurrogateBitBattern & 0xFC00; // nil everything except first six bits
        if (isSecondByteLowSurrogate != 0xDC00) {
            // we are in an escaped sequence. for this reason an output string must have
            // been initialized
            @throw [ZPJSONException expectedLowSurrogateUTF8SequenceAfterHighSurrogate_Sequence:self.readerIndex - 1];
        }
        
        uint32_t highValue = (uint32_t)(highSurrogateBitPattern - 0xD800) * 0x400;
        uint32_t lowValue = (uint32_t)(lowSurrogateBitBattern - 0xDC00);
        uint32_t unicodeValue = highValue + lowValue + 0x10000;
        
        NSString *unicodeString = [NSString stringWithFormat:@"%C", (unichar)unicodeValue];
        if (!unicodeString || unicodeString.length <= 0) {
            @throw [ZPJSONException couldNotCreateUnicodeScalarFromUInt32_Sequence:self.readerIndex unicodeValue:unicodeValue];
        }
        return unicodeString;
    }
    
    NSString *unicode = [NSString stringWithFormat:@"%C", (unichar)bitPattern];
    if (!unicode || unicode.length <= 0) {
        @throw [ZPJSONException couldNotCreateUnicodeScalarFromUInt32_Sequence:self.readerIndex unicodeValue:(uint32_t)bitPattern];
    }
    return unicode;
}

- (uint16_t)try_parseUnicodeHexSequence
{
    // As stated in RFC-8259 an escaped unicode character is 4 HEXDIGITs long
    NSUInteger startIndex = self.readerIndex;
    uint8_t firstHex = [self read];
    uint8_t secondHex = [self read];
    uint8_t thirdHex = [self read];
    uint8_t forthHex = [self read];
    
    if (firstHex <= 0 ||
        secondHex <= 0 ||
        thirdHex <= 0 ||
        forthHex <= 0) {
        @throw [ZPJSONException unexpectedEndOfFile];
    }
    
    uint8_t first = [ZPJSONDocumentReader hexAsciiTo4Bits:firstHex];
    uint8_t second = [ZPJSONDocumentReader hexAsciiTo4Bits:secondHex];
    uint8_t third = [ZPJSONDocumentReader hexAsciiTo4Bits:thirdHex];
    uint8_t forth = [ZPJSONDocumentReader hexAsciiTo4Bits:forthHex];
    
    if (first <= 0 ||
        second <= 0 ||
        third <= 0 ||
        forth <= 0) {
        uint8_t bytes[] = {first, second, third, forth};
        NSData *data = [NSData dataWithBytes:bytes length:4];
        NSString *hexString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        @throw [ZPJSONException invalidHexDigitSequence:hexString index:startIndex];
    }
    
    uint16_t firstByte = (uint16_t)(first) << 4 | (uint16_t)(second);
    uint16_t secondByte = (uint16_t)(third) << 4 | (uint16_t)(forth);

    uint16_t bitPattern = (uint16_t)(firstByte) << 8 | (uint16_t)(secondByte);

    return bitPattern;
}

- (NSString *)try_parseNumber
{
    ZPJSONControlCharacter pastControlChar = zpjson_operand;
    NSUInteger numbersSinceControlChar = 0;
    BOOL hasLeadingZero = false;
    
    // parse first character
    uint8_t ascii = [self peekWithOffset:0];
    if (ascii <= 0) {
        NSAssert(false, @"Why was this function called, if there is no 0...9 or -");
        return nil;
    }
    
    switch (ascii) {
        case '0':
        {
            numbersSinceControlChar = 1;
            pastControlChar = zpjson_operand;
            hasLeadingZero = true;
        }
            break;
        case '1'...'9':
        {
            numbersSinceControlChar = 1;
            pastControlChar = zpjson_operand;
        }
            break;
        case '-':
        {
            numbersSinceControlChar = 0;
            pastControlChar = zpjson_operand;
        }
            break;
        default:
        {
            NSAssert(false, @"Why was this function called, if there is no 0...9 or -");
        }
            break;
    }
    
    NSUInteger numberchars = 1;
    
    // parse everything else
    while ([self peekWithOffset:numberchars]) {
        uint8_t byte = [self peekWithOffset:numberchars];
        switch (byte) {
            case '0':
            {
                if (hasLeadingZero) {
                    @throw [ZPJSONException numberWithLeadingZero:self.readerIndex + numberchars];
                }
                if (numbersSinceControlChar == 0 && pastControlChar == zpjson_operand) {
                    // the number started with a minus. this is the leading zero.
                    hasLeadingZero = true;
                }
                numberchars += 1;
                numbersSinceControlChar += 1;
            }
                break;
            case '1'...'9':
            {
                if (hasLeadingZero) {
                    @throw [ZPJSONException numberWithLeadingZero:self.readerIndex + numberchars];
                }
                numberchars += 1;
                numbersSinceControlChar += 1;
            }
                break;
            case '.':
            {
                if (numbersSinceControlChar <= 0 || pastControlChar != zpjson_operand) {
                    @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.readerIndex + numberchars];
                }
                numberchars += 1;
                hasLeadingZero = false;
                pastControlChar = zpjson_decimalPoint;
                numbersSinceControlChar = 0;
            }
                break;
            case 'e':
            case 'E':
            {
                if (numbersSinceControlChar <= 0 || (pastControlChar != zpjson_operand && pastControlChar != zpjson_decimalPoint)) {
                    @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.readerIndex + numberchars];
                }
                numberchars += 1;
                hasLeadingZero = false;
                pastControlChar = zpjson_exp;
                numbersSinceControlChar = 0;
            }
                break;
            case '+':
            case '-':
            {
                if (numbersSinceControlChar != 0 || pastControlChar != zpjson_exp) {
                    @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.readerIndex + numberchars];
                }
                numberchars += 1;
                pastControlChar = zpjson_expOperator;
                numbersSinceControlChar = 0;
            }
                break;
            case kJson_space:
            case kJson_return:
            case kJson_newline:
            case kJson_tab:
            case kJson_comma:
            case kJson_closebrace:
            case kJson_closebracket:
            {
                if (numbersSinceControlChar <= 0) {
                    @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.readerIndex + numberchars];
                }
                NSUInteger numberStartIndex = self.readerIndex;
                [self moveReaderIndex:numberchars];

                return [self makeStringFast:_subData(self.data, numberStartIndex, self.readerIndex - 1)];
            }
                break;
            default:
                @throw [ZPJSONException unexpectedCharacter:nil ascii:byte characterIndex:self.readerIndex + numberchars];
                break;
        }
    }
    
    if (numbersSinceControlChar <= 0) {
        @throw [ZPJSONException unexpectedEndOfFile];
    }
    
    @try {
        return _dataToString(_suffixData(self.data, self.readerIndex), NSUTF8StringEncoding);
    } @finally {
        self.readerIndex = self.dataLength;
    }
}

- (NSUInteger)readableBytes
{
    return self.dataLength - self.readerIndex;
}
    
- (NSUInteger)dataLength
{
    return self.data.length;
}

@end
