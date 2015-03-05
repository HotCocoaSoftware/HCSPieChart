//
//  XYPieChart.m
//  XYPieChart
//
//  Created by XY Feng on 2/24/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "XYPieChart.h"
#import <QuartzCore/QuartzCore.h>
#import "MTGeometry.h"
#import "HCSPieChartLine.h"

#define RAD2DEG(radians) ((radians) * (180.0 / M_PI))
#define DEG2RAD( degrees ) (( degrees ) / 180.0 * M_PI)

@interface SliceLayer : CAShapeLayer

@property (nonatomic, assign) CGFloat   value;
@property (nonatomic, assign) CGFloat   percentage;
@property (nonatomic, assign) double    startAngle;
@property (nonatomic, assign) double    endAngle;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, strong) NSString  *text;

- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to Delegate:(id)delegate;

@end

@implementation SliceLayer

@synthesize text = _text;
@synthesize value = _value;
@synthesize percentage = _percentage;
@synthesize startAngle = _startAngle;
@synthesize endAngle = _endAngle;
@synthesize isSelected = _isSelected;

- (NSString*)description
{
    return [NSString stringWithFormat:@"value:%f, percentage:%0.0f, start:%f, end:%f", _value, _percentage, _startAngle/M_PI*180, _endAngle/M_PI*180];
}
+ (BOOL)needsDisplayForKey:(NSString *)key 
{
    if ([key isEqualToString:@"startAngle"] || [key isEqualToString:@"endAngle"]) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:key];
    }
}
- (id)initWithLayer:(id)layer
{
    if (self = [super initWithLayer:layer])
    {
        if ([layer isKindOfClass:[SliceLayer class]]) {
            self.startAngle = [(SliceLayer *)layer startAngle];
            self.endAngle = [(SliceLayer *)layer endAngle];
        }
    }
    return self;
}
- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to Delegate:(id)delegate
{
    CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:key];
    NSNumber *currentAngle = [[self presentationLayer] valueForKey:key];
    if(!currentAngle) currentAngle = from;
    [arcAnimation setFromValue:currentAngle];
    [arcAnimation setToValue:to];         
    [arcAnimation setDelegate:delegate];
    [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self addAnimation:arcAnimation forKey:key];
    [self setValue:to forKey:key];
}
@end

@interface XYPieChart (Private)

- (void)updateTimerFired:(NSTimer *)timer;
- (SliceLayer *)createSliceLayer;
- (CGSize)sizeThatFitsString:(NSString *)string;
- (void)updateTextLayerInsideSliceLayer:(SliceLayer *)pieLayer value:(CGFloat)value;
- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection;

@end

@implementation XYPieChart
{
    NSInteger _selectedSliceIndex;

    //pie view, contains all slices
    UIView  *_pieView;
    
    //animation control
    NSTimer *_animationTimer;
    NSMutableArray *_animations;
}

static NSUInteger kDefaultSliceZOrder = 100;

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize startPieAngle = _startPieAngle;
@synthesize animationSpeed = _animationSpeed;
@synthesize pieCenter = _pieCenter;
@synthesize pieRadius = _pieRadius;
@synthesize showInsideSliceLabel = _showInsideSliceLabel;
@synthesize insideSliceLabelFont = _insideSliceLabelFont;
@synthesize insideSliceLabelColor = _insideSliceLabelColor;
@synthesize insideSliceLabelShadowColor = _insideSliceLabelShadowColor;
@synthesize insideSliceLabelRadius = _insideSliceLabelRadius;
@synthesize showOutsideSliceLabel = _showOutsideSliceLabel;
@synthesize outsideSliceLabelColor = _outsideSliceLabelColor;
@synthesize outsideSliceLabelFont = _outsideSliceLabelFont;
@synthesize outsideSliceLabelShadowColor = _outsideSliceLabelShadowColor;
@synthesize selectedSliceStroke = _selectedSliceStroke;
@synthesize selectedSliceOffsetRadius = _selectedSliceOffsetRadius;
@synthesize showPercentage = _showPercentage;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _pieView = [[UIView alloc] initWithFrame:frame];
        [_pieView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_pieView];
        
        _selectedSliceIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        
        _animationSpeed = 0.5;
        _startPieAngle = M_PI_2*3;
        _selectedSliceStroke = 3.0;
        
        self.pieRadius = MIN(frame.size.width/2, frame.size.height/2) - 10;
        self.pieCenter = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.insideSliceLabelFont = [UIFont boldSystemFontOfSize:MAX((int)self.pieRadius/10, 5)];
        self.outsideSliceLabelFont = [UIFont boldSystemFontOfSize:12];
        _insideSliceLabelColor = [UIColor whiteColor];
        _outsideSliceLabelColor = [UIColor whiteColor];
        _insideSliceLabelRadius = _pieRadius/2;
        _selectedSliceOffsetRadius = MAX(10, _pieRadius/10);
        
        _showInsideSliceLabel = YES;
        _showPercentage = YES;
        _showOutsideSliceLabel = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Center:(CGPoint)center Radius:(CGFloat)radius
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.pieCenter = center;
        self.pieRadius = radius;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        _pieView = [[UIView alloc] initWithFrame:self.bounds];
        [_pieView setBackgroundColor:[UIColor clearColor]];
        [self insertSubview:_pieView atIndex:0];
        
        _selectedSliceIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        
        _animationSpeed = 0.5;
        _startPieAngle = M_PI_2*3;
        _selectedSliceStroke = 3.0;
        
        CGRect bounds = [[self layer] bounds];
        self.pieRadius = MIN(bounds.size.width/2, bounds.size.height/2) - 10;
        self.pieCenter = CGPointMake(bounds.size.width/2, bounds.size.height/2);
        self.insideSliceLabelFont = [UIFont boldSystemFontOfSize:MAX((int)self.pieRadius/10, 5)];
        self.outsideSliceLabelFont = [UIFont boldSystemFontOfSize:MAX((int)self.pieRadius/10, 5)];
        _insideSliceLabelColor = [UIColor whiteColor];
        _outsideSliceLabelColor = [UIColor whiteColor];
        _insideSliceLabelRadius = _pieRadius/2;
        _selectedSliceOffsetRadius = MAX(10, _pieRadius/10);
        
        _showInsideSliceLabel = YES;
        _showPercentage = YES;
        _showOutsideSliceLabel = YES;
    }
    return self;
}

- (void)setPieCenter:(CGPoint)pieCenter
{
    [_pieView setCenter:pieCenter];
    _pieCenter = CGPointMake(_pieView.frame.size.width/2, _pieView.frame.size.height/2);
}

- (void)setPieRadius:(CGFloat)pieRadius
{
    _pieRadius = pieRadius;
    CGPoint origin = _pieView.frame.origin;
    CGRect frame = CGRectMake(origin.x+_pieCenter.x-pieRadius, origin.y+_pieCenter.y-pieRadius, pieRadius*2, pieRadius*2);
    _pieCenter = CGPointMake(frame.size.width/2, frame.size.height/2);
    [_pieView setFrame:frame];
    [_pieView.layer setCornerRadius:_pieRadius];
}

- (void)setPieBackgroundColor:(UIColor *)color
{
    [_pieView setBackgroundColor:color];
}

#pragma mark - manage settings

- (void)setShowPercentage:(BOOL)showPercentage
{
    _showPercentage = showPercentage;
    for(SliceLayer *layer in _pieView.layer.sublayers)
    {
        CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
        [textLayer setHidden:!_showInsideSliceLabel];
        if(!_showInsideSliceLabel) return;
        NSString *label;
        if(_showPercentage)
            label = [NSString stringWithFormat:@"%0.0f", layer.percentage*100];
        else
            label = (layer.text)?layer.text:[NSString stringWithFormat:@"%0.0f", layer.value];
        CGSize adjustedSize = [label sizeWithAttributes:@{NSFontAttributeName:self.insideSliceLabelFont}];
        CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        
        if(M_PI*2*_insideSliceLabelRadius*layer.percentage < MAX(size.width,size.height))
        {
            [textLayer setString:@""];
        }
        else
        {
            [textLayer setString:label];
            [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
        }
    }
}

- (CGFloat)percentageOfSliceAtIndex:(NSUInteger)index {
    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
    
    return layer.percentage*100;
}

#pragma mark - Pie Reload Data With Animation

- (void)reloadData
{
    if (_dataSource)
    {
        CALayer *parentLayer = [_pieView layer];
        NSArray *slicelayers = [parentLayer sublayers];
        _selectedSliceIndex = -1;
        [slicelayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SliceLayer *layer = (SliceLayer *)obj;
            if(layer.isSelected)
                [self setSliceDeselectedAtIndex:idx];
        }];
        
        double startToAngle = 0.0;
        double endToAngle = startToAngle;
        
        NSUInteger sliceCount = [_dataSource numberOfSlicesInPieChart:self];
        
        double sum = 0.0;
        double values[sliceCount];
        for (int index = 0; index < sliceCount; index++) {
            values[index] = [_dataSource pieChart:self valueForSliceAtIndex:index];
            sum += values[index];
        }
        
        double angles[sliceCount];
        for (int index = 0; index < sliceCount; index++) {
            double div;
            if (sum == 0)
                div = 0;
            else
                div = values[index] / sum; 
            angles[index] = M_PI * 2 * div;
        }

        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationSpeed];
        
        [_pieView setUserInteractionEnabled:NO];
        
        __block NSMutableArray *layersToRemove = nil;
        
        BOOL isOnStart = ([slicelayers count] == 0 && sliceCount);
        NSInteger diff = sliceCount - [slicelayers count];
        layersToRemove = [NSMutableArray arrayWithArray:slicelayers];
        
        BOOL isOnEnd = ([slicelayers count] && (sliceCount == 0 || sum <= 0));
        //Remove layer with animation when slices are present and then we remove it
        if(isOnEnd)
        {
            for(SliceLayer *layer in _pieView.layer.sublayers){
                [self updateTextLayerInsideSliceLayer:layer value:0];
                [self updateTextLayerOutsideSliceLayer:layer text:@""];
                [layer createArcAnimationForKey:@"startAngle"
                                      fromValue:[NSNumber numberWithDouble:_startPieAngle]
                                        toValue:[NSNumber numberWithDouble:_startPieAngle] 
                                       Delegate:self];
                [layer createArcAnimationForKey:@"endAngle" 
                                      fromValue:[NSNumber numberWithDouble:_startPieAngle]
                                        toValue:[NSNumber numberWithDouble:_startPieAngle] 
                                       Delegate:self];
            }
            [CATransaction commit];
            return;
        }
        
        for(int index = 0; index < sliceCount; index ++)
        {
            SliceLayer *layer;
            double angle = angles[index];
            endToAngle += angle;
            double startFromAngle = _startPieAngle + startToAngle;
            double endFromAngle = _startPieAngle + endToAngle;
            
            if( index >= [slicelayers count] )
            {
                layer = [self createSliceLayer];
                if (isOnStart)
                    startFromAngle = endFromAngle = _startPieAngle;
                [parentLayer addSublayer:layer];
                diff--;
            }
            else
            {
                SliceLayer *onelayer = [slicelayers objectAtIndex:index];
                if(diff == 0 || onelayer.value == (CGFloat)values[index])
                {
                    layer = onelayer;
                    [layersToRemove removeObject:layer];
                }
                else if(diff > 0)
                {
                    layer = [self createSliceLayer];
                    [parentLayer insertSublayer:layer atIndex:index];
                    diff--;
                }
                else if(diff < 0)
                {
                    while(diff < 0) 
                    {
                        [onelayer removeFromSuperlayer];
                        [parentLayer addSublayer:onelayer];
                        diff++;
                        onelayer = [slicelayers objectAtIndex:index];
                        if(onelayer.value == (CGFloat)values[index] || diff == 0)
                        {
                            layer = onelayer;
                            [layersToRemove removeObject:layer];
                            break;
                        }
                    }
                }
            }
            
            layer.value = values[index];
            layer.percentage = (sum)?layer.value/sum:0;
            UIColor *color = nil;
            if([_dataSource respondsToSelector:@selector(pieChart:colorForSliceAtIndex:)])
            {
                color = [_dataSource pieChart:self colorForSliceAtIndex:index];
            }
            
            if(!color)
            {
                color = [UIColor colorWithHue:((index/8)%20)/20.0+0.02 saturation:(index%8+3)/10.0 brightness:91/100.0 alpha:1];
            }
            
            [layer setFillColor:color.CGColor];
            if([_dataSource respondsToSelector:@selector(pieChart:textForSliceAtIndex:)])
            {
                NSString *legendText = [_dataSource pieChart:self textForSliceAtIndex:index];
                NSString *percentage = [NSString stringWithFormat:@"%@:%0.0f%%", legendText, layer.percentage*100];
                [self updateTextLayerOutsideSliceLayer:layer text:percentage];
            }
            
            [self updateTextLayerInsideSliceLayer:layer value:values[index]];
            [layer createArcAnimationForKey:@"startAngle"
                                  fromValue:[NSNumber numberWithDouble:startFromAngle]
                                    toValue:[NSNumber numberWithDouble:startToAngle+_startPieAngle] 
                                   Delegate:self];
            [layer createArcAnimationForKey:@"endAngle" 
                                  fromValue:[NSNumber numberWithDouble:endFromAngle]
                                    toValue:[NSNumber numberWithDouble:endToAngle+_startPieAngle] 
                                   Delegate:self];
            startToAngle = endToAngle;
        }
        [CATransaction setDisableActions:YES];
        for(SliceLayer *layer in layersToRemove)
        {
            [layer setFillColor:[self backgroundColor].CGColor];
            [layer setDelegate:nil];
            [layer setZPosition:0];
            CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
            [textLayer setHidden:YES];
        }
        
        [layersToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperlayer];
        }];
        
        [layersToRemove removeAllObjects];
        
        for(SliceLayer *layer in _pieView.layer.sublayers)
        {
            [layer setZPosition:kDefaultSliceZOrder];
        }
        
        [_pieView setUserInteractionEnabled:YES];
        
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    }
}

#pragma mark - Animation Delegate + Run Loop Timer

- (void)updateTimerFired:(NSTimer *)timer;
{   
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];

    [pieLayers.copy enumerateObjectsUsingBlock:^(SliceLayer * obj, NSUInteger idx, BOOL *stop) {
        NSNumber *presentationLayerStartAngle = [[obj presentationLayer] valueForKey:@"startAngle"];
        CGFloat interpolatedStartAngle = [presentationLayerStartAngle doubleValue];
        NSNumber *presentationLayerEndAngle = [[obj presentationLayer] valueForKey:@"endAngle"];
        CGFloat interpolatedEndAngle = [presentationLayerEndAngle doubleValue];
        obj.strokeColor = obj.fillColor;
        CGFloat interpolatedMidAngle = (interpolatedEndAngle + interpolatedStartAngle) / 2;
        UIBezierPath *arcPath = [self createBezierArcPathWithStartAngle:interpolatedStartAngle endAngle:interpolatedEndAngle];
        [obj setPath:arcPath.CGPath];
        {
            [CATransaction setDisableActions:YES];
            [self setPositionOfInsideTextLayerForSliceLayer:obj atAngle:interpolatedMidAngle];
            [CATransaction setDisableActions:NO];
        }
    }];
}

- (void)setPositionOfInsideTextLayerForSliceLayer:(SliceLayer *)layer atAngle:(CGFloat)angle {
    CALayer *labelLayer = [[layer sublayers] objectAtIndex:0];
    [labelLayer setPosition:CGPointMake(_pieCenter.x + (_insideSliceLabelRadius * cos(angle)), _pieCenter.y + (_insideSliceLabelRadius * sin(angle)))];
}

- (UIBezierPath *)createBezierArcPathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    UIBezierPath *piePath = [UIBezierPath bezierPath];
    [piePath moveToPoint:_pieCenter];
    [piePath addArcWithCenter:_pieCenter radius:_pieRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [piePath closePath];
    
    return piePath;
}

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2 {
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (void)addArrowToSlice {
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];
    [pieLayers enumerateObjectsUsingBlock:^(SliceLayer * obj, NSUInteger idx, BOOL *stop) {
        NSNumber *presentationLayerStartAngle = [[obj presentationLayer] valueForKey:@"startAngle"];
        NSNumber *presentationLayerEndAngle = [[obj presentationLayer] valueForKey:@"endAngle"];

        CGFloat startAngle = [presentationLayerStartAngle doubleValue];
        CGFloat endAngle = [presentationLayerEndAngle doubleValue];
        CGFloat midAngle = (endAngle + startAngle) / 2;
        
        obj.strokeColor = obj.fillColor;
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.CGPath = obj.path;
        
        UIBezierPath *arrowPath = [self createBezierArrowPathForSliceLayer:obj withAngle:midAngle];
        [path appendPath:arrowPath];
        [obj setPath:path.CGPath];
        {
            [CATransaction setDisableActions:YES];
            CATextLayer *labelLayer2 = [[obj sublayers] objectAtIndex:1];
            [labelLayer2 setForegroundColor:obj.fillColor];
            [CATransaction setDisableActions:NO];
        }
    }];
}

- (UIBezierPath *)createBezierArrowPathForSliceLayer:(SliceLayer *)layer withAngle:(CGFloat)angleInRadian {
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    CGFloat angleInDegree = RAD2DEG(angleInRadian);
    angleInDegree = [self angleLessThan360:angleInDegree]; // angle between 0 to 360 degree
    CGPoint startPointOnCircumfrence = CGPointMake(_pieCenter.x + (_pieRadius  * cos(angleInRadian)), _pieCenter.y + (_pieRadius  * sin(angleInRadian)));
    [arrowPath moveToPoint:startPointOnCircumfrence];
    
    //find end point for arrow path
    CGPoint centre = [self.superview convertPoint:_pieCenter fromView:self];
    startPointOnCircumfrence = [self.superview convertPoint:startPointOnCircumfrence fromView:self];
    HCSPieChartLine *arrowLine = [[HCSPieChartLine alloc] initLineFromPoint:centre toPoint:startPointOnCircumfrence];
    NSArray *subviewArray = [[[self superview] subviews] mutableCopy];
    UILabel *titleLabel = [subviewArray objectAtIndex:0];
    UIView *legendContainerView = [subviewArray objectAtIndex:2];

    CATextLayer *outsideSliceTextLayer = [[layer sublayers] objectAtIndex:1];
    CGRect outsideSliceTextLayerFrame =  outsideSliceTextLayer.frame;

    CGRect frame = self.frame;
    CGFloat delta = legendContainerView.frame.origin.y + frame.origin.y - frame.size.height;
    
    CGFloat leftLineX = (frame.origin.x - delta >= 0) ? frame.origin.x - delta : outsideSliceTextLayerFrame.size.width;
    HCSPieChartLine *leftWindowLine = [[HCSPieChartLine alloc]
                                       initLineFromPoint:CGPointMake(leftLineX, 0)
                                       toPoint:CGPointMake(leftLineX, 0)];
    
    CGFloat rightLineX = (frame.origin.x + frame.size.width + delta < [UIScreen mainScreen].bounds.size.width) ? frame.origin.x + frame.size.width + delta : [UIScreen mainScreen].bounds.size.width - outsideSliceTextLayerFrame.size.width;
    
    HCSPieChartLine *rightWindowLine = [[HCSPieChartLine alloc]
                                        initLineFromPoint:CGPointMake(rightLineX, 0)
                                        toPoint:CGPointMake(rightLineX, 0)];
    
    HCSPieChartLine *titleLabelLine = [[HCSPieChartLine alloc] initLowerLineWithRect:titleLabel.frame];
    
    HCSPieChartLine *legendContainerLine = [[HCSPieChartLine alloc] initUpperLineWithRect:legendContainerView.frame];
    
    NSArray *lineArray = @[leftWindowLine, rightWindowLine, titleLabelLine, legendContainerLine];
    NSMutableArray *intersectionPointArray = [NSMutableArray array];
    for (HCSPieChartLine *line in lineArray) {
        CGPoint intersectionPoint = [arrowLine intersectionPointFromLine:line];
        [intersectionPointArray addObject:[NSValue valueWithCGPoint:intersectionPoint]];
    }
    
    NSUInteger index = 0;
    CGFloat minDistance = MAXFLOAT;
    NSMutableArray *distanceArray = [NSMutableArray array];
    for (NSValue *val in intersectionPointArray) {
        CGPoint p = [val CGPointValue];
        CGFloat distance = [self distanceFrom:startPointOnCircumfrence to:p];
        [distanceArray addObject:@(distance)];
        if (distance < minDistance) {
            minDistance = distance;
            index = [intersectionPointArray indexOfObject:val];
        }
    }
    
    CGPoint endPoint = [[intersectionPointArray objectAtIndex:index] CGPointValue];
    endPoint = CGPointMake(endPoint.x - (CGRectGetHeight(outsideSliceTextLayerFrame) / 2 * cos(angleInRadian)), endPoint.y - (CGRectGetHeight(outsideSliceTextLayerFrame) / 2  * sin(angleInRadian)));
    if (CGRectContainsPoint(self.frame, endPoint)) {
        endPoint = startPointOnCircumfrence;
    }
    endPoint = [self convertPoint:endPoint fromView:self.superview];

    [arrowPath addLineToPoint:endPoint];
    if (index == 0) {
        endPoint = CGPointMake(endPoint.x - CGRectGetWidth(outsideSliceTextLayerFrame), endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame) / 2);
        outsideSliceTextLayerFrame.origin = endPoint;
        outsideSliceTextLayer.frame = outsideSliceTextLayerFrame;
    } else if (index == 1) {
        endPoint = CGPointMake(endPoint.x, endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame) / 2);
        outsideSliceTextLayerFrame.origin = endPoint;
        outsideSliceTextLayer.frame = outsideSliceTextLayerFrame;
    } else if (index == 2) {
        if (angleInDegree < 270) {
            [arrowPath moveToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - (10  * cos(0)), endPoint.y - (10  * sin(0)));
            [arrowPath addLineToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - CGRectGetWidth(outsideSliceTextLayerFrame), endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame));
        } else {
            [arrowPath moveToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - (10  * cos(M_PI)), endPoint.y - (10  * sin(M_PI)));
            [arrowPath addLineToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x , endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame));
        }
        
        outsideSliceTextLayerFrame.origin = endPoint;
        outsideSliceTextLayer.frame = outsideSliceTextLayerFrame;
    } else {
        if (angleInDegree < 90) {
            [arrowPath moveToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - (10  * cos(M_PI)), endPoint.y - (10  * sin(M_PI)));
            [arrowPath addLineToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x, endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame) / 2);
        } else {
            [arrowPath moveToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - (10  * cos(0)), endPoint.y - (10  * sin(0)));
            [arrowPath addLineToPoint:endPoint];
            endPoint = CGPointMake(endPoint.x - CGRectGetWidth(outsideSliceTextLayerFrame) , endPoint.y - CGRectGetHeight(outsideSliceTextLayerFrame) / 2);
        }
        outsideSliceTextLayerFrame.origin = endPoint;
        outsideSliceTextLayer.frame = outsideSliceTextLayerFrame;
    }
    
    return arrowPath;
}

- (CGFloat)angleLessThan360:(CGFloat)angle {
    if (angle > 360) {
        NSUInteger count = angle / 360;
        return angle - count *(360);
    } else {
        return angle;
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (_animationTimer == nil) {
        static float timeInterval = 1.0/60.0;
        // Run the animation timer on the main thread.
        // We want to allow the user to interact with the UI while this timer is running.
        // If we run it on this thread, the timer will be halted while the user is touching the screen (that's why the chart was disappearing in our collection view).
        _animationTimer= [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
    
    [_animations addObject:anim];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
    [_animations removeObject:anim];
    if ([_animations count] == 0) {
        [_animationTimer invalidate];
        _animationTimer = nil;
        [self addArrowToSlice];
    }
}

#pragma mark - Touch Handing (Selection Notification)

- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CALayer *parentLayer = [_pieView layer];
    NSMutableArray *pieLayers = [[parentLayer sublayers] mutableCopy];
    [pieLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SliceLayer *pieLayer = (SliceLayer *)obj;
        CGPathRef path = [pieLayer path];
        
        if (CGPathContainsPoint(path, &transform, point, 0)) {
//            [pieLayer setLineWidth:_selectedSliceStroke];
//            [pieLayer setStrokeColor:[UIColor redColor].CGColor];
            [pieLayer setLineJoin:kCALineJoinBevel];
            [pieLayer setZPosition:MAXFLOAT];
            selectedIndex = idx;
        } else {
            [pieLayer setZPosition:kDefaultSliceZOrder];
        }
    }];
    
    return selectedIndex;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_pieView];
    [self getCurrentSelectedOnTouch:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_pieView];
    NSInteger selectedIndex = [self getCurrentSelectedOnTouch:point];
    [self notifyDelegateOfSelectionChangeFrom:_selectedSliceIndex to:selectedIndex];
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];

    for (SliceLayer *pieLayer in pieLayers) {
        [pieLayer setZPosition:kDefaultSliceZOrder];
//        [pieLayer setLineWidth:0.0];
    }
}

#pragma mark - Selection Notification

- (void)notifyDelegateOfSelectionChangeFrom:(NSUInteger)previousSelection to:(NSUInteger)newSelection {
    if (previousSelection != newSelection){
        if(previousSelection != -1){
            NSUInteger tempPre = previousSelection;
            if ([_delegate respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)])
                [_delegate pieChart:self willDeselectSliceAtIndex:tempPre];
            [self setSliceDeselectedAtIndex:tempPre];
            previousSelection = newSelection;
            if([_delegate respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)])
                [_delegate pieChart:self didDeselectSliceAtIndex:tempPre];
        }
        
        if (newSelection != -1){
            if([_delegate respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
                [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
            [self setSliceSelectedAtIndex:newSelection];
            _selectedSliceIndex = newSelection;
            if([_delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
                [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
        }
    } else if (newSelection != -1){
        SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:newSelection];
        if(_selectedSliceOffsetRadius > 0 && layer){
            if (layer.isSelected) {
                if ([_delegate respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)])
                    [_delegate pieChart:self willDeselectSliceAtIndex:newSelection];
                [self setSliceDeselectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)])
                    [_delegate pieChart:self didDeselectSliceAtIndex:newSelection];
                previousSelection = _selectedSliceIndex = -1;
            } else {
                if ([_delegate respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
                    [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
                [self setSliceSelectedAtIndex:newSelection];
                previousSelection = _selectedSliceIndex = newSelection;
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
                    [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
            }
        }
    }
}

#pragma mark - Selection With Notification

- (void)selectSlice:(NSInteger)newSelection {
    [self notifyDelegateOfSelectionChangeFrom:_selectedSliceIndex to:newSelection];
}

#pragma mark - Selection Programmatically Without Notification

- (void)setSliceSelectedAtIndex:(NSInteger)index {
    if(_selectedSliceOffsetRadius <= 0)
        return;
    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
    if (layer && !layer.isSelected) {
        CGPoint currPos = layer.position;
        double middleAngle = (layer.startAngle + layer.endAngle)/2.0;
        CGPoint newPos = CGPointMake(currPos.x + _selectedSliceOffsetRadius*cos(middleAngle), currPos.y + _selectedSliceOffsetRadius*sin(middleAngle));
        layer.position = newPos;
        layer.isSelected = YES;
    }
}

- (void)setSliceDeselectedAtIndex:(NSInteger)index {
    if(_selectedSliceOffsetRadius <= 0 || index < 0)
        return;
    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
    if (layer && layer.isSelected) {
        layer.position = CGPointMake(0, 0);
        layer.isSelected = NO;
    }
}

#pragma mark - Pie Layer Creation Method

- (SliceLayer *)createSliceLayer {
    SliceLayer *pieLayer = [SliceLayer layer];
    [pieLayer setZPosition:0];
    [pieLayer addSublayer:[self textLayerWithFont:self.insideSliceLabelFont textColor:self.insideSliceLabelColor shadowColor:self.insideSliceLabelShadowColor]];
    [pieLayer addSublayer:[self textLayerWithFont:self.outsideSliceLabelFont textColor:self.outsideSliceLabelColor shadowColor:self.outsideSliceLabelShadowColor]];
    
    return pieLayer;
}

- (CATextLayer *)textLayerWithFont:(UIFont *)textFont textColor:(UIColor *)textColor shadowColor:(UIColor *)shadowColor {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    CGFontRef font = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        font = CGFontCreateCopyWithVariations((__bridge CGFontRef)(textFont), (__bridge CFDictionaryRef)(@{}));
    } else {
        font = CGFontCreateWithFontName((__bridge CFStringRef)[textFont fontName]);
    }
    if (font) {
        [textLayer setFont:font];
        CFRelease(font);
    }
    
    [textLayer setFontSize:textFont.pointSize];
    [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [textLayer setForegroundColor:textColor.CGColor];
    
    if (shadowColor) {
        [textLayer setShadowColor:shadowColor.CGColor];
        [textLayer setShadowOffset:CGSizeZero];
        [textLayer setShadowOpacity:1.0f];
        [textLayer setShadowRadius:2.0f];
    }
    
    CGSize adjustedSize = [@"0" sizeWithAttributes:@{NSFontAttributeName:self.insideSliceLabelFont}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [CATransaction setDisableActions:NO];
    
    return textLayer;

}

- (void)updateTextLayerOutsideSliceLayer:(SliceLayer *)pieLayer text:(NSString *)text
{
    CATextLayer *textLayer = [[pieLayer sublayers] objectAtIndex:1];
    [textLayer setHidden:!_showOutsideSliceLabel];
    if (!_showOutsideSliceLabel) {
        return;
    }
    CGSize adjustedSize = [text sizeWithAttributes:@{NSFontAttributeName:self.insideSliceLabelFont}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
        
    [CATransaction setDisableActions:YES];
    [textLayer setString:text];
    [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    [CATransaction setDisableActions:NO];
}

- (void)updateTextLayerInsideSliceLayer:(SliceLayer *)pieLayer value:(CGFloat)value
{
    CATextLayer *textLayer = [[pieLayer sublayers] objectAtIndex:0];
    [textLayer setHidden:!_showInsideSliceLabel];
    if(!_showInsideSliceLabel) return;
    NSString *label;
    if(_showPercentage)
        label = [NSString stringWithFormat:@"%0.0f", pieLayer.percentage*100];
    else
        label = (pieLayer.text)?pieLayer.text:[NSString stringWithFormat:@"%0.0f", value];
    
    CGSize adjustedSize = [label sizeWithAttributes:@{NSFontAttributeName:self.insideSliceLabelFont}];
    CGSize size = CGSizeMake(ceilf(adjustedSize.width), ceilf(adjustedSize.height));
    
    [CATransaction setDisableActions:YES];
    if(M_PI*2*_insideSliceLabelRadius*pieLayer.percentage < MAX(size.width,size.height) || value <= 0)
    {
        [textLayer setString:@""];
    }
    else
    {
        [textLayer setString:label];
        [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    }
    [CATransaction setDisableActions:NO];
}

@end
