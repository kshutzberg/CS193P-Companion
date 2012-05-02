//
//  BarGraphViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "BarGraphViewController.h"
#import "Entities+Create.h"
#import <QuartzCore/QuartzCore.h>

@interface BarGraphViewController()<UIScrollViewDelegate, BarGraphViewDelegate>
@property (nonatomic, weak) NSTimer *timer;
- (void)updateTime:(NSTimer *)timer;
- (void)animaterGraphViewHeightToScale:(CGFloat)scale;
- (void)showTimer;
- (void)hideTimer;
- (void)initializeTimer;
@end

@implementation BarGraphViewController
@synthesize graphView = _graphView;
@synthesize question = _question;
@synthesize progressView = _progressView;

@synthesize questionTime = _questionTime;
@synthesize timer = _timer;
@synthesize expirationDate = _expirationDate;

-(void)setExpirationDate:(NSDate *)expirationDate
{
     _expirationDate = expirationDate;
    [self initializeTimer];
}

-(void)setQuestionTime:(NSTimeInterval)questionTime
{
    _questionTime = questionTime;
    [self initializeTimer];
}

- (void)initializeTimer
{
    [self.timer invalidate];
    NSTimeInterval timeLeft = [self.expirationDate timeIntervalSinceNow];
    if (timeLeft > 0) {
        [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        [self showTimer];
    }
}

- (void)updateGraph:(NSNotification *)notification
{
    [self.graphView setAnswers:self.question.numberAnswers animated:YES];
    [self.graphView setNeedsDisplay];
}

- (void)updateTime:(NSTimer *)timer
{
    float progress = 1 - [self.expirationDate timeIntervalSinceNow]/self.questionTime;
     [self.progressView setProgress:progress animated:YES];
    if (progress <= 1) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"m:ss"];
        //self.graphView.bannerText = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.timeLeft]];
    }
    else
    {
        [timer invalidate];
        [self hideTimer];
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}

#define SHRINK_SCALE .85

- (void)showTimer
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.frame = CGRectMake(20, 387, 280, 11);
    [self.view.layer insertSublayer:self.progressView.layer below:self.graphView.layer];
    [self animaterGraphViewHeightToScale:SHRINK_SCALE];
}

- (void)hideTimer
{
    //[self.progressView removeFromSuperview];
    [self animaterGraphViewHeightToScale:1.0];
}

- (void)animaterGraphViewHeightToScale:(CGFloat)scale
{
    if(!CGPointEqualToPoint(self.graphView.layer.anchorPoint, CGPointMake(0, 0))){
        CGRect frame = self.graphView.layer.frame;
        self.graphView.layer.anchorPoint = CGPointMake(0, 0);
        self.graphView.layer.frame = frame;
    }

    
    [UIView animateWithDuration:1 animations:^{
        self.graphView.transform = CGAffineTransformMakeScale(1.0, scale);
    }];
    

//    self.graphView.layer.zPosition = 10;
//    CATransform3D transform = CATransform3DScale(self.graphView.layer.transform, 1.0, scale, 1.0);
//    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"]; 
//    animation.duration = 0.5;
//    animation.fromValue = [NSValue valueWithCATransform3D:self.graphView.layer.transform];
//    animation.toValue = [NSValue valueWithCATransform3D:transform];
//    
//    self.graphView.layer.transform = transform;
//    
//    //[self.graphView.layer layoutIfNeeded];
//    [self.graphView.layer addAnimation:animation forKey:@"animateTransform"];
}

#pragma mark - Graph view delegate

- (NSString *)descriptionForAnswerAtIndex:(NSInteger)index
{
    return [(Answer *)[self.question.answers objectAtIndex:index] answerText];
}

#pragma mark - Scroll view delegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphView;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphView.frame = self.view.bounds;
    self.graphView.delegate = self;
    self.graphView.showAxes = YES;
    self.graphView.showValueLabels = YES;
    self.graphView.bottomYOffset = 10;
    self.graphView.shaddow = YES;
    self.graphView.roundedCorners = YES;
    self.graphView.correctIndex = self.question.correctIndex;
    self.graphView.bannerText = @"CS193P";
    
    self.graphView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.graphView.layer.shadowOffset = CGSizeMake(0, 6);
    self.graphView.layer.shadowOpacity = .8;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.graphView setAnswers: self.question.numberAnswers animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGraph:) name:NSManagedObjectContextDidSaveNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
@end
