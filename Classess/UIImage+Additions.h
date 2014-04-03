//
//  UIImage+Additions.h
//  FlatUIlikeiOS7
//
//  Created by Apple on 11.06.2013.
//  Copyright (c) 2013 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andRoundSize:(CGFloat)roundSize;
@end
