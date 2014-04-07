//
//  XYAlertViewHeader.h
//
//  Created by Apple on 7/27/12.
//  Copyright (c) 2012 meng.wang. All rights reserved.
//

#ifndef XYAlertViewDemo_XYAlertViewHeader_h
#define XYAlertViewDemo_XYAlertViewHeader_h

#import "XYAlertView.h"
#import "XYLoadingView.h"
#import "XYAlertViewManager.h"

#define XYShowAlert(_MSG_) [[XYAlertViewManager sharedAlertViewManager] showAlertView:_MSG_]
#define XYShowLoading(_MSG_) [[XYAlertViewManager sharedAlertViewManager] showLoadingView:_MSG_]

#endif
