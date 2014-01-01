//
//  ViewController.m
//  videoDemo
//
//  Created by Toth Csaba on 01/01/14.
//  Copyright (c) 2014 Toth Csaba. All rights reserved.
//

#import "ViewController.h"

#import <ImageIO/CGImageProperties.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton * initButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 30, 160, 30)];
    [initButton setTitle:@"Initialize video" forState:UIControlStateNormal];
    [initButton addTarget:self action:@selector(initVideoCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:initButton];
    [initButton setTintColor:[UIColor blueColor]];
    [initButton setBackgroundColor:[UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1]];
    UIScrollView*sc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, 300, 480)];
    [sc setContentSize:CGSizeMake(300, 800)];
    [self.view addSubview:sc];
    
    videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    videoView.center = self.view.center;
    videoView.backgroundColor =[ UIColor grayColor];
    [sc addSubview:videoView];
	vImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    [vImage setBackgroundColor:[UIColor greenColor]];
    vImage.center = CGPointMake(videoView.center.x, videoView.center.y+300);
    
    [sc addSubview:vImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initVideoCapture
{
    NSLog(@"Start capture");
    // Do any additional setup after loading the view, typically from a nib.
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer* viewLayer = videoView.layer;
    NSLog(@"viewlayer = %@",viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    
    captureVideoPreviewLayer.frame = videoView.bounds;
    
    [videoView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Find a suitable AVCaptureDevice
    NSArray *cameras=[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    device =[cameras objectAtIndex:1];
    
    NSError* error = nil;
    
    AVCaptureDeviceInput*input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        NSLog(@"Error:%@",error);
    }
    [session addInput:input];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary* outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [self.stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
    
    NSLog(@"initCapture OK");

    [self captureNow];
}

-(UIImage *)captureScreenInRect:(CGRect)captureFrame {
    CALayer *layer;
    layer = videoView.layer;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextClipToRect (UIGraphicsGetCurrentContext(),captureFrame);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

-(void)captureNow
{
    AVCaptureConnection*videoConnection = nil;
    for (AVCaptureConnection*connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort*port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection= connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    NSLog(@"About to request a capture from :%@",self.stillImageOutput);
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSLog(@"Async img capture");
        CFDictionaryRef exifAttachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments) {
            //Do something with the attachments.
            NSLog(@"attachments:%@",exifAttachments);
        }
        else
        {
            NSLog(@"no attachments");
        }
        NSData*imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage*image = [[UIImage alloc]initWithData:imageData];
        
        vImage.image = image;
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        NSLog(@"ImageCaptureDone");
    }];
}

@end
