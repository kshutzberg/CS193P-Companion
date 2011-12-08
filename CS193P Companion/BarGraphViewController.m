//
//  BarGraphViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "BarGraphViewController.h"
#import "Entities+Create.h"

@interface BarGraphViewController()<UIScrollViewDelegate, BarGraphViewDelegate>

@end

@implementation BarGraphViewController
@synthesize graphView = _graphView;
@synthesize question = _question;

- (void)updateGraph:(NSNotification *)notification
{
    [self.graphView setAnswers:self.question.numberAnswers animated:YES];
    [self.graphView setNeedsDisplay];
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
    self.graphView.delegate = self;
    self.graphView.showAxes = YES;
    self.graphView.showValueLabels = YES;
    self.graphView.bottomYOffset = 10;
    self.graphView.shaddow = YES;
    self.graphView.roundedCorners = YES;
    self.graphView.correctIndex = self.question.correctIndex;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGraph:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [self.graphView setAnswers: self.question.numberAnswers animated:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
