//
//  HZOverlayView.m
//  Horizon
//
//  Created by Justin Malandruccolo on 8/11/15.
//  Copyright (c) 2015 Justin Malandruccolo. All rights reserved.
//

#import "HZOverlayView.h"
#import <math.h>

@interface HZOverlayView ()

@property (strong, nonatomic) CMMotionManager *motionMngr;
@property (strong, nonatomic) CLLocationManager *locationMngr;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) UIImageView *overlayImage;
@property (strong, nonatomic) UIButton *measureButton;
@property (strong, nonatomic) UILabel *dataLabel;
@property (strong, nonatomic) UILabel *locationLabel;

@end

@implementation HZOverlayView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        _currentLocation = [[CLLocation alloc] init];
        _locationMngr = [[CLLocationManager alloc] init];
        [_locationMngr requestWhenInUseAuthorization];
        _locationMngr.delegate = self;
        _locationMngr.desiredAccuracy = kCLLocationAccuracyKilometer;
        [_locationMngr startUpdatingLocation];
        
        _motionMngr = [[CMMotionManager alloc] init];
        [_motionMngr startDeviceMotionUpdates];
        
        _overlayImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
        [_overlayImage setFrame:CGRectMake(0, 0, 50, 50)];
        _overlayImage.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:_overlayImage];
        
        _measureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-64, self.frame.size.width, 64)];
        [_measureButton addTarget:self action:@selector(didPressMeasure:) forControlEvents:UIControlEventTouchUpInside];
        [_measureButton setTitle:@"Measure" forState:UIControlStateNormal];
        [_measureButton setTitle:@"Clear" forState:UIControlStateSelected];
        [_measureButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [_measureButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_measureButton setBackgroundColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
        [self addSubview:_measureButton];
        
        _dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-119, self.frame.size.width, 50)];
        [_dataLabel setTextColor:[UIColor yellowColor]];
        _dataLabel.textAlignment = NSTextAlignmentCenter;
        
        _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-149, self.frame.size.width, 50)];
        [_locationLabel setTextColor:[UIColor yellowColor]];
        _locationLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _currentLocation = [locations lastObject];
}

- (void)didPressMeasure:(id)sender
{
    if (_measureButton.selected == NO)
    {
        [self calculateAngle];
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
             [self displayLocation];
        }
        _measureButton.selected = YES;
    }
    else
    {
        [_dataLabel removeFromSuperview];
        [_locationLabel removeFromSuperview];
        [_motionMngr startDeviceMotionUpdates];
        [_locationMngr startUpdatingLocation];
        
        _measureButton.selected = NO;
    }
}
- (void)displayLocation
{
    [_locationLabel setText:[self coordinateString]];
    [_locationMngr stopUpdatingLocation];
    [self addSubview:_locationLabel];
}

- (NSString *)coordinateString {
    
    int latSeconds = (int)(_currentLocation.coordinate.latitude * 3600);
    int latDegrees = latSeconds / 3600;
    
    int longSeconds = (int)(_currentLocation.coordinate.longitude * 3600);
    int longDegrees = longSeconds / 3600;
    
    NSString* result = [NSString stringWithFormat:@"%@%d°\%@, %d°\%@", @"Coordinates: ", ABS(latDegrees), latDegrees >= 0 ? @"N" : @"S", ABS(longDegrees), longDegrees >= 0 ? @"E" : @"W"];
    
    return result;
}

- (void)calculateAngle
{
        
  //  CGFloat x = motion.gravity.x;
    CGFloat y = _motionMngr.deviceMotion.gravity.y;
    CGFloat z = _motionMngr.deviceMotion.gravity.z;

    CGFloat angle = atan2(y, z) + M_PI_2; // to radians
    CGFloat angleDegrees = angle * 180.0f / M_PI; // to degrees
    
    if (angleDegrees > 90)
    {
        [_dataLabel setText:@"THE ANGLE IS ABOVE THE HORIZON"];
    }
    else if (angleDegrees < 0)
    {
        [_dataLabel setText:@"THE ANGLE IS BELOW THE HORIZON"];
    }
    else
    {
        [_dataLabel setText:[NSString stringWithFormat:@"%s%.1f%@", "The angle above the horizon: ", angleDegrees, @"°"]];
    }
    [_motionMngr stopDeviceMotionUpdates];
    [self addSubview:_dataLabel];

}

@end
