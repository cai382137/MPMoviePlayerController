//
//  ViewController.h
//  Test_MPMoviePlayer
//
//  Created by danny on 16/4/18.
//  Copyright © 2016年 danny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController : UIViewController

@property (nonatomic, strong)MPMoviePlayerController * moviePlayController;
@property (nonatomic, strong)UISlider * time_Slider;
@property (nonatomic, strong)UIView * tapView ;
@end

