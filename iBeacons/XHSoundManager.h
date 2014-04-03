//
//  XHSoundManager.h
//  XHPathCover
//
//  Created by Apple on 14-2-7.
//  Copyright (c) meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHSoundManager : NSObject

+ (instancetype)sharedInstance;

- (void)playRefreshSound;

@end
