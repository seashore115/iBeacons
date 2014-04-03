//
//  LDProgressView.h
//  LDProgressView
//
//  Created by Apple on 9/27/13.
//  Copyright (c) 2013 meng.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LDProgressStripes,
    LDProgressGradient,
    LDProgressSolid
} LDProgressType;

@interface LDProgressView : UIView

@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) UIColor *color UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *flat UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *animate UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showText UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *borderRadius UI_APPEARANCE_SELECTOR;

@property (nonatomic) LDProgressType type;

@end
