//
//  ZPJSONValue.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZPJSONValueState) {
    valueState_wrong, // 异常
    valueState_right_isContainer, // 正确，value是容器
    valueState_right_isNotContainer // 正确，value不是容器
};

typedef NS_ENUM(NSInteger, ZPJSONValueClass) {
    zp_string = 1,
    zp_number = 2,
    zp_bool = 3,
    zp_null = 4,
    zp_array = 5,
    zp_object = 6,
    zp_unknown = 100
};

@interface ZPJSONValue : NSObject

// 属性用于存储不同类型的值
@property (nonatomic, assign, readonly) ZPJSONValueClass valueClass;

@property (nonatomic, strong, readonly) NSString *stringValue;
@property (nonatomic, strong, readonly) NSString *numberValue;
@property (nonatomic, assign, readonly) BOOL boolValue;
@property (nonatomic, strong, readonly) NSArray<ZPJSONValue *> *arrayValue;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, ZPJSONValue *> *objectValue;
@property (nonatomic, strong, readonly) NSString *unknownValue;

@property (nonatomic, strong, readonly) NSString *wrong;

+ (instancetype)stringJsonValue:(NSString *)string;

+ (instancetype)objectJsonValue:(NSDictionary *)object;

+ (instancetype)arrayJsonValue:(NSArray *)array;

+ (instancetype)boolJsonValue:(BOOL)bl;

+ (instancetype)nullJsonValue;

+ (instancetype)numberJsonValue:(NSString *)number;

+ (instancetype)unknownJsonValue:(NSString *)unknown;

- (ZPJSONValueState)valueState;

- (BOOL)isRight;

- (void)appendWrong:(NSString *)wrongString;

@end

NS_ASSUME_NONNULL_END
