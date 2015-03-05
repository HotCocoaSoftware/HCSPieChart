//
//  HCSChartLabelButtonContainerView.h
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCSChartLegendButtonView.h"

@class HCSChartLegendContainerView;

@protocol HCSChartLegendContainerViewDataSource <NSObject>

- (NSUInteger)numberOfChartLegendsInChartLegendContainerView:(HCSChartLegendContainerView *)containerView;
- (NSString *)chartLegendContainerView:(HCSChartLegendContainerView *)containerView textForLegendAtIndex:(NSUInteger)index;
- (UIColor *)chartLegendContainerView:(HCSChartLegendContainerView *)containerView colorForLegendAtIndex:(NSUInteger)index;

@end

@protocol HCSChartLegendContainerViewDelegate <NSObject>

- (void)chartLegendContainerView:(HCSChartLegendContainerView *)container didSelectLegendAtIndex:(NSUInteger)index;

@end

@interface HCSChartLegendContainerView : UIView

@property (nonatomic, weak) id<HCSChartLegendContainerViewDataSource> dataSource;
@property (nonatomic, weak) id<HCSChartLegendContainerViewDelegate> delegate;
@property (nonatomic) BOOL showLegendContainerView;

- (void)reloadData;
- (void)toggleLegendButtonAtIndex:(NSInteger)index;

@end
