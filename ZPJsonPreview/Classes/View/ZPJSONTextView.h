//
//  ZPJSONTextView.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZPJSONTextView;

@protocol ZPJSONTextViewDelegate <NSObject>

@optional

/**
 - Parameters:
 @prama textView: Currently displayed textView.
 @prama point: value of the clicked coordinate.
 @prama characterIndex: index of the clicked character
 */
- (void)textView:(ZPJSONTextView *)textView didClickZoomAt:(CGPoint)point characterIndex:(NSUInteger)characterIndex;

@end

@interface ZPJSONTextView : UITextView

@property (nonatomic, weak) id <ZPJSONTextViewDelegate>clickDelegate;

@end

NS_ASSUME_NONNULL_END
