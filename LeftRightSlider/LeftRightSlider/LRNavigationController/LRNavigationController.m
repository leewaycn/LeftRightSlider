//
//  LRNavigationController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-12-9.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//


#import "LRNavigationController.h"

@interface LRNavigationController ()
{
    CGPoint startTouch;
    
    UIView *lastScreenShotView;
    UIView *blackMask;
    
}

@property (nonatomic,retain) UIView *backgroundView;

@property (nonatomic,assign) BOOL isMoving;

@property (nonatomic,retain) UIImage *imgScreenShot;

@end

@implementation LRNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _canDragBack = YES;
        
        _startX=-200;
        _judgeOffset=50;
        _contentScale=1;
    }
    return self;
}

- (void)dealloc
{
#if __has_feature(objc_arc)
    lastScreenShotView=nil;
    blackMask=nil;
    [_backgroundView removeFromSuperview];
    _backgroundView=nil;
    _unGestureDic=nil;
    _imgScreenShot=nil;
#else
    [lastScreenShotView release];
    [blackMask release];
    [_backgroundView release];
    [_unGestureDic release];
    if (_imgScreenShot!=nil) {
        [_imgScreenShot release];
    }
    [super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushViewControllerWithLRAnimated:(UIViewController *)viewController{
    
    if (_isScreenShot) {
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.frame.size, NO, [UIScreen mainScreen].scale);
        [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
        _imgScreenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (_unGestureDic==nil||[_unGestureDic valueForKey:NSStringFromClass([viewController class])]==nil) {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                    action:@selector(paningGestureReceive:)];
        [recognizer delaysTouchesBegan];
        [viewController.view addGestureRecognizer:recognizer];
#if __has_feature(objc_arc)
#else
        [recognizer release];
#endif
    }
    
    [self pushViewController:viewController animated:NO];
    
    _isMoving = YES;
    
    if (!_backgroundView)
    {
        CGRect frame = self.view.frame;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#else
        if (self.navigationBar.translucent||[UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleBlackTranslucent) {
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
        }
        else{
#endif
#if  __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_7_1
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height-([[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0)))];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
#else
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#else
        }
#endif
        blackMask.backgroundColor = [UIColor blackColor];
        [_backgroundView addSubview:blackMask];
    }
    
    _backgroundView.hidden = NO;
    
    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
    
#if __has_feature(objc_arc)
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#else
    if (lastScreenShotView!=nil) {
        [lastScreenShotView release];
        lastScreenShotView=nil;
    }
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#endif
    if (_isScreenShot) {
        [(UIImageView*)lastScreenShotView setImage:_imgScreenShot];
    }
    else{
        [lastScreenShotView addSubview:((UIViewController*)self.viewControllers[[self.viewControllers indexOfObject:self.visibleViewController]-1]).view];
    }
    
    [lastScreenShotView setFrame:CGRectMake(0,
                                            0,
                                            _backgroundView.frame.size.width,
                                            _backgroundView.frame.size.height)];
    
    CGRect frame = self.view.frame;
    frame.origin.x = self.view.frame.size.width;
    self.view.frame = frame;
    
    [_backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [self moveViewWithX:0];
    } completion:^(BOOL finished) {
        _isMoving = NO;
        _backgroundView.hidden = YES;
    }];
    
}

-(void)popViewControllerWithLRAnimated{
    _isMoving = YES;
    
    if (!_backgroundView)
    {
        CGRect frame = self.view.frame;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
        if (self.navigationBar.translucent||[UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleBlackTranslucent) {
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
        }
        else{
#endif
#if  __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_7_1
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
#else
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
        }
#endif
        blackMask.backgroundColor = [UIColor blackColor];
        [_backgroundView addSubview:blackMask];
    }
    
    _backgroundView.hidden = NO;
    
    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
    
#if __has_feature(objc_arc)
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#else
    if (lastScreenShotView!=nil) {
        [lastScreenShotView release];
        lastScreenShotView=nil;
    }
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#endif
    for (UIView *subView in lastScreenShotView.subviews) {
        [subView removeFromSuperview];
    }
    if (_isScreenShot) {
        [(UIImageView*)lastScreenShotView setImage:_imgScreenShot];
    }
    else{
        [lastScreenShotView addSubview:((UIViewController*)self.viewControllers[[self.viewControllers indexOfObject:self.visibleViewController]-1]).view];
    }

    
    [lastScreenShotView setFrame:CGRectMake(_startX,
                                            lastScreenShotView.frame.origin.y,
                                            lastScreenShotView.frame.size.width,
                                            lastScreenShotView.frame.size.height)];
    
    [_backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self moveViewWithX:self.view.frame.size.width];
        
    } completion:^(BOOL finished) {
        
        [self popViewControllerAnimated:NO];
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        self.view.frame = frame;
        
        _isMoving = NO;
    }];
}

-(void)popToRootViewControllerWithLRAnimated{
    _isMoving = YES;
    
    if (!_backgroundView)
    {
        CGRect frame = self.view.frame;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
        if (self.navigationBar.translucent||[UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleBlackTranslucent) {
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
        }
        else{
#endif
#if  __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_7_1
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
#else
            _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
            [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
        }
#endif
        blackMask.backgroundColor = [UIColor blackColor];
        [_backgroundView addSubview:blackMask];
    }
    
    _backgroundView.hidden = NO;
    
    if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
    
#if __has_feature(objc_arc)
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#else
    if (lastScreenShotView!=nil) {
        [lastScreenShotView release];
        lastScreenShotView=nil;
    }
    if (_isScreenShot) {
        lastScreenShotView = [[UIImageView alloc] init];
    }
    else{
        lastScreenShotView = [[UIView alloc] init];
    }
#endif
    for (UIView *subView in lastScreenShotView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (_isScreenShot) {
        [(UIImageView*)lastScreenShotView setImage:_imgScreenShot];
    }
    else{
        [lastScreenShotView addSubview:((UIViewController*)self.viewControllers[[self.viewControllers indexOfObject:self.visibleViewController]-1]).view];
    }
    [lastScreenShotView setFrame:CGRectMake(_startX,
                                            lastScreenShotView.frame.origin.y,
                                            lastScreenShotView.frame.size.width,
                                            lastScreenShotView.frame.size.height)];
    
    [_backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self moveViewWithX:self.view.frame.size.width];
        
    } completion:^(BOOL finished) {
        
        [self popToRootViewControllerAnimated:NO];
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        self.view.frame = frame;
        
        _isMoving = NO;
    }];
}

#pragma mark - Utility Methods

- (void)moveViewWithX:(float)x
{
    x = x>self.view.frame.size.width?self.view.frame.size.width:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/1000);
    
    blackMask.alpha = alpha;
    
    CGFloat aa = fabsf(_startX)/[UIScreen mainScreen].bounds.size.width;
    CGFloat y = x*aa;
    
    
    CGFloat lastScreenScale=_contentScale+x/self.view.frame.size.width*(1-_contentScale);
    
    [lastScreenShotView setFrame:CGRectMake(_startX+y+lastScreenShotView.superview.frame.size.width*(1-lastScreenScale)/2,
                                            lastScreenShotView.superview.frame.size.height*(1-lastScreenScale)/2,
                                            lastScreenShotView.superview.frame.size.width*lastScreenScale,
                                            lastScreenShotView.superview.frame.size.height*lastScreenScale)];
}


#pragma mark - Gesture Recognizer

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    CGPoint touchPoint = [recoginzer locationInView:[UIApplication sharedApplication].keyWindow];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!_backgroundView)
        {
            CGRect frame = self.view.frame;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
            if (self.navigationBar.translucent||[UIApplication sharedApplication].statusBarStyle==UIStatusBarStyleBlackTranslucent) {
                _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
                [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
                
                blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
            }
            else{
#endif
#if  __IPHONE_OS_VERSION_MAX_ALLOWED>=__IPHONE_7_1
                _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
                [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
                
                blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, [[[UIDevice currentDevice] systemVersion] floatValue]<7?0:([UIApplication sharedApplication].statusBarFrame.size.height>20?([UIApplication sharedApplication].statusBarFrame.size.height-20):0), frame.size.width , frame.size.height)];
#else
                _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
                [self.view.superview insertSubview:_backgroundView belowSubview:self.view];
                
                blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height-[UIApplication sharedApplication].statusBarFrame.size.height)];
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#else
            }
#endif
            blackMask.backgroundColor = [UIColor blackColor];
            [_backgroundView addSubview:blackMask];
        }
        
        _backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
#if __has_feature(objc_arc)
        if (_isScreenShot) {
            lastScreenShotView = [[UIImageView alloc] init];
        }
        else{
            lastScreenShotView = [[UIView alloc] init];
        }
#else
        if (lastScreenShotView!=nil) {
            [lastScreenShotView release];
            lastScreenShotView=nil;
        }
        if (_isScreenShot) {
            lastScreenShotView = [[UIImageView alloc] init];
        }
        else{
            lastScreenShotView = [[UIView alloc] init];
        }
#endif
        for (UIView *subView in lastScreenShotView.subviews) {
            [subView removeFromSuperview];
        }
        
        if (_isScreenShot) {
            [(UIImageView*)lastScreenShotView setImage:_imgScreenShot];
        }
        else{
            [lastScreenShotView addSubview:((UIViewController*)self.viewControllers[[self.viewControllers indexOfObject:self.visibleViewController]-1]).view];
        }

        [lastScreenShotView setFrame:CGRectMake(_startX,
                                                lastScreenShotView.frame.origin.y,
                                                lastScreenShotView.frame.size.width,
                                                lastScreenShotView.frame.size.height)];
        
        [_backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > _judgeOffset)
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:self.view.frame.size.width];
                
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
            }];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                _backgroundView.hidden = YES;
            }];
            
        }
        return;
        
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            _backgroundView.hidden = YES;
        }];
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

@end



