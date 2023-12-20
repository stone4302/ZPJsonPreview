//
//  NSString+ZPJsonValidURL.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "NSString+ZPJsonValidURL.h"

@implementation ZPJSONValidURL

- (instancetype)initWithUrlString:(NSString *)urlString isIP:(BOOL)isIP
{
    self = [super init];
    if (self) {
        _urlString = urlString;
        _isIP = isIP;
    }
    return self;
}

- (NSURL *)openingURL
{
    if (_isIP) {
        // Add "http" prefix to ip address
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", _urlString]];
    }
    
    NSURL *_url = [NSURL URLWithString:_urlString];
    if (_url.scheme == nil) {
        // Add the "https" prefix to the general address
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", _urlString]];
    }
    return _url;
}

@end

@implementation NSString (ZPJsonValidURL)

/// Check if the string is a valid URL.
///
/// - Return: If it is a valid URL, return the unescaped string. Otherwise return nil.
- (ZPJSONValidURL *)zp_json_validURL
{
    if (self.length <= 1) {
        return nil;
    }
    
    NSString *string = [self removeEscaping];
    
    // Since `predicate` can also match ip,
    // use `ipPredicate` to match ip first,
    // and then use `predicate` to match if it is not.
    if ([self.zp_json_predicate_ip_address evaluateWithObject:string.lowercaseString]) {
        return [[ZPJSONValidURL alloc] initWithUrlString:string isIP:YES];
    }
    
    if ([self.zp_json_predicate_url evaluateWithObject:string.lowercaseString]) {
        return [[ZPJSONValidURL alloc] initWithUrlString:string isIP:NO];
    }
    return nil;
}

- (NSString *)removeEscaping
{
    NSString *string = self;
    
    if ([string containsString:@"\\/"]) {
        string = [string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
    return self;
}

#pragma mark - private

/// Used to match any url, including ip addresses.
- (NSPredicate *)zp_json_predicate_url
{
    NSArray *argumentArray = @[
        @"((?:http|https)://)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
    ];
    return [NSPredicate predicateWithFormat:@"SELF MATCHES %@" argumentArray:argumentArray];
}

/// Used to match ip addresses.
- (NSPredicate *)zp_json_predicate_ip_address
{
    NSArray *argumentArray = @[
        @"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    ];
    return [NSPredicate predicateWithFormat:@"SELF MATCHES %@" argumentArray:argumentArray];
}

@end


