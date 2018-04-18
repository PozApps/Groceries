//
//  TransitionAnimator.h
//  Groceries
//
//  Created by Nadav Pozmantir on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property CGRect originFrame;
@property (nonatomic, readonly) NSInteger duration;
@property BOOL presenting;
@property (nonatomic, copy) void (^dismissCompletion)(void);

@end
