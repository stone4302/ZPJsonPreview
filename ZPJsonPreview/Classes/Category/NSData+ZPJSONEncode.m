//
//  NSData+ZPJSONEncode.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/19.
//

#import "NSData+ZPJSONEncode.h"

@implementation NSData (ZPJSONEncode)

+ (NSData *)zpjson_dataWithJson:(id)json
{
    if (!json) { return nil; }
    
    NSData *data = nil;
    if ([json isKindOfClass:NSString.class]) {
        data = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([json isKindOfClass:NSDictionary.class] ||
             [json isKindOfClass:NSArray.class]) {
        NSError *error = nil;
        data = [NSJSONSerialization dataWithJSONObject:json options:(NSJSONWritingPrettyPrinted) error:&error];
        if (error) {
            data = nil;
        }
    }
    else if ([json isKindOfClass:NSData.class]) {
        data = (NSData *)json;
    }
    
    if (!data || ![data isKindOfClass:NSData.class]) {
        return nil;
    }
    return data;
}

@end
