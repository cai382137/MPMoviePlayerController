//
//  ViewController.m
//  Test_MPMoviePlayer
//
//  Created by danny on 16/4/18.
//  Copyright © 2016年 danny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong)   NSArray * markTime;
@property (nonatomic, strong)   NSArray * distTime;
@end

@implementation ViewController
@synthesize moviePlayController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self setMyView];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];


}


- (void)setMyView{
    
    //use str , it will show the problem about the currentPlaybackTime doesn`t work
    //but it is work with the str1 ....
    //so i think it must  the reason why sometimes the currentPlaybackTime doesn`t work
    
    
//    NSString * str = @"http://videoal.xiaozhu521.com/video/qiniucode/20160220/65/42bd6a3059fd43e3b024ff0c1f918d65.mp4?e=1460952984&token=W6QRgyuMNJKS7XsEhmXX9YgYO_2aB-vAFZXKzXFy:OMHjHEQhhBD61aLjn-fUFTPKK84=";
    NSString * str1                          = @"http://38.98.63.12/youku/6976CDA88D94881CF724A84F3E/030008010056FDDF0560D2003E8803ECFF6DC0-6231-8154-D81A-B396974FDDB7.mp4";
    moviePlayController                     = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:str1]];
    moviePlayController.view.frame          = self.view.bounds;
    [self.view addSubview:moviePlayController.view];
    moviePlayController.controlStyle        = MPMovieControlStyleNone;
    [moviePlayController prepareToPlay];

    for( UIView * view in  moviePlayController.view.subviews){
        if(view.bounds.size.width > 0.95 * moviePlayController.view.bounds.size.width && view.bounds.size.height > 0.95 * moviePlayController.view.bounds.size.height )
//        _tapView                         = [[UIView alloc] init];
//        _tapView.frame                   = CGRectMake(0, 0, 368, 500);
//        _tapView.backgroundColor         = [UIColor whiteColor];
//        _tapView.alpha                   = 1.0;
//        [view addSubview:_tapView];
    _time_Slider                            = [[UISlider alloc]init];
    _time_Slider.frame                      = CGRectMake(30, 450, 300, 50);
    _time_Slider.backgroundColor            = [UIColor blackColor];
        [_time_Slider addTarget:self action:@selector(moveSlider) forControlEvents:UIControlEventTouchUpInside];
        [_time_Slider addTarget:self action:@selector(startMove) forControlEvents:UIControlEventTouchDown];
        [view addSubview:_time_Slider];

    UIGestureRecognizer * tapGesture        = [[UITapGestureRecognizer alloc]init];
        [tapGesture addTarget:self action:@selector(tapTheView)];
        [view addGestureRecognizer:tapGesture];
    }







}

#pragma mark ---
- (void)onMPMoviePlayerPlaybackStateDidChangeNotification{
    moviePlayController.controlStyle        = MPMovieControlStyleNone;
    if (moviePlayController.playbackState == MPMoviePlaybackStatePlaying) {
        //playing

        [UIView animateWithDuration:0.3 animations:^{
    _time_Slider.userInteractionEnabled     = NO;
        } completion:^(BOOL finished) {
    _time_Slider.alpha                      = 0.0;
        }];
    }else if (moviePlayController.playbackState == MPMoviePlaybackStatePaused){
        //pausing
    _time_Slider.value                      = moviePlayController.currentPlaybackTime;
        [UIView animateWithDuration:0.3 animations:^{
    _time_Slider.alpha                      = 1.0;
    _time_Slider.userInteractionEnabled     = YES;
        } completion:^(BOOL finished) {

        }];
    }
}


- (void)onMPMoviePlayerLoadStateDidChangeNotification{

}


- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification{
    if (moviePlayController.loadState & MPMovieLoadStatePlaythroughOK) {
        //这才开始计时
    _markTime                               = [NSArray arrayWithArray:[self getCurrentSystime]];
    }
    if (moviePlayController.loadState & MPMovieLoadStateStalled){

        //进入缓冲
        NSLog(@"loading---loading---loading---\n");

    }
}

- (void)onMPMovieDurationAvailableNotification{
    CGFloat totalTime                       = moviePlayController.duration;
    _time_Slider.minimumValue               = 0.0;
    _time_Slider.maximumValue               = totalTime;
}

- (void)onMPMoviePlayerPlaybackDidFinishNotification:(NSNotification *)notification{
    //====error report
    NSDictionary *notificationUserInfo      = [notification userInfo];
    NSNumber *resultValue                   = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];

    MPMovieFinishReason reason              = [resultValue intValue];

    if (reason == MPMovieFinishReasonPlaybackError)
    {
    NSError *mediaPlayerError               = [notificationUserInfo objectForKey:@"error"];

    NSString*errorstring                    = @"";
        if (mediaPlayerError)
        {
    errorstring                             = [NSString stringWithFormat:@"%@",[mediaPlayerError localizedDescription]];

        }
        else
        {
    errorstring                             = @"playback failed without any given reason";
        }

    }

}


#pragma  mark --
//MPMoviePlaybackStateStopped,
//MPMoviePlaybackStatePlaying,
//MPMoviePlaybackStatePaused,
- (void)tapTheView{
    if (moviePlayController.playbackState == MPMoviePlaybackStatePlaying) {
        //播放状态  －》 需要停止
        [moviePlayController pause];

    _markTime                               = [self getCurrentSystime];

    }else{
//        停止或者其他都重新开始播放
        [moviePlayController play];
    }


}


#pragma mark ------
- (NSArray *)doCalculate:(NSArray *)time1 and:(NSArray *)time2 withSym:(NSString *)sym{
    int t1_minute ,t2_minute;
    float t1_second,t2_second;
    t1_minute                               = [time1[0] intValue];
    t1_second                               = [time1[1] floatValue];;
    t2_minute                               = [time2[0] intValue];
    t2_second                               = [time2[1] floatValue];
    if ([sym isEqualToString:@"+"]) {
    t1_minute                               += t2_minute;
    t1_second                               += t2_second;
        if (t2_second >= 60) {
    t1_minute                               += 1;
    t1_second                               -= 60;
        }
    }else if([sym isEqualToString:@"-"]){
        if (t1_second < t2_second) {
    t1_minute                               = t1_minute - t2_minute - 1;
    t1_second                               = t1_second - t2_second + 60;
        }else{
    t1_minute                               -= t2_minute;
    t1_second                               -= t2_second;
        }
    }
    return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",t1_minute],[NSString stringWithFormat:@"%f",t1_second],nil];
}

- (NSArray *)getCurrentSystime{
    NSDate *date                            = [NSDate date];
    NSDateFormatter *formatter              = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm-ss"];

    NSString *string_time                   = [formatter stringFromDate:date];
    NSArray *time                           = [string_time componentsSeparatedByString:@"-"];
    return time;
}

- (float)transTimeArrToFloat:(NSArray *)arr{
    float minute                            = [arr[0] floatValue];
    float second                            = [arr[1] floatValue];
    return (minute*60 + second);
}

- (NSArray *)transTimeFloatToArr:(float)num{
    float sum                               = floor(num);
    int minute                              = sum / 60;
    int second                              = floor(sum - minute * 60);
    return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld",(long)minute],[NSString stringWithFormat:@"%ld",(long)second] ,nil];
}


#pragma mark ---
- (void)moveSlider{

    moviePlayController.currentPlaybackTime = _time_Slider.value;
    [moviePlayController play];
}

- (void)startMove{
    [moviePlayController pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
