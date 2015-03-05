//
//  HCSPieChart.h
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSPieChartView;

@protocol HCSPieChartDataSource <NSObject>

- (NSUInteger)numberOfSlicesInPieChart:(HCSPieChartView *)pieChart;
- (CGFloat)pieChart:(HCSPieChartView *)pieChart valueForSliceAtIndex:(NSUInteger)index;
- (UIColor *)pieChart:(HCSPieChartView *)pieChart colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(HCSPieChartView *)pieChart nameOfLegendAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfLegendsInPieChart:(HCSPieChartView *)pieChart;
- (UIColor *)pieChart:(HCSPieChartView *)pieChart colorForLegendAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(HCSPieChartView *)pieChart textForSliceAtIndex:(NSUInteger)index;

@end

@protocol HCSPieChartDelegate <NSObject>

@optional
- (void)pieChart:(HCSPieChartView *)pieChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(HCSPieChartView *)pieChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(HCSPieChartView *)pieChart didDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(HCSPieChartView *)pieChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(HCSPieChartView *)pieChart didSelectLegendAtIndex:(NSUInteger)index;

@end

@interface HCSPieChartView : UIView

- (id)initWithFrame:(CGRect)frame chartTitle:(NSString *)title chartRadius:(CGFloat)radius;
- (void)reloadData;
- (void)reloadOnlyPieChartNotLegends;

@property(nonatomic, weak) id<HCSPieChartDataSource> dataSource;
@property(nonatomic, weak) id<HCSPieChartDelegate> delegate;

@property (nonatomic, strong) UIFont *chartTitleLabelTextFont;
@property (nonatomic, strong) UIColor *chartTitleLabelTextColor;


@property (nonatomic) CGFloat pieChartRadius;
@property (nonatomic) CGPoint pieChartCentre;
@property (nonatomic) CGFloat spaceBetweenTitleLabelAndPieChart;

@property(nonatomic, assign) BOOL    pieChartShowLabel;
@property(nonatomic, strong) UIFont  *pieChartLabelFont;
@property(nonatomic, strong) UIColor *pieChartLabelColor;
@property(nonatomic, strong) UIColor *pieChartLabelShadowColor;
@property(nonatomic, assign) CGFloat pieChartLabelRadius;

@property(nonatomic, assign) BOOL    pieChartShowPercentage;
@property(nonatomic, assign) CGFloat pieChartStartPieAngle;
@property(nonatomic, assign) CGFloat pieChartAnimationSpeed;
@property(nonatomic, assign) CGFloat pieChartSelectedSliceStroke;
@property(nonatomic, assign) CGFloat pieChartSelectedSliceOffsetRadius;

- (void)setPieChartBackgroundColor:(UIColor *)color;
- (void)setPieChartSliceSelectedAtIndex:(NSInteger)index;
- (void)setPieChartSliceDeselectedAtIndex:(NSInteger)index;

@property (nonatomic) BOOL showChartLegend;
@property (nonatomic) CGFloat spaceBetweenPieChartAndLegendContainer;

@end
