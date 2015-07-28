//
//  ViewController.m
//  Simplifier
//
//  Created by 長谷川瞬哉 on 2015/06/24.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

#import "ViewController.h"

@interface view()
@end

@implementation view

- (id)init
{
  self = [super init];
  if (self != nil) {
    _path = CGPathCreateMutable();
    _path1 = CGPathCreateMutable();
  }
  return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
//  CGMutablePathRef path = CGPathCreateMutable();
  
  CGImageRef image = [UIImage imageNamed:@"100837s.jpg"].CGImage;
  CGContextDrawImage(ctx, self.frame, image);

  // 線の色を指定
  CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5] CGColor]);
  CGContextSetLineWidth(ctx, 30);
  // 線の描画開始座標をセット
  
  CGContextAddPath(ctx, _path);
  CGContextAddPath(ctx, _path1);
  // 描画の開始～終了座標まで線を引く
  CGContextStrokePath(ctx);
 
}


@end
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  view* v = [[view alloc]init];
  v.frame = CGRectMake(0, 0, 300, 300);
  v.backgroundColor = [UIColor whiteColor].CGColor;
  [self.view.layer addSublayer:v];
  
  
//  CGPathMoveToPoint(v.path, nil, 0, 0);
//  CGPathAddLineToPoint(v.path, nil, 100, 100);
//  CGPathAddLineToPoint(v.path, nil, 200, 200);
//  CGPathAddLineToPoint(v.path, nil, 300, 300);

//  CGPathMoveToPoint(v.path1, nil, 300, 0);
//  CGPathAddLineToPoint(v.path, nil, 200, 100);
//  CGPathAddLineToPoint(v.path, nil, 100, 200);
//  CGPathAddLineToPoint(v.path, nil, 0, 300);
  
  CGPathMoveToPoint(v.path, nil, 0, 0);
  CGPathAddCurveToPoint(v.path, nil, 100, 100, 200, 200, 300, 300);
  //下
  CGPathAddCurveToPoint(v.path, nil, 200, 200, 100, 200, 0, 300);
  CGPathAddCurveToPoint(v.path, nil, 100, 200, 200, 100, 300, 0);
  //上
  CGPathAddCurveToPoint(v.path, nil, 200, 100, 100, 100, 0, 0);
  //左
  CGPathAddCurveToPoint(v.path, nil, 100, 100, 100, 200, 0, 300);
  //右
  CGPathMoveToPoint(v.path, nil, 300, 0);
  CGPathAddCurveToPoint(v.path, nil, 200, 100, 200, 200, 300, 300);

  
//  CGFloat x = [[NSString stringWithFormat:@"%.5lf", 0.1234789] floatValue];
//  CGFloat y = [[NSString stringWithFormat:@"%.5lf", 0.123456789] floatValue];
//  NSLog(@"x:%lf y:%f", x, y);
  
  CGFloat x = 0.1234789;
  int xINT = x * 100000;
  CGFloat xFLOATMISS = xINT / 100000.0;
  CGFloat xFLOAT = xINT;
  xFLOAT /= 100000;
  double xDOUBLE = xINT/ 100000.0;
//  xDOUBLE /= 100000;
  NSLog(@"xINT:%d MISS:%lf xFLOAT:%lf", xINT, xFLOATMISS, xFLOAT);

//  [self simple:v];
  
  [v setNeedsDisplay];

}

- (void)simple:(view*)v
{
  NSMutableArray* point = [[NSMutableArray alloc]init];
  int index = 0;
  switch (index) {
    case 0:
      [point addObject:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
      [point addObject:[NSValue valueWithCGPoint:CGPointMake(100, 100)]];
      [point addObject:[NSValue valueWithCGPoint:CGPointMake(150, 200)]];
      [point addObject:[NSValue valueWithCGPoint:CGPointMake(200, 200)]];
      [point addObject:[NSValue valueWithCGPoint:CGPointMake(200, 150)]];
      break;
    case 1:
      [point addObject:NSStringFromCGPoint(CGPointMake(0.1, 0.1))];
      [point addObject:NSStringFromCGPoint(CGPointMake(0.1, 0.1))];
      [point addObject:NSStringFromCGPoint(CGPointMake(0.1, 0.1))];
      [point addObject:NSStringFromCGPoint(CGPointMake(0.1, 0.1))];
      [point addObject:NSStringFromCGPoint(CGPointMake(0.1, 0.1))];
      break;
      
    default:
      break;
  }
  
  
  
  NSLog(@"new:%@", point);
  
  PathSimplifier* simplifier = [[[PathSimplifier alloc] initWithPoints:point]autorelease];
  v.path = [simplifier simplify];
 
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
