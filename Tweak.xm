#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

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

//

%hook UnityView

@interface UnityView


- (NSArray *)subviews;
- (void)addSubview:(UIView *)subview;
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
- (bool)processTouches:(NSSet *)touches;
- (void)toggleWalk;
- (void)onButtonTweakLoc;
- (void)showLocationSettingPrompt:(NSString *)msg;
@end

UIButton *speedButton;
UIButton *walkButton;
UIButton *patrolButton;
UIButton *tweakLocButton;
UIButton *hideUIButton;

UILabel *speedLabel;
UILabel *walkLabel;

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
        walkButton.backgroundColor = [UIColor redColor];
    } else {
        walkButton.backgroundColor = [UIColor whiteColor];
    }
}

%new
- (void)toggleHideUI
{
    hideUI = !hideUI;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

%new
- (void)onButtonTweakLoc
{
    UIAlertController *alertController = [UIAlertController
                                        alertControllerWithTitle:nil
                                        message:@"Set GPS location:"
                                        preferredStyle:UIAlertControllerStyleAlert];
    WCLocation *loc=[goLoc copy];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
   {
     textField.placeholder=@"Latitude:";
     textField.tag=11;
     textField.clearButtonMode=UITextFieldViewModeWhileEditing;
     textField.keyboardType=UIKeyboardTypeDecimalPad;
     if (loc)
     {
         textField.text=[NSString stringWithFormat:@"%.8f",loc.coordinate.latitude];
     }
   }];
  [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
   {
     textField.placeholder=@"Longitude:";
     textField.tag=12;
     textField.clearButtonMode=UITextFieldViewModeWhileEditing;
     textField.keyboardType=UIKeyboardTypeDecimalPad;
     if (loc)
     {
         textField.text=[NSString stringWithFormat:@"%.8f",loc.coordinate.longitude];
     }
   }];
  [alertController addAction:[UIAlertAction actionWithTitle:@"Set" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    NSArray *inputs = alertController.textFields;
    NSString *latString, *lngString;
    for (UITextField *txtFld in inputs) {
        if (txtFld.tag == 11)
        {
            latString = txtFld.text;
        }else if (txtFld.tag == 12)
        {
            lngString = txtFld.text;
        }
    }
    if (latString.length==0 || lngString.length==0)
    {
        [self showLocationSettingPrompt:@"Latitude and longitude should not be null!"];
        return;
    }
    float lat=[latString floatValue];
    float lng=[lngString floatValue];
    if (lat<-90 || lat>90 || lng<-180 || lng>180)
    {
        [self showLocationSettingPrompt:@"Range of latitude or longitude is not correct!"];
        return;
    }
    NSDictionary *dict=@{@"lat":@(lat), @"lng":@(lng)};
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path=[path stringByAppendingPathComponent:@"zwoloc.plist"];
    [dict writeToFile:path atomically:YES];
    [self showLocationSettingPrompt:@"Success! You need to restart the app to take effect."];
  }]];
  [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
  [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)showLocationSettingPrompt:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController
                                            alertControllerWithTitle:nil
                                            message:msg
                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action =
  [UIAlertAction actionWithTitle:@"OK"
                           style:UIAlertActionStyleDefault
                         handler:nil];  
  [alertController addAction:action];
  [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:alertController animated:YES completion:nil];
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

        tweakLocButton = [[UIButton alloc] initWithFrame:CGRectMake(13, 390, 40, 40)];
        tweakLocButton.backgroundColor = [UIColor whiteColor];
        [tweakLocButton setTitle:@"GPS" forState:UIControlStateNormal];
        tweakLocButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [tweakLocButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
        [tweakLocButton addTarget:self action:@selector(onButtonTweakLoc) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tweakLocButton];        
        
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
        tweakLocButton.alpha = !hideUI;
        speedLabel.alpha = !hideUI;
        walkLabel.alpha = !hideUI;
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
            }
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

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // block failure callback
}
%end