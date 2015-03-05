//
//  HCSChartLabelButtonContainerView.m
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import "HCSChartLegendContainerView.h"
#import "HCSChartLegendButtonView.h"

static CGFloat const kChartLegendContainerViewCornerRadius = 4.f;
static CGFloat const kLegendViewMarginOffSetWithChartLegendContainerView = 6.f;

@interface HCSChartLegendContainerView() <HCSChartLegendButtonViewDelegate>

@property (nonatomic, strong) NSMutableArray *chartLabelButtonArray;

@end

@implementation HCSChartLegendContainerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        self.layer.cornerRadius = kChartLegendContainerViewCornerRadius;
        self.showLegendContainerView = YES;
    }
    
    return self;
}

- (void)reloadData {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.layer.borderColor = [UIColor clearColor].CGColor;
    if (self.showLegendContainerView) {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        [self addChartLegendsToLegendViewContainer];
    }
}

- (void)setShowLegendContainerView:(BOOL)showLegendContainerView {
    _showLegendContainerView = showLegendContainerView;
    [self reloadData];
}

- (void)addChartLegendsToLegendViewContainer {
    if ([self.dataSource respondsToSelector:@selector(numberOfChartLegendsInChartLegendContainerView:)]) {
        NSUInteger numberChartLegendViews = [self.dataSource numberOfChartLegendsInChartLegendContainerView:self];
        
        CGFloat firstRowOriginX = kLegendViewMarginOffSetWithChartLegendContainerView;
        CGFloat heightOfOneRow = [HCSChartLegendButtonView height] + 2 * kLegendViewMarginOffSetWithChartLegendContainerView;
        
        CGFloat currentLegendOriginX = firstRowOriginX;
        CGFloat currentLegendOriginY = kLegendViewMarginOffSetWithChartLegendContainerView;
        CGFloat frameHeight = heightOfOneRow;
        self.chartLabelButtonArray = [NSMutableArray array];
        
        for (NSUInteger i = 0; i < numberChartLegendViews; i++) {
            HCSChartLegendButtonView *chartLegendView = [self createLegendViewAtIndex:i];
                chartLegendView.delegate = self;
            
            if (!(currentLegendOriginX + CGRectGetWidth(chartLegendView.frame) < CGRectGetWidth(self.frame))) {
                currentLegendOriginX = firstRowOriginX;
                currentLegendOriginY = currentLegendOriginY + heightOfOneRow;
                frameHeight = frameHeight + heightOfOneRow;
            }
            
            [chartLegendView shiftOriginToPoint:CGPointMake(currentLegendOriginX, currentLegendOriginY)];
            [self addSubview:chartLegendView];
            [self.chartLabelButtonArray addObject:chartLegendView];
            currentLegendOriginX = currentLegendOriginX + CGRectGetWidth(chartLegendView.frame);
        }
        CGRect frame = self.frame;
        frame.size.height = frameHeight;
        self.frame = frame;
    }
}

- (HCSChartLegendButtonView *)createLegendViewAtIndex:(NSUInteger)index {
    NSString *legendText = [self textForLegendAtIndex:index];
    UIColor *legendColor = [self colorForLegendAtIndex:index];
    
    return [[HCSChartLegendButtonView alloc] initWithOrigin:CGPointMake(0, 0) withName:legendText withColor:legendColor index:index];
}

- (NSString *)textForLegendAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(chartLegendContainerView:textForLegendAtIndex:)]) {
        return [self.dataSource chartLegendContainerView:self textForLegendAtIndex:index];
    } else {
    return @"";
    }
}

- (UIColor *)colorForLegendAtIndex:(NSUInteger)index {
    if ([self.dataSource respondsToSelector:@selector(chartLegendContainerView:colorForLegendAtIndex:)]) {
        return [self.dataSource chartLegendContainerView:self colorForLegendAtIndex:index];
    } else {
        return [UIColor clearColor];
    }
}

- (void)toggleLegendButtonAtIndex:(NSInteger)index {
    if (index > 0) {
        HCSChartLegendButtonView *button = self.chartLabelButtonArray[index];
        [button buttonClicked];
    }
}

#pragma mark - HCSChartLegendButtonViewDelegate

- (void)didSelectChartLegendButtonView:(HCSChartLegendButtonView *)chartCategoryButton {
    NSUInteger index = [self.chartLabelButtonArray indexOfObject:chartCategoryButton];
    if ([self.delegate respondsToSelector:@selector(chartLegendContainerView:didSelectLegendAtIndex:)]) {
        [self.delegate chartLegendContainerView:self didSelectLegendAtIndex:index];
    }
}

@end
