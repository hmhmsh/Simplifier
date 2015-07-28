//
//  PathSimplifier.h
//  Simplifier
//
//  Created by 長谷川瞬哉 on 2015/06/24.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PathSimplifier : NSObject

@property (retain, nonatomic) NSMutableArray* curves;
-(id)initWithPoints:(NSMutableArray*)points;
-(CGMutablePathRef)simplify;
-(NSMutableArray*)simplifyGetCurve;
-(void)fitCubicWithfirst:(int)first last:(int)last tan1:(CGPoint)tan1 tan2:(CGPoint)tan2;
-(void)addCurveWithcurve:(NSMutableArray*)curve;
-(NSMutableArray *)chordLengthParameterizeWithFirst:(int)first last:(int)last;
-(NSMutableArray*)generateBezierWithFirst:(int)first last:(int)last uPrime:(NSMutableArray*)uPrime tan1:(CGPoint)tan1 tan2:(CGPoint)tan2;
-(void)findMaxErrorWithFirst:(int)first last:(int)last curve:(NSMutableArray*)curve u:(NSArray*)u;
-(CGPoint)evaluateWithdegree:(int)degree curve:(NSMutableArray*)curve t:(CGFloat)t;
-(void)reparameterizeWithFirst:(int)first last:(int)last u:(NSMutableArray*)u curve:(NSMutableArray*)curve;
-(CGFloat)findRootWithCurve:(NSMutableArray*)curve point:(CGPoint)point u:(CGFloat)u;
@end

@interface PathSimplifier(CGPointExt)
-(CGPoint)addWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
-(CGPoint)addWithPoint1:(CGPoint)point1 n:(CGFloat)n;
-(CGPoint)subtractWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
-(CGPoint)subtractWithPoint1:(CGPoint)point1 n:(CGFloat)n;
-(CGPoint)multiplyWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
-(CGPoint)multiplyWithPoint1:(CGPoint)point1 n:(CGFloat)n;
-(CGPoint)divideWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
-(CGPoint)divideWithPoint1:(CGPoint)point1 n:(CGFloat)n;
-(CGPoint)negateWithPoint1:(CGPoint)point1;
-(CGPoint)normalizeWithPoint1:(CGPoint)point1;
-(CGPoint)normalizeWithPoint1:(CGPoint)point1 d:(CGFloat)d;
-(CGFloat)dotWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
-(CGFloat)distanceWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;
@end