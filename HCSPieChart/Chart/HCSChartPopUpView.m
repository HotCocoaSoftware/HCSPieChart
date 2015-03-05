//
//  HCSChartPopUpView.m
//  HCSPieChart
//
//  Created by Aseem Aggarwal on 12/24/14.
//  Copyright (c) 2014 Aseem Aggarwal. All rights reserved.
//

#import "HCSChartPopUpView.h"

static CGFloat const kPopupViewLabelFontSize = 15.f;
static CGFloat const kPopupViewCornerRadius = 5.f;
static CGFloat const kPopupViewLabelMarginOffset = 5.f;

@implementation HCSChartPopUpView

- (id)initPopViewWithOrigin:(CGPoint)origin withText:(NSString *)text color:(UIColor *)color {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = color.CGColor;
        self.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        self.layer.cornerRadius = kPopupViewCornerRadius;
        UIFont *font = [UIFont systemFontOfSize:kPopupViewLabelFontSize];
        UILabel *popupViewLabel = [self popupViewLabelViewWithText:text font:font];
        [self addSubview:popupViewLabel];
        self.frame = CGRectMake(origin.x, origin.y, CGRectGetWidth(popupViewLabel.frame) + 2 * kPopupViewLabelMarginOffset, CGRectGetHeight(popupViewLabel.frame) + 2 * kPopupViewLabelMarginOffset);
    }
    
    return self;
}

- (UILabel *)popupViewLabelViewWithText:(NSString *)text font:(UIFont *)font {
    CGSize size = [self sizeForText:text withFont:font];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kPopupViewLabelMarginOffset, kPopupViewLabelMarginOffset, size.width, size.height)];
    label.font = font;
    label.text = text;
    
    return label;
}

- (CGSize)sizeForText:(NSString *)text withFont:(UIFont *)textFont{
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    
    return [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
}

@end
