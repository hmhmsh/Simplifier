//
//  ViewController.h
//  Simplifier
//
//  Created by 長谷川瞬哉 on 2015/06/24.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathSimplifier.h"

@interface view : CALayer
@property (nonatomic) CGMutablePathRef path;
@property (nonatomic) CGMutablePathRef path1;
@property (strong, nonatomic) NSMutableArray* array;
@end

@interface ViewController : UIViewController


@end

