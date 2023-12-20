//
//  ZPJSONValue.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import "ZPJSONValue.h"

@interface ZPJSONValue ()

// 属性用于存储不同类型的值
@property (nonatomic, assign) ZPJSONValueClass valueClass;

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) NSString *numberValue;
@property (nonatomic, assign) BOOL boolValue;
@property (nonatomic, strong) NSArray<ZPJSONValue *> *arrayValue;
@property (nonatomic, strong) NSDictionary<NSString *, ZPJSONValue *> *objectValue;
@property (nonatomic, strong) NSString *unknownValue;

@property (nonatomic, strong) NSString *wrong;

@end

@implementation ZPJSONValue

#pragma mark - init selector

+ (instancetype)stringJsonValue:(NSString *)string
{
    ZPJSONValue *value = [ZPJSONValue new];
    if ([string isKindOfClass:NSString.class]) {
        value.stringValue = string;
        value.valueClass = zp_string;
    }
    return value;
}

+ (instancetype)objectJsonValue:(NSDictionary *)object
{
    ZPJSONValue *value = [ZPJSONValue new];
    if ([object isKindOfClass:NSDictionary.class]) {
        value.objectValue = object;
        value.valueClass = zp_object;
    }
    return value;
}

+ (instancetype)arrayJsonValue:(NSArray *)array
{
    ZPJSONValue *value = [ZPJSONValue new];
    if ([array isKindOfClass:NSArray.class]) {
        value.arrayValue = array;
        value.valueClass = zp_array;
    }
    return value;
}

+ (instancetype)boolJsonValue:(BOOL)bl
{
    ZPJSONValue *value = [ZPJSONValue new];
    value.boolValue = bl;
    value.valueClass = zp_bool;
    return value;
}

+ (instancetype)nullJsonValue
{
    ZPJSONValue *value = [ZPJSONValue new];
    value.valueClass = zp_null;
    return value;
}

+ (instancetype)numberJsonValue:(NSString *)number
{
    ZPJSONValue *value = [ZPJSONValue new];
    if ([number isKindOfClass:NSString.class]) {
        value.numberValue = number;
        value.valueClass = zp_number;
    }
    return value;
}

+ (instancetype)unknownJsonValue:(NSString *)unknown
{
    ZPJSONValue *value = [ZPJSONValue new];
    value.unknownValue = unknown;
    value.valueClass = zp_unknown;
    return value;
}

#pragma mark - safe getter

- (NSString *)stringValue
{
    if (_valueClass == zp_string && [_stringValue isKindOfClass:NSString.class]) {
        return _stringValue;
    }
    return nil;
}

- (NSString *)numberValue
{
    if (_valueClass == zp_number && [_numberValue isKindOfClass:NSString.class]) {
        return _numberValue;
    }
    return nil;
}

- (NSArray<ZPJSONValue *> *)arrayValue
{
    if (_valueClass == zp_array && [_arrayValue isKindOfClass:NSArray.class]) {
        return _arrayValue;
    }
    return nil;
}

- (NSDictionary<NSString *,ZPJSONValue *> *)objectValue
{
    if (_valueClass == zp_object && [_objectValue isKindOfClass:NSDictionary.class]) {
        return _objectValue;
    }
    return nil;
}

- (NSString *)unknownValue
{
    if (_valueClass == zp_unknown && [_unknownValue isKindOfClass:NSString.class]) {
        return _unknownValue;
    }
    return nil;
}

#pragma mark - public selector

- (void)appendWrong:(NSString *)wrongString
{
    self.wrong = wrongString;
}

#pragma mark - public getter

- (ZPJSONValueState)isRight
{
    switch (self.valueClass) {
        case zp_unknown: return valueState_wrong;
        case zp_string: return self.wrong == nil ? valueState_right_false : valueState_wrong;
        case zp_number: return self.wrong == nil ? valueState_right_false : valueState_wrong;
        case zp_bool: return self.wrong == nil ? valueState_right_false : valueState_wrong;
        case zp_null: return self.wrong == nil ? valueState_right_false : valueState_wrong;
        case zp_array:
        {
            ZPJSONValue *last = [self.arrayValue lastObject];
            if (!last) {
                return valueState_right_true;
            }
            if (last.isRight == valueState_right_true ||
                last.isRight == valueState_right_false) {
                return valueState_right_true;
            } else {
                return valueState_wrong;
            }
        }
        case zp_object:
        {
            for (ZPJSONValue *value in self.objectValue.allValues) {
                if (value.isRight != valueState_wrong) {
                    continue;
                }
                return valueState_wrong;
            }
            return valueState_right_true;
        }
            
        default: return valueState_wrong;
    }
}



@end
