//
//  ViewController.m
//  HCSPieChart
//
//  Created by Sahil Kapoor on 04/03/15.
//  Copyright (c) 2015 Hot Cocoa Software. All rights reserved.
//


#import "ViewController.h"
#import "HCSPieChartView.h"

#define PCColorBlue [UIColor colorWithRed:0.0 green:153/255.0 blue:204/255.0 alpha:1.0]
#define PCColorGreen [UIColor colorWithRed:153/255.0 green:204/255.0 blue:51/255.0 alpha:1.0]
#define PCColorOrange [UIColor colorWithRed:1.0 green:153/255.0 blue:51/255.0 alpha:1.0]
#define PCColorRed [UIColor colorWithRed:1.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define PCColorYellow [UIColor colorWithRed:1.0 green:220/255.0 blue:0.0 alpha:1.0]
#define PCColorDefault [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]

@interface ViewController () <HCSPieChartDataSource, HCSPieChartDelegate>

@property (nonatomic, strong) HCSPieChartView *pieChart;
@property (nonatomic, strong) NSArray *valueArray;
@property (nonatomic, strong) NSArray *legendsArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    CGFloat width;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = self.view.bounds.size.width / 4;
    } else {
        width = self.view.bounds.size.width / 4;
    }
    self.pieChart = [[HCSPieChartView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.width) chartTitle:@"PIE CHART" chartRadius:width];
    self.pieChart.spaceBetweenTitleLabelAndPieChart = 40.0;
    self.pieChart.spaceBetweenPieChartAndLegendContainer = 20.0;
    self.pieChart.dataSource = self;
    self.pieChart.delegate = self;
    self.valueArray = @[@(33), @(15), @(5), @(15), @(22),@(43), @(20), @(30), @(15), @(22)];
    self.legendsArray = @[@"Calm", @"Cool", @"Ego", @"Stature", @"Agile",@"Narcissist", @"Charm", @"Creative", @"Versatile", @"Witty"];
    [self.view addSubview:self.pieChart];
    [self.pieChart reloadData];
    self.pieChart.pieChartShowPercentage = NO;
}

- (NSUInteger)numberOfSlicesInPieChart:(HCSPieChartView *)pieChart {
    return 8;
}

- (NSString *)pieChart:(HCSPieChartView *)pieChart textForSliceAtIndex:(NSUInteger)index {
    return self.legendsArray[index];
}

- (NSUInteger)numberOfLegendsInPieChart:(HCSPieChartView *)pieChart {
    return 8;
}

- (CGFloat)pieChart:(HCSPieChartView *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    return [self.valueArray[index] floatValue];
}

- (NSString *)pieChart:(HCSPieChartView *)pieChart nameOfLegendAtIndex:(NSUInteger)index {
    return self.legendsArray[index];
}

- (UIColor *)pieChart:(HCSPieChartView *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    return [self colorForIndex:index];
}

- (UIColor *)pieChart:(HCSPieChartView *)pieChart colorForLegendAtIndex:(NSUInteger)index {
    return [self colorForIndex:index];
}

- (void)pieChart:(HCSPieChartView *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
}

- (void)pieChart:(HCSPieChartView *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
}

- (UIColor *)colorForIndex:(NSUInteger)index {
    switch (index) {
        case 0:
            return PCColorYellow;
        case 1:
            return PCColorRed;
        case 2:
            return PCColorOrange;
        case 3:
            return PCColorGreen;
        case 4:
            return PCColorBlue;
        case 5:
            return PCColorYellow;
        case 6:
            return PCColorRed;
        case 7:
            return PCColorOrange;
        case 8:
            return PCColorGreen;
        case 9:
            return PCColorBlue;
        default:
            return PCColorDefault;
            
    }
}

@end
