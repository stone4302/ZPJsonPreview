//
//  ZPJSONDocumentReader.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
 
#define kJson_space  ' '
#define kJson_return '\r'
#define kJson_newline '\n'
#define kJson_tab '\t'

#define kJson_colon ':'
#define kJson_comma ','

#define kJson_openbrace '{'
#define kJson_closebrace '}'

#define kJson_openbracket '['
#define kJson_closebracket ']'

#define kJson_quote '\"'
#define kJson_backslash '\\'

@interface ZPJSONDocumentReader : NSObject

@property (nonatomic, strong, readonly) NSData *data;

@property (nonatomic, assign, readonly) NSUInteger readerIndex;

- (instancetype)initWithData:(NSData *)data;

- (uint8_t)read;

- (uint8_t)try_consumeWhitespace;

- (uint8_t)peekWithOffset:(NSUInteger)offset;

- (void)moveReaderIndex:(NSUInteger)offset;

- (NSString *)try_readString;

- (BOOL)try_readBool;

- (void)try_readNull;

- (NSString *)try_readNumber;

- (NSString *)readUnknown:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
