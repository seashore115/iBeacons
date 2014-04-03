//
//  UIColor+RGBValues.h
//  LDBarButtonItemExample
//
//  Created by Apple on 1/24/13.
//  Copyright (c) 2013 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGBValues)

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;

- (UIColor *)darkerColor;
- (UIColor *)lighterColor;
- (BOOL)isLighterColor;
- (BOOL)isClearColor;

@end
