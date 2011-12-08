//
//  AskerViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "AskerViewController.h"
#import "GKMatchHandler.h"
#import "QuestionMessage.h"

@interface AskerViewController()<UIActionSheetDelegate>

@end

@implementation AskerViewController
@synthesize titleLabel;
@synthesize promptLabel;
@synthesize answers = _answers;

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)answerQuestion:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Answer" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: nil];
    for (NSString *answer in self.answers) {
        [sheet addButtonWithTitle:answer];
    }
    [sheet showInView:self.view];
    
}

#pragma mark - Action sheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.cancelButtonIndex == 0)buttonIndex--;
    
    NSData *data = [QuestionMessage dataWithAnswerIndex:buttonIndex];
    [[GKMatchHandler sharedHandler].match sendDataToAllPlayers:data withDataMode:GKSendDataUnreliable error:NULL];
}

@end
