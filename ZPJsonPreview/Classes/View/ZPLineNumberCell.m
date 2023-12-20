//
//  ZPLineNumberCell.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import "ZPLineNumberCell.h"

@implementation ZPLineNumberCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textLabelRect = self.textLabel.frame;
    
    // Modify the left spacing of the label.
    textLabelRect.origin.x = 5;
    
    // Modify the width, actually in order to modify the right spacing.
    textLabelRect.size.width = self.contentView.frame.size.width - 15;
    
    // Make label ceiling display
    CGFloat height = [self.textLabel sizeThatFits:self.contentView.frame.size].height;
    if (height > 0) {
        textLabelRect.size.height = height;
    }
    
    self.textLabel.frame = textLabelRect;
}

@end
