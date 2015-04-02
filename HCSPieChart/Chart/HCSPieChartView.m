//
//  HCSPieChart.m
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "HCSPieChartView.h"
#import "XYPieChart.h"
#import "HCSChartLegendContainerView.h"
#import "HCSChartPopUpView.h"

static CGFloat const kChartTitleTextDefaultSize = 20.f;

static CGFloat const kPopUpLeftShift = 100.f;
static CGFloat const kPopUpUpShift = 20;

static CGFloat const kVerticalSpaceBetweenLabelAndChart = 15.f;
static CGFloat const kVerticalSpaceBetweenChartAndChartLabelContainer = 50.f;

static CGFloat const kPieChartLabelFont = 12.f;
static CGFloat const kPieChartLabelRadiusOffsetFromCircumference = 15.f;

static CGFloat const kChartLabelContainerHorizontalMarginOffset = 4.f;

@interface HCSPieChartView() <XYPieChartDataSource, HCSChartLegendContainerViewDataSource, XYPieChartDelegate, HCSChartLegendContainerViewDelegate>

@property (nonatomic, strong) UILabel *chartTitleLabel;
@property (nonatomic, strong) XYPieChart *pieChart;


@property (nonatomic, strong) HCSChartLegendContainerView *chartLegendContainerView;

//@property (nonatomic) CGPoint locationPieChartTapped;
@property (nonatomic) NSUInteger selectedSliceIndex;
@property (nonatomic, strong) UIView *popupView;

@end

@implementation HCSPieChartView

- (id)initWithFrame:(CGRect)frame chartTitle:(NSString *)title chartRadius:(CGFloat)radius {
    self = [super initWithFrame:frame];
    if (self) {
        self.chartTitleLabel = [self chartTitleLabelWithText:title];
        
        self.pieChart = [self pieChartWithRadius:radius];
        self.pieChartRadius = radius;
        
        
        self.chartLegendContainerView = [self emptyChartLegendContainerView];
        self.showChartLegend = YES; //Default show legend is yes
        
        [self addSubview:self.chartTitleLabel];
        [self addSubview:self.pieChart];
        [self addSubview:self.chartLegendContainerView];
    }
    
    return self;
}

- (void)setDelegate:(id<HCSPieChartDelegate>)delegate {
    _delegate = delegate;
    self.pieChart.delegate = self;
    self.chartLegendContainerView.delegate = self;
}

- (void)setDataSource:(id<HCSPieChartDataSource>)dataSource {
    _dataSource = dataSource;
    self.pieChart.dataSource = self;
    self.chartLegendContainerView.dataSource = self;
}

#pragma mark Chart Title Label

- (UILabel *)chartTitleLabelWithText:(NSString *)text {
    //Label Default Font
    UIFont *labelFont = [UIFont boldSystemFontOfSize:kChartTitleTextDefaultSize];
    CGSize textSize = [self sizeForText:text withFont:labelFont];
    
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), textSize.height);
    UILabel *chartTitleLabel = [[UILabel alloc] initWithFrame:frame];
    chartTitleLabel.textAlignment = NSTextAlignmentCenter;
    chartTitleLabel.text = text;
    chartTitleLabel.textColor = [UIColor blackColor];
    [chartTitleLabel setFont:labelFont];
    
    return chartTitleLabel;
}

- (void)setChartTitleLabelTextColor:(UIColor *)chartTitleLabelTextColor {
    if (chartTitleLabelTextColor) {
        _chartTitleLabelTextColor = chartTitleLabelTextColor;
        self.chartTitleLabel.textColor = _chartTitleLabelTextColor;
    }
}

- (void)setChartTitleLabelTextFont:(UIFont *)chartTitleLabelTextFont {
    if (chartTitleLabelTextFont) {
        _chartTitleLabelTextFont = chartTitleLabelTextFont;
        self.chartTitleLabel.font = chartTitleLabelTextFont;
        CGSize textSize = [self sizeForText:self.chartTitleLabel.text withFont:chartTitleLabelTextFont];
        if (self.chartTitleLabel.frame.size.height < textSize.height) {
            //set height for chart label
            CGRect frame = self.chartTitleLabel.frame;
            frame.size.height = textSize.height;
            self.chartTitleLabel.frame = frame;
            [self updatePieChartViewFrame];
        }
    }
}

#pragma mark - Pie Chart

- (XYPieChart *)pieChartWithRadius:(CGFloat)radius {
    CGFloat originX = CGRectGetWidth(self.bounds) / 2 - radius;
    self.spaceBetweenTitleLabelAndPieChart = kVerticalSpaceBetweenLabelAndChart;
    CGFloat originY =  CGRectGetHeight(self.chartTitleLabel.bounds) + self.spaceBetweenTitleLabelAndPieChart;
    XYPieChart *pieChart = [[XYPieChart alloc]initWithFrame:CGRectMake(originX, originY, 2 * radius, 2 * radius) Center:CGPointMake(radius, radius) Radius:radius];
    //default font
    pieChart.parentFrame = self.frame;
    pieChart.insideSliceLabelFont = [UIFont systemFontOfSize:kPieChartLabelFont];
    pieChart.insideSliceLabelRadius = radius - kPieChartLabelRadiusOffsetFromCircumference;

    return pieChart;
}

- (void)setPieChartCentre:(CGPoint)pieChartCentre {
    _pieChartCentre = pieChartCentre;
    self.pieChart.center = pieChartCentre;
}

- (void)setPieChartRadius:(CGFloat)pieChartRadius {
    _pieChartRadius = pieChartRadius;
    self.pieChart.pieRadius = pieChartRadius;
}

- (void)setPieChartLabelFont:(UIFont *)pieChartLabelFont {
    _pieChartLabelFont = pieChartLabelFont;
    self.pieChart.insideSliceLabelFont = pieChartLabelFont;
}

- (void)setPieChartLabelColor:(UIColor *)pieChartLabelColor {
    _pieChartLabelColor = pieChartLabelColor;
    self.pieChart.insideSliceLabelColor = pieChartLabelColor;
}

- (void)setPieChartLabelShadowColor:(UIColor *)pieChartLabelShadowColor {
    _pieChartLabelShadowColor = pieChartLabelShadowColor;
    self.pieChart.insideSliceLabelShadowColor = pieChartLabelShadowColor;
}

- (void)setPieChartLabelRadius:(CGFloat)pieChartLabelRadius {
    _pieChartLabelRadius = pieChartLabelRadius;
    self.pieChart.insideSliceLabelRadius = pieChartLabelRadius;
}

- (void)setPieChartShowLabel:(BOOL)pieChartShowLabel {
    _pieChartShowLabel = pieChartShowLabel;
    self.pieChart.showInsideSliceLabel = pieChartShowLabel;
}

- (void)setPieChartShowPercentage:(BOOL)pieChartShowPercentage {
    _pieChartShowPercentage = pieChartShowPercentage;
    self.pieChart.showPercentage = pieChartShowPercentage;
}

- (void)setPieChartStartPieAngle:(CGFloat)pieChartStartPieAngle {
    _pieChartStartPieAngle = pieChartStartPieAngle;
    self.pieChart.startPieAngle = pieChartStartPieAngle;
}

- (void)setPieChartAnimationSpeed:(CGFloat)pieChartAnimationSpeed {
    _pieChartAnimationSpeed = pieChartAnimationSpeed;
    self.pieChart.animationSpeed = pieChartAnimationSpeed;
}

- (void)setPieChartSelectedSliceOffsetRadius:(CGFloat)pieChartSelectedSliceOffsetRadius {
    _pieChartSelectedSliceOffsetRadius = pieChartSelectedSliceOffsetRadius;
    self.pieChart.selectedSliceOffsetRadius = pieChartSelectedSliceOffsetRadius;
}

- (void)setPieChartSelectedSliceStroke:(CGFloat)pieChartSelectedSliceStroke {
    _pieChartSelectedSliceStroke = pieChartSelectedSliceStroke;
    self.pieChart.selectedSliceStroke = pieChartSelectedSliceStroke;
}

- (void)setPieChartBackgroundColor:(UIColor *)color {
    [self.pieChart setPieBackgroundColor:color];
}

- (void)setPieChartSliceSelectedAtIndex:(NSInteger)index {
    [self.pieChart setSliceSelectedAtIndex:index];
}

- (void)setPieChartSliceDeselectedAtIndex:(NSInteger)index {
    [self.pieChart setSliceDeselectedAtIndex:index];
}

- (void)setSpaceBetweenTitleLabelAndPieChart:(CGFloat)spaceBetweenTitleLabelAndPieChart {
    _spaceBetweenTitleLabelAndPieChart = spaceBetweenTitleLabelAndPieChart;
    [self updatePieChartViewFrame];
}

- (void)setSpaceBetweenPieChartAndLegendContainer:(CGFloat)spaceBetweenPieChartAndLegendContainer {
    _spaceBetweenPieChartAndLegendContainer = spaceBetweenPieChartAndLegendContainer;
    [self updateLegendContainerViewFrame];
}
- (void)updatePieChartViewFrame {
    if (self.pieChart) {
        //Reset fame of pie chart
        CGRect frame = self.pieChart.frame;
        frame.origin.y =  CGRectGetHeight(self.chartTitleLabel.bounds) + self.spaceBetweenTitleLabelAndPieChart;
        self.pieChart.frame = frame;
        [self updateLegendContainerViewFrame];
    }
}

- (void)updateLegendContainerViewFrame {
    if (self.chartLegendContainerView) {
        CGRect frame = self.chartLegendContainerView.frame;
        frame.origin.y = self.pieChart.center.y + self.pieChartRadius + self.spaceBetweenPieChartAndLegendContainer;
        self.chartLegendContainerView.frame = frame;
    }
}

#pragma mark Chart Legends

- (HCSChartLegendContainerView *)emptyChartLegendContainerView {
    CGFloat originX = kChartLabelContainerHorizontalMarginOffset;
    self.spaceBetweenPieChartAndLegendContainer = kVerticalSpaceBetweenChartAndChartLabelContainer;
    CGFloat originY = self.pieChart.center.y + self.pieChartRadius + self.spaceBetweenPieChartAndLegendContainer;
    CGFloat width = CGRectGetWidth(self.frame) - 2 * kChartLabelContainerHorizontalMarginOffset;
    CGFloat height = 0.f;
    HCSChartLegendContainerView *container = [[HCSChartLegendContainerView alloc] initWithFrame:CGRectMake(originX, originY, width, height)];
    [self addSubview:container];
    
    return container;
}

- (void)setShowChartLegend:(BOOL)showChartLegend {
    _showChartLegend = showChartLegend;
    self.chartLegendContainerView.showLegendContainerView = showChartLegend;
}

- (void)reloadData {
    [self.pieChart reloadData];
    [self.chartLegendContainerView reloadData];
}

- (void)reloadOnlyPieChartNotLegends {
    [self.pieChart reloadData];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    NSUInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfSlicesInPieChart:)]) {
         count = [self.dataSource numberOfSlicesInPieChart:self];
    }
    
    return count;
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pieChart:textForSliceAtIndex:)]) {
        return [self.dataSource pieChart:self textForSliceAtIndex:index];
    }
    
    return nil;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pieChart:valueForSliceAtIndex:)]) {
        return [self.dataSource pieChart:self valueForSliceAtIndex:index];
    }
    
    return 0;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pieChart:colorForSliceAtIndex:)]) {
        return [self.dataSource pieChart:self colorForSliceAtIndex:index];
    }
    
    return nil;
}

#pragma mark - XYPieChart Delegate

- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will select slice at index %lu",(unsigned long)index);
    if ([self.delegate respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)]) {
        [self.delegate pieChart:self willSelectSliceAtIndex:index];
    }
}

- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
    [self removePopupView];
    if ([self.delegate respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)]) {
        [self.delegate pieChart:self willDeselectSliceAtIndex:index];
    }
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did didselect slice at index %lu",(unsigned long)index);
    if ([self.delegate respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)]) {
        [self.delegate pieChart:self didDeselectSliceAtIndex:index];
    }
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    NSLog(@"did select slice at index %lu",(unsigned long)index);
    if ([self.delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)]) {
        [self.delegate pieChart:self didSelectSliceAtIndex:index];
    }
}

#pragma mark - HCSChartLabelButtonContainerDataSource

- (NSUInteger)numberOfChartLegendsInChartLegendContainerView:(HCSChartLegendContainerView *)containerView {
    NSUInteger count = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfLegendsInPieChart:)]) {
        count = [self.dataSource numberOfLegendsInPieChart:self];
    }
    
    return count;
}

- (NSString *)chartLegendContainerView:(HCSChartLegendContainerView *)containerView textForLegendAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pieChart:nameOfLegendAtIndex:)]) {
        return [self.dataSource pieChart:self nameOfLegendAtIndex:index];
    }
    
    return nil;
}

- (UIColor *)chartLegendContainerView:(HCSChartLegendContainerView *)containerView colorForLegendAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pieChart:colorForLegendAtIndex:)]) {
        return [self.dataSource pieChart:self colorForLegendAtIndex:index];
    }
    
    return nil;
}

#pragma mark - HCSChartLabelButtonContainerDelegate

- (void)chartLegendContainerView:(HCSChartLegendContainerView *)container didSelectLegendAtIndex:(NSUInteger)index {
    [self.pieChart selectSlice:index];
    if ([self.delegate respondsToSelector:@selector(pieChart:didSelectLegendAtIndex:)]) {
        [self.delegate pieChart:self didSelectLegendAtIndex:index];
    }
}

#pragma mark - Popup View

- (void)showPopUpforSelectedSliceAtIndex:(NSUInteger)index atOrigin:(CGPoint)origin {
    if (self.popupView) {
        [self removePopupView];
    }
    NSString *nameOfSlice = [self.dataSource pieChart:self nameOfLegendAtIndex:index];
    UIColor *color = [self.dataSource pieChart:self colorForSliceAtIndex:index];
    CGFloat percentage = [self.pieChart percentageOfSliceAtIndex:index];
    NSString *text = [NSString stringWithFormat:@"%@:%0.0f%%", nameOfSlice, percentage];
    self.popupView = [self popViewAtOrigin:origin withText:text withColor:color];
    [self addSubview:self.popupView];

    if (!(index == self.selectedSliceIndex)) {
    }
}

- (void)removePopupView {
    if (self.popupView) {
        [self.popupView removeFromSuperview];
        self.popupView = nil;
    }
}

- (UIView *)popViewAtOrigin:(CGPoint)origin withText:(NSString *)text withColor:(UIColor *)color{
    HCSChartPopUpView *popUpView = [[HCSChartPopUpView alloc] initPopViewWithOrigin:CGPointMake(origin.x - kPopUpLeftShift, origin.y - kPopUpUpShift) withText:text color:color];
    
    return popUpView;
}

#pragma mark - Touch Event

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.pieChart];
    NSInteger selectedIndex = [self.pieChart getCurrentSelectedOnTouch:point];
    [self.chartLegendContainerView toggleLegendButtonAtIndex:selectedIndex];
    point.x +=  self.pieChart.frame.origin.x;
    if (selectedIndex >= 0) {
        [self showPopUpforSelectedSliceAtIndex:selectedIndex atOrigin:(CGPoint)point];
    } else {
        [self removePopupView];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removePopupView];
}

- (CGSize)sizeForText:(NSString *)text withFont:(UIFont *)textFont{
    NSDictionary *attributes = @{NSFontAttributeName: textFont};
    
    return [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil].size;
}

@end
