//
//  XHSoundManager.m
//  XHPathCover
//
//  Created by Apple on 14-2-7.
//  Copyright (c) meng.wang. All rights reserved.
//

#import "XHSoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface XHSoundManager () {
    SystemSoundID refreshSound;
}

@end

@implementation XHSoundManager

+ (instancetype)sharedInstance {
    static XHSoundManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XHSoundManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"pullrefresh" withExtension:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url) , &refreshSound);
    }
    return self;
}

- (void)playRefreshSound {
    AudioServicesPlaySystemSound(refreshSound);
}

@end
