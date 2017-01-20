#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

////////------ External ------//////
//
//  RSPlayPauseButton.h
//
//  Created by Raphael Schaad on 2014-03-22.
//  This is free and unencumbered software released into the public domain.
//


#import <UIKit/UIKit.h>


#define RSPlayPauseButtonAnimationStyleSplit 0 // Default
#define RSPlayPauseButtonAnimationStyleSplitAndRotate 1



//
//  Displays a  ⃝ with either the ► (play) or ❚❚ (pause) icon and nicely morphs between the two states.
//  It's targeted for iOS 7+ and is tintColor-aware.
//
@interface RSPlayPauseButton : UIControl

// State
@property (nonatomic, assign, getter = isPaused) BOOL paused; // Default is `YES`; changing this way is not animated
- (void)setPaused:(BOOL)paused animated:(BOOL)animated;

// Style
@property (nonatomic, assign) int animationStyle; // Default is `RSPlayPauseButtonAnimationStyleSplit`

@end

//
//  RSPlayPauseButton.m
//
//  Created by Raphael Schaad https://github.com/raphaelschaad on 2014-03-22.
//  This is free and unencumbered software released into the public domain.
//


#include <tgmath.h> // type generic math, yo: http://en.wikipedia.org/wiki/Tgmath.h#tgmath.h


static const CGFloat kScale = 1.0;
static const CGFloat kBorderSize = 32.0 * kScale;
static const CGFloat kBorderWidth = 0.0 * kScale;
static const CGFloat kSize = kBorderSize + kBorderWidth; // The total size is the border size + 2x half the border width.
static const CGFloat kPauseLineWidth = 4.0 * kScale;
static const CGFloat kPauseLineHeight = 15.0 * kScale;
static const CGFloat kPauseLinesSpace = 4.0 * kScale;
static const CGFloat kPlayTriangleOffsetX = 2.0 * kScale;
static const CGFloat kPlayTriangleTipOffsetX = 2.0 * kScale;

static const CGPoint p1 = {0.0, 0.0};                          // line 1, top left
static const CGPoint p2 = {kPauseLineWidth, 0.0};              // line 1, top right
static const CGPoint p3 = {kPauseLineWidth, kPauseLineHeight}; // line 1, bottom right
static const CGPoint p4 = {0.0, kPauseLineHeight};             // line 1, bottom left

static const CGPoint p5 = {kPauseLineWidth + kPauseLinesSpace, 0.0};                                // line 2, top left
static const CGPoint p6 = {kPauseLineWidth + kPauseLinesSpace + kPauseLineWidth, 0.0};              // line 2, top right
static const CGPoint p7 = {kPauseLineWidth + kPauseLinesSpace + kPauseLineWidth, kPauseLineHeight}; // line 2, bottom right
static const CGPoint p8 = {kPauseLineWidth + kPauseLinesSpace, kPauseLineHeight};                   // line 2, bottom left


@interface RSPlayPauseButton ()

@property (nonatomic, strong) CAShapeLayer *borderShapeLayer;
@property (nonatomic, strong) CAShapeLayer *playPauseShapeLayer;
@property (nonatomic, strong, readonly) UIBezierPath *pauseBezierPath;
@property (nonatomic, strong, readonly) UIBezierPath *pauseRotateBezierPath;
@property (nonatomic, strong, readonly) UIBezierPath *playBezierPath;
@property (nonatomic, strong, readonly) UIBezierPath *playRotateBezierPath;

@end


@implementation RSPlayPauseButton

#pragma mark - Accessors
#pragma mark Public

- (void)setPaused:(BOOL)paused
{
    if (_paused != paused) {
        [self setPaused:paused animated:NO];
    }
}


#pragma mark Private

@synthesize pauseBezierPath = _pauseBezierPath;

- (UIBezierPath *)pauseBezierPath
{
    if (!_pauseBezierPath) {
        _pauseBezierPath = [UIBezierPath bezierPath];
        
        // Subpath for 1. line
        [_pauseBezierPath moveToPoint:p1];
        [_pauseBezierPath addLineToPoint:p2];
        [_pauseBezierPath addLineToPoint:p3];
        [_pauseBezierPath addLineToPoint:p4];
        [_pauseBezierPath closePath];
        
        // Subpath for 2. line
        [_pauseBezierPath moveToPoint:p5];
        [_pauseBezierPath addLineToPoint:p6];
        [_pauseBezierPath addLineToPoint:p7];
        [_pauseBezierPath addLineToPoint:p8];
        [_pauseBezierPath closePath];
    }
    
    return _pauseBezierPath;
}


@synthesize pauseRotateBezierPath = _pauseRotateBezierPath;

- (UIBezierPath *)pauseRotateBezierPath
{
    if (!_pauseRotateBezierPath) {
        _pauseRotateBezierPath = [UIBezierPath bezierPath];
        
        // Subpath for 1. line
        [_pauseRotateBezierPath moveToPoint:p7];
        [_pauseRotateBezierPath addLineToPoint:p8];
        [_pauseRotateBezierPath addLineToPoint:p5];
        [_pauseRotateBezierPath addLineToPoint:p6];
        [_pauseRotateBezierPath closePath];
        
        // Subpath for 2. line
        [_pauseRotateBezierPath moveToPoint:p3];
        [_pauseRotateBezierPath addLineToPoint:p4];
        [_pauseRotateBezierPath addLineToPoint:p1];
        [_pauseRotateBezierPath addLineToPoint:p2];
        [_pauseRotateBezierPath closePath];
    }
    
    return _pauseRotateBezierPath;
}


@synthesize playBezierPath = _playBezierPath;

- (UIBezierPath *)playBezierPath
{
    if (!_playBezierPath) {
        _playBezierPath = [UIBezierPath bezierPath];
        
        const CGFloat kPauseLinesHalfSpace = floor(kPauseLinesSpace / 2);
        const CGFloat kPauseLineHalfHeight = floor(kPauseLineHeight / 2);
        
        CGPoint _p1 = CGPointMake(p1.x + kPlayTriangleOffsetX, p1.y);
        CGPoint _p2 = CGPointMake(p2.x + kPauseLinesHalfSpace, p2.y);
        CGPoint _p3 = CGPointMake(p3.x + kPauseLinesHalfSpace, p3.y);
        CGPoint _p4 = CGPointMake(p4.x + kPlayTriangleOffsetX, p4.y);
        
        CGPoint _p5 = CGPointMake(p5.x - kPauseLinesHalfSpace, p5.y);
        CGPoint _p6 = CGPointMake(p6.x + kPlayTriangleTipOffsetX, p6.y);
        CGPoint _p7 = CGPointMake(p7.x + kPlayTriangleTipOffsetX, p7.y);
        CGPoint _p8 = CGPointMake(p8.x - kPauseLinesHalfSpace, p8.y);
        
        const CGFloat kPlayTriangleWidth = _p6.x - _p1.x;
        
        _p2.y += kPauseLineHalfHeight * (_p2.x - kPlayTriangleOffsetX) / kPlayTriangleWidth;
        _p3.y -= kPauseLineHalfHeight * (_p3.x - kPlayTriangleOffsetX) / kPlayTriangleWidth;
        
        _p5.y += kPauseLineHalfHeight * (_p5.x - kPlayTriangleOffsetX) / kPlayTriangleWidth;
        
        _p6.y = kPauseLineHalfHeight;
        _p7.y = kPauseLineHalfHeight;
        
        _p8.y -= kPauseLineHalfHeight * (_p8.x - kPlayTriangleOffsetX) / kPlayTriangleWidth;
        
        [_playBezierPath moveToPoint:_p1];
        [_playBezierPath addLineToPoint:_p2];
        [_playBezierPath addLineToPoint:_p3];
        [_playBezierPath addLineToPoint:_p4];
        [_playBezierPath closePath];
        
        [_playBezierPath moveToPoint:_p5];
        [_playBezierPath addLineToPoint:_p6];
        [_playBezierPath addLineToPoint:_p7];
        [_playBezierPath addLineToPoint:_p8];
        [_playBezierPath closePath];
    }
    
    return _playBezierPath;
}


@synthesize playRotateBezierPath = _playRotateBezierPath;

- (UIBezierPath *)playRotateBezierPath
{
    if (!_playRotateBezierPath) {
        _playRotateBezierPath = [UIBezierPath bezierPath];
        
        const CGFloat kPauseLineHalfHeight = floor(kPauseLineHeight / 2);
        
        CGPoint _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8;
        _p1 = _p2 = _p5 = _p6 = CGPointMake(p6.x + kPlayTriangleTipOffsetX, kPauseLineHalfHeight);
        _p3 = _p8 = CGPointMake(p1.x + kPlayTriangleOffsetX, kPauseLineHalfHeight);
        _p4 = CGPointMake(p1.x + kPlayTriangleOffsetX, p1.y);
        _p7 = CGPointMake(p4.x + kPlayTriangleOffsetX, p4.y);
        
        [_playRotateBezierPath moveToPoint:_p1];
        [_playRotateBezierPath addLineToPoint:_p2];
        [_playRotateBezierPath addLineToPoint:_p3];
        [_playRotateBezierPath addLineToPoint:_p4];
        [_playRotateBezierPath closePath];
        
        [_playRotateBezierPath moveToPoint:_p5];
        [_playRotateBezierPath addLineToPoint:_p6];
        [_playRotateBezierPath addLineToPoint:_p7];
        [_playRotateBezierPath addLineToPoint:_p8];
        [_playRotateBezierPath closePath];
    }
    
    return _playRotateBezierPath;
}


#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _paused = YES;
        
        [self sizeToFit];
    }
    return self;
}


#pragma mark - UIView Method Overrides
#pragma mark Configuring a View's Visual Appearance

- (void)tintColorDidChange
{
    // Refresh view rendering when system calls this method with a changed tint color.
    [self setNeedsLayout];
}


#pragma mark Configuring the Resizing Behavior

- (CGSize)sizeThatFits:(CGSize)size
{
    // Ignore the current size/new size by super and instead use our default size.
    return CGSizeMake(kSize, kSize);
}


#pragma mark Laying out Subviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.playPauseShapeLayer) {
        self.playPauseShapeLayer = [[CAShapeLayer alloc] init];
        CGRect playPauseRect = CGRectZero;
        playPauseRect.origin.x = floor(((self.bounds.size.width) - (kPauseLineWidth + kPauseLinesSpace + kPauseLineWidth)) / 2);
        playPauseRect.origin.y = floor(((self.bounds.size.height) - (kPauseLineHeight)) / 2);
        playPauseRect.size.width = kPauseLineWidth + kPauseLinesSpace + kPauseLineWidth + kPlayTriangleTipOffsetX;
        playPauseRect.size.height = kPauseLineHeight;
        self.playPauseShapeLayer.frame = playPauseRect;
        UIBezierPath *path = self.isPaused ? self.playRotateBezierPath : self.pauseBezierPath;
        self.playPauseShapeLayer.path = path.CGPath;
        [self.layer addSublayer:self.playPauseShapeLayer];
    }
    self.playPauseShapeLayer.fillColor = self.tintColor.CGColor;
}


#pragma mark - Public Methods

- (void)setPaused:(BOOL)paused animated:(BOOL)animated
{
    if (_paused != paused) {
        _paused = paused;
        
        UIBezierPath *fromPath = nil;
        UIBezierPath *toPath = nil;
        if (self.animationStyle == RSPlayPauseButtonAnimationStyleSplit) {
            fromPath = self.isPaused ? self.pauseBezierPath : self.playBezierPath;
            toPath = self.isPaused ? self.playBezierPath : self.pauseBezierPath;
        } else if (self.animationStyle == RSPlayPauseButtonAnimationStyleSplitAndRotate) {
            fromPath = self.isPaused ? self.pauseBezierPath : self.playRotateBezierPath;
            toPath = self.isPaused ? self.playRotateBezierPath : self.pauseRotateBezierPath;
        } else {
            // Unsupported animation style -- fall back to using default animation style's "to path" but don't animate to it.
            toPath = self.isPaused ? self.playBezierPath : self.pauseBezierPath;
            animated = NO;
        }
        
        NSString * const kMorphAnimationKey = @"morphAnimationKey";
        if (animated) {
            // Morph between the two states.
            CABasicAnimation *morphAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
            
            CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [morphAnimation setTimingFunction:timingFunction];
            
            // Make the new state stick.
            [morphAnimation setRemovedOnCompletion:NO];
            [morphAnimation setFillMode:kCAFillModeForwards];
            
            morphAnimation.duration = 0.3;
            morphAnimation.fromValue = (__bridge id)fromPath.CGPath;
            morphAnimation.toValue = (__bridge id)toPath.CGPath;
            
            [self.playPauseShapeLayer addAnimation:morphAnimation forKey:kMorphAnimationKey];
        } else {
            // Clear out potential existing morph animations.
            [self.playPauseShapeLayer removeAnimationForKey:kMorphAnimationKey];
            
            // Snap to new state.
            self.playPauseShapeLayer.path = toPath.CGPath;
        }
    }
}


@end

////////------ End External ------//////

@interface WCLocation : NSObject

@property CLLocationCoordinate2D coordinate;
@property CLLocationDistance altitude;
@property (nonatomic, strong) CLFloor *floor;
@property CLLocationAccuracy horizontalAccuracy;
@property CLLocationAccuracy verticalAccuracy;
@property (nonatomic, strong) NSDate *timestamp;
@property CLLocationSpeed speed;
@property CLLocationDirection course;

-(id)copyWithZone:(NSZone *) zone;

@end

@implementation WCLocation

-(id)copyWithZone:(NSZone *) zone
{
    WCLocation *copy = [WCLocation new];
    copy.coordinate = self.coordinate;
    copy.altitude = self.altitude;
    copy.floor = self.floor;
    copy.horizontalAccuracy = self.horizontalAccuracy;
    copy.verticalAccuracy = self.verticalAccuracy;
    copy.timestamp = self.timestamp;
    copy.speed = self.speed;
    copy.course = self.course;
    return copy;
}

@end

// Globals
bool locChanged;
WCLocation *goLoc;
CLLocationManager *locationManager; //Need to change the location of the manager

bool walkingMode;
CGPoint walkingVec;

bool patrolMode;
bool patrolPaused;
WCLocation *baseLocation;
//

%hook UnityView

@interface UnityView <UIAlertViewDelegate>


- (NSArray *)subviews;
- (void)addSubview:(UIView *)subview;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (bool)processTouches:(NSSet *)touches;
- (void)toggleWalk;
- (void)togglePatrol;
@end

UIButton *speedButton;
UIButton *walkButton;
UIButton *patrolButton;
UIButton *hideUIButton;

UILabel *speedLabel;
UILabel *walkLabel;
UILabel *patrolLabel;
RSPlayPauseButton *patrolPlayPauseButton;
int speed = 1;
bool hideUI = false;

bool locationLoopStarted;

%new
- (void)incrementSpeed
{
    switch (speed) {
        case 1:
            speed = 2;
            [speedButton setTitle:@"2x" forState:UIControlStateNormal];
            break;
            
        case 2:
            speed = 4;
            [speedButton setTitle:@"4x" forState:UIControlStateNormal];
            break;
            
        case 4:
            [speedButton setTitle:@"1x" forState:UIControlStateNormal];
            speed = 1;
            break;
            
        default:
            break;
    }
}

%new
- (void)toggleWalk
{
    walkingMode = !walkingMode;
    if (walkingMode) {
        if (patrolMode)
            [self togglePatrol];
        walkButton.backgroundColor = [UIColor redColor];
    } else {
        walkButton.backgroundColor = [UIColor whiteColor];
    }
}

%new
- (void)togglePatrol
{
    patrolMode = !patrolMode;
    if (patrolMode) {
        if (walkingMode)
            [self toggleWalk];
        patrolButton.backgroundColor = [UIColor greenColor];
        baseLocation = [goLoc copy];
        [UIView animateWithDuration:0.2 animations:^{
            patrolPlayPauseButton.frame = CGRectOffset(patrolPlayPauseButton.frame, 50, 0);
        }];
    } else {
        patrolPaused = false;
        [patrolPlayPauseButton setPaused:NO animated:YES];
        patrolButton.backgroundColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.2 animations:^{
            patrolPlayPauseButton.frame = CGRectOffset(patrolPlayPauseButton.frame, -50, 0);
        }];
    }
}

%new
- (void)togglePatrolPause
{
    patrolPaused = !patrolPaused;
    [patrolPlayPauseButton setPaused:patrolPaused animated:YES];
}

%new
- (void)toggleHideUI
{
    hideUI = !hideUI;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)layoutSubviews
{
    %orig;
    if (!speedButton) {
        
        speedButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 250, 40, 40)];
        speedButton.backgroundColor = [UIColor whiteColor];
        speedButton.layer.cornerRadius = speedButton.frame.size.width/2;
        speedButton.clipsToBounds = YES;
        [speedButton setTitle:@"1x" forState:UIControlStateNormal];
        [speedButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        [speedButton addTarget:self action:@selector(incrementSpeed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:speedButton];
        
        speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 290, 60, 14)];
        speedLabel.textAlignment = NSTextAlignmentCenter;
        speedLabel.text = @"Speed";
        speedLabel.textColor = [UIColor whiteColor];
        speedLabel.font = [UIFont systemFontOfSize:10];
        speedLabel.layer.cornerRadius = 7.f;
        speedLabel.backgroundColor = [UIColor colorWithWhite:40/255.0 alpha:0.17];
        speedLabel.clipsToBounds = YES;
        [self addSubview:speedLabel];
        
        
        walkButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 320, 40, 40)];
        walkButton.backgroundColor = [UIColor whiteColor];
        walkButton.layer.borderColor = [UIColor whiteColor].CGColor;
        walkButton.layer.borderWidth = 3.0f;
        walkButton.layer.cornerRadius = speedButton.frame.size.width/2;
        walkButton.clipsToBounds = YES;
        [walkButton addTarget:self action:@selector(toggleWalk) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:walkButton];
        
        walkLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 360, 60, 14)];
        walkLabel.textAlignment = NSTextAlignmentCenter;
        walkLabel.text = @"Tap To Walk";
        walkLabel.textColor = [UIColor whiteColor];
        walkLabel.font = [UIFont systemFontOfSize:10];
        walkLabel.layer.cornerRadius = 7.f;
        walkLabel.backgroundColor = [UIColor colorWithWhite:40/255.0 alpha:0.17];
        walkLabel.clipsToBounds = YES;
        [self addSubview:walkLabel];
        
        patrolButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 390, 40, 40)];
        patrolButton.backgroundColor = [UIColor whiteColor];
        patrolButton.layer.borderColor = [UIColor whiteColor].CGColor;
        patrolButton.layer.borderWidth = 3.0f;
        patrolButton.layer.cornerRadius = speedButton.frame.size.width/2;
        patrolButton.clipsToBounds = YES;
        [patrolButton addTarget:self action:@selector(togglePatrol) forControlEvents:UIControlEventTouchUpInside];
        
        patrolLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 430, 60, 14)];
        patrolLabel.textAlignment = NSTextAlignmentCenter;
        patrolLabel.text = @"Patrol";
        patrolLabel.textColor = [UIColor whiteColor];
        patrolLabel.font = [UIFont systemFontOfSize:10];
        patrolLabel.layer.cornerRadius = 7.f;
        patrolLabel.backgroundColor = [UIColor colorWithWhite:40/255.0 alpha:0.17];
        patrolLabel.clipsToBounds = YES;
        [self addSubview:patrolLabel];
        
        patrolPlayPauseButton = [[RSPlayPauseButton alloc] initWithFrame:CGRectMake(15, 393, 40, 40)];
        [patrolPlayPauseButton setPaused:NO animated:NO];
        patrolPlayPauseButton.tintColor = [UIColor greenColor];
        patrolPlayPauseButton.backgroundColor = [UIColor whiteColor];
        patrolPlayPauseButton.layer.cornerRadius = patrolPlayPauseButton.frame.size.width/2;
        patrolPlayPauseButton.animationStyle = RSPlayPauseButtonAnimationStyleSplitAndRotate;
        [patrolPlayPauseButton addTarget:self action:@selector(togglePatrolPause) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:patrolPlayPauseButton];
        [self addSubview:patrolButton];
        
        hideUIButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 25, 34, 34)];
        hideUIButton.backgroundColor = [UIColor whiteColor];
        hideUIButton.layer.cornerRadius = hideUIButton.frame.size.width/2;
        [hideUIButton addTarget:self action:@selector(toggleHideUI) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:hideUIButton];        
        
    }
    [UIView animateWithDuration:0.3 animations:^{
        hideUIButton.backgroundColor = hideUI ? [UIColor clearColor] : [UIColor colorWithWhite:1.0 alpha:0.85];
        speedButton.alpha = !hideUI;
        walkButton.alpha = !hideUI;
        patrolButton.alpha = !hideUI;
        patrolPlayPauseButton.alpha = !hideUI;
        speedLabel.alpha = !hideUI;
        walkLabel.alpha = !hideUI;
        patrolLabel.alpha = !hideUI;
    }];
}

// Return true means call orig
%new
- (bool)processTouches:(NSSet<UITouch *> *)touches
{
    if (hideUI) {
        return true;
    }
    if (!goLoc) {
        return true;
    } else if (!locationManager) {
        return true;
        
    } else {
        UITouch *touch = [touches anyObject];
        if (/*touch.force < 1.5 &&*/ !walkingMode) { //Force too low
            return true;
        }
        
        UIView *touchedView = touch.view;
        CGPoint touchLocation = [touch locationInView:touchedView];
        
        // Get touch vector
        CGPoint centerLoc = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 1.4);
        //CGPoint centerLoc = CGPointMake(185, 485);
        walkingVec = CGPointMake(touchLocation.x - centerLoc.x, touchLocation.y - centerLoc.y);
        
        //
        //        CGFloat heading = 0;
        //        if (walkingVec.y > 0 && walkingVec.x > 0) {
        //            heading = arc4random_uniform(90)
        //        }
        //        // = tan(walkingVec.x / walkingVec.y);
        //        NSLog(@"HEading: %f", heading);
        //
        //        dot = walkingVec.y      # dot product
        //        det = walkingVec.x      # determinant
        //        angle = atan2(det, dot)  # atan2(y, x) or atan2(sin, cos)
        
        
        locChanged = true;
        return false;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([self processTouches:touches]) {
        %orig;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if([self processTouches:touches]) {
        %orig;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    %orig;
    locChanged = false;
    //    UITouch *touch = [touches anyObject];
    //    UIView *touchedView = touch.view;
    //    CGPoint touchLocation = [touch locationInView:touchedView];
    //    NSLog(@"%f %f", touchLocation.x, touchLocation.y);
    //    if (touchLocation.x < 20 && touchLocation.y < 20) {
    //        hideUI = !hideUI;
    //        [self setNeedsLayout];
    //        [self layoutIfNeeded];
    //        NSLog(@"Toggling UI");
    //    }
}

%end

%hook NIAIosLocationManager

@interface NIAIosLocationManager


- (void)startLocationLoop;

@end

%new
- (void)startLocationLoop
{
    if (locationLoopStarted)
        return;
    locationLoopStarted = true;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFTimeInterval patrolTime = 0;
        CFTimeInterval lastLoopTime;
        while (true) {
            CGFloat sleepTime = 0.1;
            if (locChanged) { // Set from walking mode
                // NSLog(@"Updating location");
                
                // Normalize
                CGFloat length = sqrt(walkingVec.x * walkingVec.x + walkingVec.y * walkingVec.y) * (5500 + arc4random_uniform(1000));
                walkingVec = CGPointMake(walkingVec.x / length, walkingVec.y / length);
                
                goLoc.coordinate = CLLocationCoordinate2DMake(goLoc.coordinate.latitude - (walkingVec.y * speed),
                                                              goLoc.coordinate.longitude + (walkingVec.x * speed));
                
                //locationManager.location = goLoc;
                [[locationManager delegate] locationManager:locationManager didUpdateLocations:@[]];
                // NSLog(@"LMD: %@", [locationManager delegate]);
                locChanged = false;
                sleepTime = 0.8 + (arc4random_uniform(100) / 400.0);
            } else if (patrolMode && !patrolPaused) {
                patrolTime += CACurrentMediaTime() - lastLoopTime;
                goLoc.coordinate = CLLocationCoordinate2DMake(baseLocation.coordinate.latitude - (sin(patrolTime * 0.03 * speed) * 0.001),
                                                              baseLocation.coordinate.longitude + (cos(patrolTime * 0.03 * speed) * 0.001));
                
                //locationManager.location = goLoc;
                [[locationManager delegate] locationManager:locationManager didUpdateLocations:@[]];
                sleepTime = 0.8 + (arc4random_uniform(100) / 400.0);
            }
            lastLoopTime = CACurrentMediaTime();
            [NSThread sleepForTimeInterval:sleepTime];
        }
    });
}


CGFloat baseHorizontalAccuracy;
CGFloat baseverticalAccuracy;

CGFloat randomizeValue(CGFloat value)
{
    return value - (value / 8) + arc4random_uniform(value/4);
}

NSDate *currentTimestamp()
{
    return [NSDate date];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = [locations lastObject];
    
    
    if (loc) { //We got a real location
        baseHorizontalAccuracy = loc.horizontalAccuracy;
        baseverticalAccuracy = loc.verticalAccuracy;
        goLoc.course = loc.course;
        //Fuzz it a little bit so it's not always the same
        goLoc.coordinate = CLLocationCoordinate2DMake(goLoc.coordinate.latitude - .00005 + ((arc4random_uniform(300) / 100) * .00005),
                                                      goLoc.coordinate.longitude - .00005 + ((arc4random_uniform(300) / 100) * .00005));
    }
    
    if (!goLoc && loc.horizontalAccuracy < 500) {
        // NSLog(@"Creating Goloc");
        goLoc = [WCLocation new];

        NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        path=[path stringByAppendingPathComponent:@"zwoloc.plist"];
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:path];
        NSNumber *lat=dict[@"lat"];
    	NSNumber *lng=dict[@"lng"];
        if (lat && lng)
        {
        	goLoc.coordinate = CLLocationCoordinate2DMake(lat.floatValue, lng.floatValue);
        }else{
        	goLoc.coordinate = loc.coordinate;
        }        
        
        goLoc.altitude = loc.altitude;
        goLoc.floor = loc.floor;
        
        locationManager = manager;
        
        [self startLocationLoop];
    }
    
    if (goLoc) {
        goLoc.horizontalAccuracy = randomizeValue(baseHorizontalAccuracy);
        goLoc.verticalAccuracy = randomizeValue(baseverticalAccuracy);
        goLoc.timestamp = currentTimestamp();
        goLoc.speed = randomizeValue(speed * 20);
        //goLoc.course = loc.course;
        
        NSArray *locs = @[goLoc];
        %orig(manager, locs);
    } else {
        // %orig;
    }
}
%end