//
//  ZPJsonPreview.h
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import <UIKit/UIKit.h>
#import "ZPJSONHighlightStyle.h"

NS_ASSUME_NONNULL_BEGIN

@class ZPJsonPreview;

@protocol ZPJsonPreviewDelegate <NSObject>

@optional

/**
 - Parameters:
 @prama view: The view itself for previewing the json.
 @prama url: The URL address that the user clicked on.
 @prama textView: The `UITextView` to which the URL belongs.
 @Returen: `true` if interaction with the URL should be allowed; `false` if interaction should not be allowed.
 */
- (BOOL)jsonPreview:(ZPJsonPreview *)jsonPreview didClickURL:(NSURL *)url on:(UITextView *)textView;

@end

@interface ZPJsonPreview : UIView

@property (nonatomic, weak) id <ZPJsonPreviewDelegate>delegate;

- (void)previewJson:(id)json style:(ZPJSONHighlightStyle *)style;

- (void)previewJson:(id)json;

@end

NS_ASSUME_NONNULL_END
