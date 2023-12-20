//
//  ZPJSONError.m
//  ZPAlexProject
//
//  Created by Alex on 2023/12/20.
//

#import "ZPJSONError.h"

@implementation ZPJSONError

+ (instancetype)jsonError:(NSError *)error
{
    ZPJSONError *objc = [[ZPJSONError alloc] init];
    objc.error = error;
    return objc;
}

+ (instancetype)jsonErrorWithException:(ZPJSONException *)exception
{
    ZPJSONError *objc = [[ZPJSONError alloc] init];
    objc.exception = exception;
    return objc;
}

@end
