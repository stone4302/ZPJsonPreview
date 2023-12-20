//
//  ZPJSONTextView.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import "ZPJSONTextView.h"

@implementation ZPJSONTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self config];
    }
    return self;
}

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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.bounces = NO;
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
    self.showsHorizontalScrollIndicator = NO;
    
    self.editable = NO;
    self.scrollEnabled = YES;
    self.textAlignment = NSTextAlignmentLeft;
    self.textContainer.lineFragmentPadding = 0;
    self.layoutManager.allowsNonContiguousLayout = NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    // Get the letter of the character at the current touch position
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    // Get the position of the clicked letter
    NSUInteger characterIndex = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    NSUInteger startIndex = 0;
    // Prevent the click logic from triggering when the line break is clicked.
    NSString *indexString = [self.text substringWithRange:NSMakeRange(startIndex + characterIndex, 1)];
    if ([indexString isEqualToString:@"\n"]) {
        return;
    }
    
    dispatch_block_t callBack = ^{
        if ([self.clickDelegate respondsToSelector:@selector(textView:didClickZoomAt:characterIndex:)]) {
            [self.clickDelegate textView:self didClickZoomAt:point characterIndex:characterIndex];
        }
    };
    
    // Clicked on the fold area
    NSDictionary *attributes = [self.attributedText attributesAtIndex:characterIndex effectiveRange:nil];
    
    if ([attributes objectForKey:NSAttachmentAttributeName] != nil) {
        callBack();
        return;
    }
    
    if ([attributes objectForKey:NSBackgroundColorAttributeName] != nil) {
        callBack();
        return;
    }
    
    // Blur the scope of the click.
    for (int i=-1; i<=2; i++) {
        NSInteger offset = characterIndex + i;
        if (offset < 0 || offset > self.text.length - 1) {
            break;
        }
        NSString *offsetString = [self.text substringWithRange:NSMakeRange(offset, 1)];
        if (![offsetString isEqualToString:@"["] && [offsetString isEqualToString:@"{"]) {
            continue;
        }
        callBack();
        break;
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    /**
         action == @selector(cut:) ||
         action == @selector(paste:) ||
         action == @selector(select:) ||
         action == @selector(delete:)
     */
    if (action == @selector(copy:) ||
        action == @selector(selectAll:)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)copy:(id)sender
{
    [super copy:sender];
    self.selectedTextRange = nil;
}

@end
