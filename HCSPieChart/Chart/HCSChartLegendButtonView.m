//
//  HCSChartCategoryButton.m
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "HCSChartLegendButtonView.h"

static CGFloat const kLegendCheckBoxHeightAndWidth = 20.f;
static CGFloat const kLegendCheckBoxCornerRadius = 4.f;
static CGFloat const kLegendCheckBoxHorizontalMarginOffset = 2.f;
static CGFloat const kHorizontalSpaceBetweenLegendCheckBoxAndLegendLabel = 3.f;
static CGFloat const kLegendTextFontSize = 12.f;
static CGFloat const kDistanceBetweenLegends = 12.f;

@interface HCSChartLegendButtonView()

@property (nonatomic, strong) UIView *legendCheckBoxView;
@property (nonatomic, strong) UILabel *legendLabel;
@property (nonatomic) BOOL isClicked;
@property (nonatomic, readwrite) NSInteger index;

@end

@implementation HCSChartLegendButtonView

- (id)initWithOrigin:(CGPoint)origin withName:(NSString *)text withColor:(UIColor *)color index:(NSInteger)index {
    self = [self init];
    if (self) {
        self.index = index;
        self.color = color;
        self.legendCheckBoxView = [self legendCheckBoxWithColor:color];
        
        self.legendLabel = [self legendLabelWithText:text];
        CGFloat width = self.legendLabel.frame.origin.x + CGRectGetWidth(self.legendLabel.frame);
        
        CGRect frame = CGRectMake(origin.x, origin.y, width, kLegendCheckBoxHeightAndWidth);
        self.frame = frame;
        [self.legendCheckBoxView setUserInteractionEnabled:NO];
        [self addSubview:self.legendLabel];
        [self addSubview:self.legendCheckBoxView];
        self.backgroundColor = [UIColor clearColor];
        [self addTarget:self action:@selector(chartLabelButtonisClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

#pragma Legend Check Box

- (UIView *)legendCheckBoxWithColor:(UIColor *)color {
    CGFloat originX = kLegendCheckBoxHorizontalMarginOffset;
    CGFloat originY = 0.f;
    UIView *checkBox = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, kLegendCheckBoxHeightAndWidth, kLegendCheckBoxHeightAndWidth)];
    checkBox.layer.cornerRadius = kLegendCheckBoxCornerRadius;
    checkBox.backgroundColor = color;
    
    return checkBox;
}

#pragma Legend Label

- (UILabel *)legendLabelWithText:(NSString *)text {
    UIFont *labelFont = [UIFont systemFontOfSize:kLegendTextFontSize];
    CGSize size = [self sizeForText:text withFont:labelFont withSize:CGSizeMake(CGFLOAT_MAX, kLegendCheckBoxHeightAndWidth)];
    CGFloat originX = self.legendCheckBoxView.frame.origin.x + CGRectGetWidth(self.legendCheckBoxView.frame) + kHorizontalSpaceBetweenLegendCheckBoxAndLegendLabel;
    CGFloat originY = self.legendCheckBoxView.frame.origin.y + 3;
    UILabel *chartLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, size.width + kDistanceBetweenLegends, size.height)];
    chartLabel.textColor=[UIColor blackColor];
    [chartLabel setFont:labelFont];
    chartLabel.backgroundColor=[UIColor clearColor];
    chartLabel.text = text;
    
    return chartLabel;
}

- (CGSize)sizeForText:(NSString *)text withFont:(UIFont *)textFont withSize:(CGSize)size{
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    
    return [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
}

+ (CGFloat)height {
    return kLegendCheckBoxHeightAndWidth;
}

- (void)shiftOriginToPoint:(CGPoint)newOrigin {
    CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.frame = newFrame;
}

- (void)chartLabelButtonisClicked:(HCSChartLegendButtonView *)chartLabelButton {
    if ([self.delegate respondsToSelector:@selector(didSelectChartLegendButtonView:)]){
        [self.delegate didSelectChartLegendButtonView:self];
    }
}

- (void)buttonClicked {
    self.isClicked = !self.isClicked;
    self.legendLabel.font = self.isClicked ? [UIFont boldSystemFontOfSize:kLegendTextFontSize + 1] : [UIFont systemFontOfSize:kLegendTextFontSize];
//    self.backgroundColor = self.isClicked ? [UIColor greenColor]: [UIColor clearColor];
    CGFloat delta = self.isClicked ? 2 : -2;
    CGRect frame = self.legendCheckBoxView.frame;
    frame.size = CGSizeMake(frame.size.width + delta, frame.size.height + delta);
    frame.origin.x -= delta/2;
    frame.origin.y -= delta/2;
    self.legendCheckBoxView.frame = frame;
}

- (void)buttonSelected:(BOOL)selected {
    if (self.isClicked != selected) {
        [self buttonClicked];
    }
}

@end

