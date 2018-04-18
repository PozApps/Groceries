//
//  TransitionAnimator.m
//  Groceries
//
//  Created by Nadav Pozmantir on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "TransitionAnimator.h"

static CGFloat const TransitionDuration = 1.0;

@implementation TransitionAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = TransitionDuration;
        self.presenting = YES;
        self.originFrame = CGRectZero;
    }
    return self;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *itemView = self.presenting ? toView : [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect initialFrame = self.presenting ? self.originFrame : itemView.frame;
    CGRect finalFrame = self.presenting ? itemView.frame : self.originFrame;
    
    CGFloat xScaleFactor = self.presenting ? initialFrame.size.width / finalFrame.size.width : finalFrame.size.width / initialFrame.size.width;
    CGFloat yScaleFactor = self.presenting ? initialFrame.size.height / finalFrame.size.height : finalFrame.size.height / initialFrame.size.height;

    CGAffineTransform scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, xScaleFactor, yScaleFactor);
    if (self.presenting) {
        itemView.transform = scaleTransform;
        itemView.center = CGPointMake(CGRectGetMidX(initialFrame), CGRectGetMidY(initialFrame));
        itemView.clipsToBounds = YES;
    }
    
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:itemView];

    [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:0.0 options:
     UIViewAnimationOptionLayoutSubviews animations:^{
        itemView.transform = self.presenting ? CGAffineTransformIdentity : scaleTransform;
        itemView.center = CGPointMake(CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame));
    } completion:^(BOOL finished) {
        if (!self.presenting) {
            self.dismissCompletion();
        }
        [transitionContext completeTransition:YES];
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end
