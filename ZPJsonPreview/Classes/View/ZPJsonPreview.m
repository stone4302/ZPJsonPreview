//
//  ZPJsonPreview.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import "ZPJsonPreview.h"
#import "ZPJSONTextView.h"
#import "ZPJSONDecorator.h"
#import "NSString+ZPJsonValidURL.h"

typedef NSDictionary <NSNumber*, NSNumber*> * ZPJsonLineHeightStorage;

@interface ZPJsonPreview ()
<
UITextViewDelegate,
ZPJSONTextViewDelegate
>
@property (nonatomic, strong) ZPJSONHighlightStyle *highlightStyle;
@property (nonatomic, strong) ZPJSONTextView *jsonTextView;

@property (nonatomic, strong) ZPJSONDecorator *decorator;
@property (nonatomic, strong) NSArray *lineDataSource;
@end

@implementation ZPJsonPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config
{
    [self addSubview:self.jsonTextView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.jsonTextView.frame = self.bounds;
}

#pragma mark - public

- (void)previewJson:(id)json style:(ZPJSONHighlightStyle *)style
{
    if (!style || ![style isKindOfClass:ZPJSONHighlightStyle.class]) {
        style = [ZPJSONHighlightStyle new];
    }
    
    _highlightStyle = style;
    
    self.decorator = [ZPJSONDecorator decoratorWithJson:json judgmentValid:YES style:style];
    
    [self refreshTextView];
}

- (void)previewJson:(id)json
{
    [self previewJson:json style:nil];
}

#pragma mark - UI

- (void)refreshTextView
{
    // 异常判断
    if (self.decorator.error) {
        [self showErrorText];
        return;
    }
    
    NSMutableAttributedString *jsonAttributedString = [[NSMutableAttributedString alloc] init];
    
    for (ZPJSONSlice *slice in self.decorator.slices) {
        if ([slice isKindOfClass:ZPJSONSlice.class]) {
            [jsonAttributedString appendAttributedString:slice.expand];
            [jsonAttributedString appendAttributedString:self.decorator.wrapString];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.jsonTextView.attributedText = jsonAttributedString;
    });
}

- (void)showErrorText
{
    NSString *errorString = nil;
    ZPJSONError *error = self.decorator.error;
    if (error.error) {
        NSString *string = [error.error.userInfo objectForKey:NSLocalizedDescriptionKey];
        if (!string || ![string isKindOfClass:NSString.class] || string.length <= 0) {
            string = [error.error.userInfo objectForKey:NSDebugDescriptionErrorKey];
        }
        errorString = [NSString stringWithFormat:@"Error: %@", string ?: @"未知错误"];
    }
    else if (error.exception) {
        ZPJSONValue *unknown = [error.exception unknownJsonValue];
        errorString = [NSString stringWithFormat:@"Error: %@", unknown.unknownValue ?: @"未知错误"];
    }
    
    errorString = errorString ?: @"Error: 未知错误";
    
    NSAttributedString *attErrorString = [[NSAttributedString alloc] initWithString:errorString attributes:self.errorTextAttributes];
        
    dispatch_async(dispatch_get_main_queue(), ^{
        self.jsonTextView.attributedText = attErrorString;
    });
}

- (NSDictionary *)errorTextAttributes
{
    return @{
        NSForegroundColorAttributeName : [self.highlightStyle.color colorKey:errorText],
        NSFontAttributeName : self.highlightStyle.errorFont
    };
}

#pragma mark -

/// Calculate the line height of the line number display area
- (CGFloat)calculateLineHeightAtIndex:(NSUInteger)index width:(CGFloat)width
{
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineFragmentPadding = 0;
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [layoutManager addTextContainer:textContainer];
    [layoutManager glyphRangeForBoundingRect:CGRectMake(0, 0, size.width, size.height) inTextContainer:textContainer];
    
    NSMutableAttributedString *attString = nil;
    if (index >= 0 && index <= self.decorator.slices.count - 1) {
        ZPJSONSlice *slice = [self.decorator.slices objectAtIndex:index];
        attString = slice.expand;
    }
    
    if (attString == nil) {
        return 0;
    }
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:attString];
    [textStorage addLayoutManager:layoutManager];
    CGRect rect = [layoutManager usedRectForTextContainer:textContainer];
    
    return rect.size.height;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    NSURL *openingURL = [[URL.absoluteString zp_json_validURL] openingURL];
    if (!_delegate || !openingURL) {
        return YES;
    }
    
    return [_delegate jsonPreview:self didClickURL:openingURL on:textView];
}

#pragma mark - ZPJSONTextViewDelegate

static NSUInteger _displayLengthFromSlice(ZPJSONSlice *slice) {
    switch (slice.state) {
        case ZPJSONSliceState_expand: return slice.expand.length;
        case ZPJSONSliceState_folded:
        {
            if (slice.folded && [slice.folded isKindOfClass:NSMutableAttributedString.class]) {
                return slice.folded.length;
            }
            return 0;
        }
        default: return 0;
    }
}

- (void)textView:(ZPJSONTextView *)textView didClickZoomAt:(CGPoint)point characterIndex:(NSUInteger)characterIndex
{
    // Get the clicked character
    NSUInteger startIndex = 0;
    NSString *clickedCharacter = [textView.text substringWithRange:NSMakeRange(startIndex + characterIndex, 1)];
    
    if ([self.decorator isExpandOrFoldString:clickedCharacter]) {
        // Get the clicked slice
        ZPJSONSlice *clickSlice = [self clickSliceAtCharacterIndex:characterIndex];
        if (!clickSlice || ![clickSlice isKindOfClass:ZPJSONSlice.class]) {
            return;
        }
        // 避免点击的位置不是可以收起的slice
        if (![self containActionIconFromSlice:clickSlice]) {
            return;
        }
        NSUInteger currentIndex = [self.decorator.slices indexOfObject:clickSlice];
        // Calculate the starting point of the replacement range
        NSUInteger location = 0;
        for (NSUInteger index=0; index<currentIndex; index++) {
            ZPJSONSlice *slice = [self.decorator.slices objectAtIndex:index];
            if (slice.foldedTimes != 0) {
                continue;
            }
            location = location + 1 + _displayLengthFromSlice(slice);
        }
        // Perform different operations based on slice status
        switch (clickSlice.state) {
            case ZPJSONSliceState_expand:
            {
                NSMutableAttributedString *folded = clickSlice.folded;
                if (!folded) return;
                clickSlice.state = ZPJSONSliceState_folded;
                
                BOOL isExecution = true;
                NSUInteger length = clickSlice.expand.string.length;
                
                for (NSUInteger index=currentIndex+1; index<self.decorator.slices.count; index++) {
                    if (!isExecution) {
                        break; // 不需要执行跳出循环
                    }
                    ZPJSONSlice *slice = [self.decorator.slices objectAtIndex:index];
                    if (slice.level < clickSlice.level) { continue; }
                    if (slice.level == clickSlice.level) { isExecution = false; }
                    
                    NSUInteger foldedTimes = slice.foldedTimes;
                    slice.foldedTimes += 1;
                    
                    if (foldedTimes != 0) { continue; }
                    // Accumulate the length of the string to be hidden
                    length = length + 1 + _displayLengthFromSlice(slice);
                }
                // Replacement string
                [self.jsonTextView.textStorage replaceCharactersInRange:NSMakeRange(location, length) withAttributedString:folded];
            }
                break;
            case ZPJSONSliceState_folded:
            {
                NSMutableAttributedString *folded = clickSlice.folded;
                if (!folded) return;
                clickSlice.state = ZPJSONSliceState_expand;
                
                BOOL isExecution = true;
                
                NSMutableAttributedString *replaceString = [[NSMutableAttributedString alloc] init];
                
                for (NSUInteger index=currentIndex+1; index<self.decorator.slices.count; index++) {
                    if (!isExecution) {
                        break; // 不需要执行跳出循环
                    }
                    ZPJSONSlice *slice = [self.decorator.slices objectAtIndex:index];
                    if (slice.level < clickSlice.level) { continue; }
                    if (slice.level == clickSlice.level) { isExecution = false; }
                    slice.foldedTimes -= 1;
                    if (slice.foldedTimes != 0) { continue; }
                    
                    switch (slice.state) {
                        case ZPJSONSliceState_expand:
                        {
                            [replaceString appendAttributedString:slice.expand];
                            [replaceString appendAttributedString:self.decorator.wrapString];
                        }
                            break;
                        case ZPJSONSliceState_folded:
                        {
                            if (slice.folded && [slice.folded isKindOfClass:NSMutableAttributedString.class]) {
                                [replaceString appendAttributedString:slice.folded];
                                [replaceString appendAttributedString:self.decorator.wrapString];
                            }
                        }
                            break;
                    }
                }
                
                // Replacement string
                [replaceString insertAttributedString:self.decorator.wrapString atIndex:0];
                [replaceString insertAttributedString:clickSlice.expand atIndex:0];
                
                [replaceString deleteCharactersInRange:NSMakeRange(replaceString.length - 1, 1)];
                // Replacement string
                [self.jsonTextView.textStorage replaceCharactersInRange:NSMakeRange(location, folded.length) withAttributedString:replaceString];
            }
                break;
        }
    }
}

- (BOOL)containActionIconFromSlice:(ZPJSONSlice *)slice
{
    NSString *expand = slice.expand.string;
    if (!expand || ![expand isKindOfClass:NSString.class]) {
        return NO;
    }
    
    for (NSInteger i=0; i<expand.length; i++) {
        NSString *string = [expand substringWithRange:NSMakeRange(i, 1)];
        if ([self.decorator isExpandOrFoldString:string]) {
            return YES;
        }
    }
    
    return NO;
}

- (ZPJSONSlice *)clickSliceAtCharacterIndex:(NSUInteger)characterIndex
{
    ZPJSONSlice *clickSlice = nil;
    NSUInteger count = 0;
    // Using foldedTimes, when foldedTimes is greater than 0, it means it is hidden and not counted
    for (NSUInteger i=0; i<self.decorator.slices.count; i++) {
        ZPJSONSlice *slice = [self.decorator.slices objectAtIndex:i];
        if ([slice isKindOfClass:ZPJSONSlice.class]) {
            if (slice.foldedTimes != 0) { continue; }
            NSUInteger length = _displayLengthFromSlice(slice);
            if (count + length >= characterIndex) {
                clickSlice = slice;
                break;
            }
            length += 1; //后面的\n
            count += length;
        }
    }
    return clickSlice;
}

#pragma mark - getter

- (ZPJSONTextView *)jsonTextView
{
    if (!_jsonTextView) {
        _jsonTextView = [[ZPJSONTextView alloc] init];
        _jsonTextView.clickDelegate = self;
        _jsonTextView.delegate = self;
    }
    return _jsonTextView;
}

- (ZPJSONDecorator *)decorator
{
    if (!_decorator) {
        _decorator = [[ZPJSONDecorator alloc] init];
    }
    return _decorator;
}

@end
