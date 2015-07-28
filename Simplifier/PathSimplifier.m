//
//  PathSimplifier.m
//  Simplifier
//
//  Created by 長谷川瞬哉 on 2015/06/24.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

#import "PathSimplifier.h"
#define TOLERANCE 1e-6
#define EPSILON 1e-12


@implementation PathSimplifier(CGPointExt)

-(CGPoint)addWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  return CGPointMake(point1.x+point2.x, point1.y+point2.y);
}
-(CGPoint)addWithPoint1:(CGPoint)point1 n:(CGFloat)n
{
  return CGPointMake(point1.x+n, point1.y+n);
}

-(CGPoint)subtractWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  return CGPointMake(point1.x-point2.x, point1.y-point2.y);
}
-(CGPoint)subtractWithPoint1:(CGPoint)point1 n:(CGFloat)n
{
  return CGPointMake(point1.x-n, point1.y-n);
}

-(CGPoint)multiplyWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  return CGPointMake(point1.x*point2.x, point1.y*point2.y);
}
-(CGPoint)multiplyWithPoint1:(CGPoint)point1 n:(CGFloat)n
{
  return CGPointMake(point1.x*n, point1.y*n);
}

-(CGPoint)divideWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  return CGPointMake(point1.x/point2.x, point1.y/point2.y);
}
-(CGPoint)divideWithPoint1:(CGPoint)point1 n:(CGFloat)n
{
  return CGPointMake(point1.x/n, point1.y/n);
}

-(CGPoint)negateWithPoint1:(CGPoint)point1
{
  return CGPointMake(-point1.x, -point1.y);
}

-(CGPoint)normalizeWithPoint1:(CGPoint)point1
{
  return [self normalizeWithPoint1:point1 d:1.0];
}
-(CGPoint)normalizeWithPoint1:(CGPoint)point1 d:(CGFloat)d
{
  CGFloat length = sqrt(point1.x*point1.x + point1.y*point1.y);
  CGFloat scale = length > 0 ? d / length : 0;
//  CGFloat scale = d / length;
  return CGPointMake(point1.x*scale, point1.y*scale);
}

-(CGFloat)dotWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  return (point1.x*point2.x + point1.y*point2.y);
}

-(CGFloat)distanceWithPoint1:(CGPoint)point1 point2:(CGPoint)point2
{
  CGPoint d = CGPointMake(point1.x-point2.x, point1.y-point2.y);
  return sqrt(d.x*d.x + d.y*d.y);
}
@end

@interface PathSimplifier()
{
  CGMutablePathRef path_;
  NSMutableArray* points_;
  CGPoint point_;
  CGFloat error_;
  
  CGFloat MaxErrorError_;
  int MaxErrorIndex_;
}
@end

@implementation PathSimplifier

-(id)initWithPoints:(NSMutableArray*)points
{
  self = [super init];
  if (self != nil) {
    path_ = CGPathCreateMutable();
    points_ = [[points mutableCopy] retain];
    error_ = 100;
    self.curves = [NSMutableArray array];
  }
  return self;
  
}

-(void)dealloc{
  [points_ release];
  [super dealloc];
}

-(CGMutablePathRef)simplify
{
  NSUInteger length = [points_ count];
  if (length > 1) {
    [self fitCubicWithfirst:0
                       last:(int)length -1
                       tan1:[self normalizeWithPoint1:[self subtractWithPoint1:[points_[1] CGPointValue]
                                                                        point2:[points_[0] CGPointValue]]]
                       tan2:[self normalizeWithPoint1:[self subtractWithPoint1:[points_[length - 2] CGPointValue]
                                                                        point2:[points_[(int)length - 1] CGPointValue]]]
     ];
  }
  return path_;
}

-(NSMutableArray*)simplifyGetCurve
{
  NSUInteger length = [points_ count];
  if (length > 1) {
    [self fitCubicWithfirst:0
                       last:(int)length -1
                       tan1:[self normalizeWithPoint1:[self subtractWithPoint1:[points_[1] CGPointValue]
                                                                        point2:[points_[0] CGPointValue]]]
                       tan2:[self normalizeWithPoint1:[self subtractWithPoint1:[points_[length - 2] CGPointValue]
                                                                        point2:[points_[(int)length - 1] CGPointValue]]]
     ];
  }
  return self.curves;
}


-(void)fitCubicWithfirst:(int)first last:(int)last tan1:(CGPoint)tan1 tan2:(CGPoint)tan2
{
  if (last - first == 1) {
    CGPoint pt1 = [points_[first] CGPointValue];
    CGPoint pt2 = [points_[last] CGPointValue];
    CGFloat dist = [self distanceWithPoint1:pt1 point2:pt2] / 3;
    if (dist > 0) {
      [self addCurveWithcurve:[@[[NSValue valueWithCGPoint:pt1],
                                 [NSValue valueWithCGPoint:[self addWithPoint1:pt1 point2:[self normalizeWithPoint1:tan1 d:dist]]],
                                 [NSValue valueWithCGPoint:[self addWithPoint1:pt2 point2:[self normalizeWithPoint1:tan2 d:dist]]],
                                 [NSValue valueWithCGPoint:pt2]] mutableCopy]];
    }
    else {
      [self addCurveWithcurve:[@[[NSValue valueWithCGPoint:pt1],
                                 [NSValue valueWithCGPoint:pt1],
                                 [NSValue valueWithCGPoint:pt2],
                                 [NSValue valueWithCGPoint:pt2]] mutableCopy]];
    }
    return;
  }
  NSMutableArray* uPrime = [self chordLengthParameterizeWithFirst:first last:last];
  CGFloat maxError = MAX(error_, error_*error_);
  int split = 0;
  
  for (int i = 0; i <= 4; i++) {
    NSMutableArray* curve = [self generateBezierWithFirst:first last:last uPrime:uPrime tan1:tan1 tan2:tan2];
    [self findMaxErrorWithFirst:first last:last curve:curve u:uPrime];
    if (MaxErrorError_ < error_) {
      [self addCurveWithcurve:curve];
      return;
    }
    split = MaxErrorIndex_;
    if (MaxErrorError_ >= maxError) {
      break;
    }
    [self reparameterizeWithFirst:first last:last u:uPrime curve:curve];
    maxError = MaxErrorError_;
  }
  CGPoint V1 = [self subtractWithPoint1:[points_[split-1] CGPointValue] point2:[points_[split] CGPointValue]];
  CGPoint V2 = [self subtractWithPoint1:[points_[split] CGPointValue] point2:[points_[split+1] CGPointValue]];
  CGPoint tanCenter = [self normalizeWithPoint1:[self divideWithPoint1:[self addWithPoint1:V1
                                                                                    point2:V2]
                                                                     n:2]];
  [self fitCubicWithfirst:first last:split tan1:tan1 tan2:tanCenter];
  [self fitCubicWithfirst:split last:last tan1:[self negateWithPoint1:tanCenter] tan2:tan2];
}

-(void)addCurveWithcurve:(NSMutableArray*)curve
{
  NSMutableDictionary* dictionary0 = [NSMutableDictionary dictionary];
  NSMutableDictionary* dictionary1 = [NSMutableDictionary dictionary];
  NSMutableDictionary* dictionary2 = [NSMutableDictionary dictionary];
  NSMutableDictionary* dictionary3 = [NSMutableDictionary dictionary];
  if (CGPathIsEmpty(path_)) {
    CGPathMoveToPoint(path_, nil, [curve[0] CGPointValue].x, [curve[0] CGPointValue].y);
    [dictionary0 setObject:[NSNumber numberWithFloat:[curve[0] CGPointValue].x] forKey:@"x"];
    [dictionary0 setObject:[NSNumber numberWithFloat:[curve[0] CGPointValue].y] forKey:@"y"];
    [self.curves addObject:dictionary0];
  }
  CGPathAddCurveToPoint(path_, nil,
                        floorf([curve[1] CGPointValue].x), floorf([curve[1] CGPointValue].y),
                        floorf([curve[2] CGPointValue].x), floorf([curve[2] CGPointValue].y),
                        [curve[3] CGPointValue].x, [curve[3] CGPointValue].y);
  
  [dictionary1 setObject:[NSNumber numberWithDouble:[curve[1] CGPointValue].x] forKey:@"x"];
  [dictionary1 setObject:[NSNumber numberWithDouble:[curve[1] CGPointValue].y] forKey:@"y"];
  [self.curves addObject:dictionary1];
  [dictionary2 setObject:[NSNumber numberWithDouble:[curve[2] CGPointValue].x] forKey:@"x"];
  [dictionary2 setObject:[NSNumber numberWithDouble:[curve[2] CGPointValue].y] forKey:@"y"];
  [self.curves addObject:dictionary2];
  [dictionary3 setObject:[NSNumber numberWithFloat:[curve[3] CGPointValue].x] forKey:@"x"];
  [dictionary3 setObject:[NSNumber numberWithFloat:[curve[3] CGPointValue].y] forKey:@"y"];
  [self.curves addObject:dictionary3];
  //    [self.curves addObject:curve];
}

-(NSMutableArray *)chordLengthParameterizeWithFirst:(int)first last:(int)last
{
  NSMutableArray* dummyMutableArray = [NSMutableArray array];
  dummyMutableArray[0] = @0.0f;
  for (int i = first+1; i <= last; i++) {
    dummyMutableArray[i-first] = [NSNumber numberWithFloat:[dummyMutableArray[i-first-1] floatValue]
                                  +[self distanceWithPoint1:[points_[i] CGPointValue]
                                                     point2:[points_[i-1] CGPointValue]]];
  }
  for (int i = 1, m = last-first; i <= m; i++) {
    [dummyMutableArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[dummyMutableArray objectAtIndex:i] floatValue] / [[dummyMutableArray objectAtIndex:m] floatValue]]];
  }
  return dummyMutableArray;
}

-(NSMutableArray*)generateBezierWithFirst:(int)first last:(int)last uPrime:(NSMutableArray*)uPrime tan1:(CGPoint)tan1 tan2:(CGPoint)tan2
{
  CGFloat epsilon = EPSILON;
  CGPoint pt1 = [points_[first] CGPointValue];
  CGPoint pt2 = [points_[last] CGPointValue];
  CGFloat C[2][2];
  C[0][0] = 0; C[0][1] = 0; C[1][0] = 0; C[1][1] = 0;
  CGFloat X[2];
  X[0] = 0; X[1] = 0;
  
  for (int i = 0, l = last - first + 1; i < l; i++) {
    CGFloat u = [uPrime[i] floatValue];
    CGFloat t = 1 - u;
    CGFloat b = 3 * u * t;
    CGFloat b0 = t * t * t;
    CGFloat b1 = b * t;
    CGFloat b2 = b * u;
    CGFloat b3 = u * u * u;
    CGPoint a1 = [self normalizeWithPoint1:tan1 d:b1];
    CGPoint a2 = [self normalizeWithPoint1:tan2 d:b2];
    CGPoint tmp = [self subtractWithPoint1:[self subtractWithPoint1:[points_[first+1] CGPointValue]
                                                             point2:[self multiplyWithPoint1:pt1 n:(b0+b1)]]
                                    point2:[self multiplyWithPoint1:pt2 n:(b2+b3)]];
    C[0][0] += [self dotWithPoint1:a1 point2:a1];
    C[0][1] += [self dotWithPoint1:a1 point2:a2];
    C[1][0] = C[0][1];
    C[1][1] += [self dotWithPoint1:a2 point2:a2];
    X[0] += [self dotWithPoint1:a1 point2:tmp];
    X[1] += [self dotWithPoint1:a2 point2:tmp];
  }
  
  CGFloat detC0C1 = C[0][0] * C[1][1] - C[1][0] * C[0][1];
  CGFloat alpha1 = 0;
  CGFloat alpha2 = 0;
  if (fabs(detC0C1) > epsilon) {
    CGFloat detC0X = C[0][0] * X[1] - C[1][0] * X[0];
    CGFloat detXC1 = X[0] * C[1][1] - X[1] * C[0][1];
    alpha1 = detXC1 / detC0C1;
    alpha2 = detC0X / detC0C1;
  }
  else{
    CGFloat c0 = C[0][0] + C[0][1];
    CGFloat c1 = C[1][0] + C[1][1];
    if (fabs(c0) > epsilon) {
      alpha1 = alpha2 = X[0] / c0;
    }
    else if (fabs(c1) > epsilon){
      alpha1 = alpha2 = X[1] / c1;
    }
    else{
      alpha1 = alpha2 = 0;
    }
  }
  
  CGFloat segLength = [self distanceWithPoint1:pt2 point2:pt1];
  epsilon *= segLength;
  if (alpha1 < epsilon || alpha2 < epsilon) {
    alpha1 = alpha2 = segLength / 3;
  }
  
  return [@[[NSValue valueWithCGPoint:pt1],
            [NSValue valueWithCGPoint:[self addWithPoint1:pt1 point2:[self normalizeWithPoint1:tan1 d:alpha1]]],
            [NSValue valueWithCGPoint:[self addWithPoint1:pt2 point2:[self normalizeWithPoint1:tan2 d:alpha2]]],
            [NSValue valueWithCGPoint:pt2]] mutableCopy];
}

-(void)findMaxErrorWithFirst:(int)first last:(int)last curve:(NSMutableArray*)curve u:(NSArray*)u
{
  double half = (last - first + 1) * 0.5;
  MaxErrorIndex_ = floor(half);
  MaxErrorError_ = 0;
  for (int i = first+1; i < last; i++) {
    CGPoint P = [self evaluateWithdegree:3 curve:curve t:[u[i - first] floatValue]];
    CGPoint v = [self subtractWithPoint1:P point2:[points_[i] CGPointValue]];
    CGFloat dist = v.x*v.x + v.y*v.y;
    if (dist >= MaxErrorError_) {
      MaxErrorError_ = dist;
      MaxErrorIndex_ = i;
    }
  }
}

//　評価
-(CGPoint)evaluateWithdegree:(int)degree curve:(NSMutableArray*)curve t:(CGFloat)t
{
  NSMutableArray* tmp = [curve mutableCopy];
  for (int i = 1; i <= degree; i++) {
    for (int j = 0; j <= degree - i; j++) {
      //            curve[j] = [NSValue valueWithCGPoint:[self addWithPoint1:[self multiplyWithPoint1:[curve[j] CGPointValue] n:1-t]
      //                                                              point2:[self multiplyWithPoint1:[curve[j+1] CGPointValue] n:t]]];
      tmp[j] = [NSValue valueWithCGPoint:[self addWithPoint1:[self multiplyWithPoint1:[tmp[j] CGPointValue] n:1-t]
                                                      point2:[self multiplyWithPoint1:[tmp[j+1] CGPointValue] n:t]]];
    }
  }
  return [tmp[0] CGPointValue];
}

-(void)reparameterizeWithFirst:(int)first last:(int)last u:(NSMutableArray*)u curve:(NSMutableArray*)curve
{
  for (int i = first; i <= last; i++) {
    u[i-first] = [NSNumber numberWithFloat:[self findRootWithCurve:curve point:[points_[i] CGPointValue] u:[u[i-first] floatValue]]];
  }
}

-(CGFloat)findRootWithCurve:(NSMutableArray*)curve point:(CGPoint)point u:(CGFloat)u
{
  NSMutableArray* curve1 = [NSMutableArray array];
  NSMutableArray* curve2 = [NSMutableArray array];
  for (int i = 0; i <= 2; i++) {
    [curve1 addObject:[NSValue valueWithCGPoint:[self multiplyWithPoint1:[self subtractWithPoint1:[curve[i+1] CGPointValue]
                                                                                           point2:[curve[i] CGPointValue]]
                                                                       n:3]]];
  }
  for (int i = 0; i <= 1; i++) {
    [curve2 addObject:[NSValue valueWithCGPoint:[self multiplyWithPoint1:[self subtractWithPoint1:[curve1[i+1] CGPointValue]
                                                                                           point2:[curve1[i] CGPointValue]]
                                                                       n:2]]];
  }
  CGPoint pt = [self evaluateWithdegree:3 curve:curve t:u];
  CGPoint pt1 = [self evaluateWithdegree:2 curve:curve1 t:u];
  CGPoint pt2 = [self evaluateWithdegree:1 curve:curve2 t:u];
  CGPoint diff = [self subtractWithPoint1:pt point2:point];
  CGFloat df = [self dotWithPoint1:pt1 point2:pt1] + [self dotWithPoint1:diff point2:pt2];
  if (fabs(df) < TOLERANCE) {
    return u;
  }
  return u - [self dotWithPoint1:diff point2:pt1] / df;
}

@end
