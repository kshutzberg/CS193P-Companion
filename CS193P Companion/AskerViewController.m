//
//  AskerViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "AskerViewController.h"
#import "GKMatchHandler.h"
#import "DataMessage.h"
#import "ObjectPickerTableViewController.h"

@interface AskerViewController()<UIActionSheetDelegate, ObjectPickerTableViewControllerDelegate>
@property (nonatomic, weak) UIActionSheet *actionSheet;
@end


@implementation AskerViewController
@synthesize answers = _answers;

@synthesize titleLabel = _titleLabel;
@synthesize promptLabel= _promptLabel;
@synthesize countdownLabel = _countdownLabel;

@synthesize answerButton = _answerButton;

@synthesize questionTitle = _questionTitle;
@synthesize prompt = _prompt;
@synthesize completionDate = _completionDate;

@synthesize timeLeft = _timeLeft;

@synthesize actionSheet = _actionSheet;

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)answerQuestion:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Answer" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    for (NSString *answer in self.answers) {
        [actionSheet addButtonWithTitle:answer];
    }
    [actionSheet showInView:self.view];
    self.actionSheet = actionSheet;
    
}

- (void)updateTime:(NSTimer *)timer
{
    self.timeLeft--;
    if (self.timeLeft >= 0) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"m:ss"];
        self.countdownLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.timeLeft]];
    }
    else
    {
        [timer invalidate];
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Object picker table view controller delegate

- (void)objectPicker:(ObjectPickerTableViewController *)picker didChooseObjects:(NSArray *)objects
{
    NSUInteger answerIndex;
    
    if(![objects count])answerIndex = NSNotFound;
    else answerIndex = [self.answers indexOfObject:[objects lastObject]];
    
    NSData *answerData = [DataMessage dataWithAnswerIndex:answerIndex];
    
    GKMatchHandler *handler = [GKMatchHandler sharedHandler];
    NSArray *players = [NSArray arrayWithObject:handler.instructorID];
    
    [handler.match sendData:answerData toPlayers: players withDataMode:GKSendDataReliable error:NULL];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.cancelButtonIndex == 0)buttonIndex--;
    
    NSData *data = [DataMessage dataWithAnswerIndex:buttonIndex];
    [[GKMatchHandler sharedHandler].match sendDataToAllPlayers:data withDataMode:GKSendDataUnreliable error:NULL];
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = self.questionTitle;
    self.title = self.questionTitle;
    
    self.promptLabel.text = self.prompt;
    
    if(self.timeLeft > 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"m:ss"];
        self.countdownLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.timeLeft]];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
    else
    {
        NSLog(@"Student received question %f seconds late",0 - self.timeLeft);
    }
    ObjectPickerTableViewController *answerTVC = [[ObjectPickerTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //Set Picker options
    answerTVC.mode = PickerModeOptionalSingleSelection;
    answerTVC.objects = self.answers;
    answerTVC.delegate = self;
    
    
    answerTVC.tableView.frame = self.answerButton.frame;
    answerTVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
    
    [self.answerButton removeFromSuperview];
    
    [self addChildViewController:answerTVC];
    [self.view addSubview:answerTVC.tableView];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
}

@end
