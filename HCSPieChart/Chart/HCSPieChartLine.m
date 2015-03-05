//
//  HCSPieChartLine.m
//  HCSPieChart
//
//  Created by Aseem Aggarwal on 12/30/14.
//  Copyright (c) 2014 Aseem Aggarwal. All rights reserved.
//

#import "HCSPieChartLine.h"

static CGFloat const kSpaceFromLegend = 10.0f;

@implementation HCSPieChartLine

- (id)initLineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    self = [super init];
    if (self) {
        [self lineFromPoint:point1 toPoint:point2];
    }
    
    return self;
}

- (void)lineFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    CGFloat deltaX = point2.x - point1.x;
    CGFloat deltaY = point2.y - point1.y;
    if (deltaX == 0) {
        self.m = INFINITY;
        self.c = point1.x;
    } else {
        self.m = deltaY / deltaX;
        self.c = point2.y - self.m * point2.x;
    }
}

- (id)initLowerLineWithRect:(CGRect)frame {
    self = [self init];
    if (self) {
        CGPoint point1 = CGPointMake(frame.origin.x, frame.origin.y + CGRectGetHeight(frame));
        CGPoint point2 = CGPointMake(frame.origin.x + CGRectGetWidth(frame), frame.origin.y + CGRectGetHeight(frame));
        [self lineFromPoint:point1 toPoint:point2];
    }
    
    return self;
}

- (id)initUpperLineWithRect:(CGRect)frame {
    self = [self init];
    if (self) {
        CGPoint point1 = CGPointMake(frame.origin.x, frame.origin.y - kSpaceFromLegend);
        CGPoint point2 = CGPointMake(frame.origin.x + CGRectGetWidth(frame), frame.origin.y - kSpaceFromLegend);
        [self lineFromPoint:point1 toPoint:point2];
    }
    
    return self;
}

- (CGPoint)intersectionPointFromLine:(HCSPieChartLine *)line {
    CGPoint intersectionPoint;
    
    if (self.m == line.m) {
        //Parallel lines
        return CGPointMake(INFINITY, INFINITY);
    } else {
        CGFloat deltaSlope = (self.m - line.m);
        if (deltaSlope == INFINITY || deltaSlope == -INFINITY) {
            if (self.m != INFINITY) {
                intersectionPoint.y = self.m * line.c + self.c;
                intersectionPoint.x = line.c;
            } else {
                intersectionPoint.y = line.m * self.c + line.c;
                intersectionPoint.x = self.c;
            }
        } else {
            intersectionPoint.x = (line.c - self.c) / deltaSlope;
            intersectionPoint.y = self.m * intersectionPoint.x + self.c;
        }
    }
    
    return intersectionPoint;
}

@end
