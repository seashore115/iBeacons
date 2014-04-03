//
//  XHWaterDropRefresh.h
//  XHPathCover
//
//  Created by Apple on 14-2-7.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHWaterDropRefresh : UIView

@property (nonatomic, assign) CGFloat radius; // default is 5.
@property (nonatomic, assign) CGFloat maxOffset; // default is 70
@property (nonatomic, assign) CGFloat deformationLength; // default is 0.4 (between 0.1 -- 0.9)
@property (nonatomic, assign) CGFloat offsetHeight;
@property (nonatomic, strong) UIImage *refreshCircleImage;
@property (nonatomic, readonly) BOOL isRefreshing;

- (void)stopRefresh;
- (void)startRefreshAnimation;

@property (nonatomic, copy) void(^handleRefreshEvent)(void) ;
@property (nonatomic) float currentOffset;

@end
