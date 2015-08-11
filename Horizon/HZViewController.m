//
//  HZViewController.m
//  Horizon
//
//  Created by Justin Malandruccolo on 8/10/15.
//  Copyright (c) 2015 Justin Malandruccolo. All rights reserved.
//

#import "HZViewController.h"
#import "HZOverlayView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface HZViewController ()

@property (strong, nonatomic) UIButton *fire;
@property (strong, nonatomic) UILabel *target;
@property (strong, nonatomic) HZOverlayView *overlayView;

@end

@implementation HZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];

    _overlayView = [[HZOverlayView alloc] initWithFrame:self.view.bounds];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *media = [UIImagePickerController
                          availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        
        if ([media containsObject:(NSString*)kUTTypeImage] == YES) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            // picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            [picker setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
            picker.delegate = self;
            picker.showsCameraControls = NO;
            
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            float scale = screenSize.height / screenSize.width*3/4;
            CGAffineTransform translate = CGAffineTransformMakeTranslation(0,(screenSize.height - screenSize.width*4/3)*0.5);
            CGAffineTransform fullScreen = CGAffineTransformMakeScale(scale, scale);
            picker.cameraViewTransform = CGAffineTransformConcat(fullScreen, translate);
            
            picker.cameraOverlayView = _overlayView;
            [self presentViewController:picker animated:YES completion:^{}];
            //[picker release];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported!"
                                                            message:@"Camera does not support photo capturing."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

@end
