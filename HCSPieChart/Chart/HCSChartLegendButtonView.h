//
//  HCSChartLegendButtonView.h
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSChartLegendButtonView;

@protocol HCSChartLegendButtonViewDelegate <NSObject>

- (void)didSelectChartLegendButtonView:(HCSChartLegendButtonView *)chartCategoryButton;

@end

@interface HCSChartLegendButtonView : UIButton

@property (nonatomic, weak) id<HCSChartLegendButtonViewDelegate> delegate;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, readonly) NSInteger index;

- (void)buttonClicked;
- (void)buttonSelected:(BOOL)selected;
- (id)initWithOrigin:(CGPoint)origin withName:(NSString *)text withColor:(UIColor *)color index:(NSInteger)index;
- (void)shiftOriginToPoint:(CGPoint)newOrigin;
+ (CGFloat)height;

@end

