//
//  ViewController.h
//  videoDemo
//
//  Created by Toth Csaba on 01/01/14.
//  Copyright (c) 2014 Toth Csaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController
{
    UIView* videoView;
    UIImageView*vImage;
}
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;

@end
