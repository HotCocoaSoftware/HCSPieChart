//
//  HCSPieChartLine.h
//  HCSPieChart
//
//  Created by Aseem Aggarwal on 12/30/14.
//  Copyright (c) 2014 Aseem Aggarwal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HCSPieChartLine : NSObject

- (id)initLineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;
- (id)initUpperLineWithRect:(CGRect)frame;
- (id)initLowerLineWithRect:(CGRect)frame;
- (CGPoint)intersectionPointFromLine:(HCSPieChartLine *)line;
@property (nonatomic) CGFloat m;
@property (nonatomic) CGFloat c;

@end
