//
//  QuestionsTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "QuestionsTableViewController.h"
#import "QuestionInfoViewController.h"
#import "Entities+Create.h"
#import "QuestionCell.h"
#import "BarGraphView.h"

@interface QuestionsTableViewController(){
    UINavigationController *_navcontroller;
}
@end

@implementation QuestionsTableViewController
@synthesize currentLecture = _currentLecture;
@synthesize currentTopic = _currentTopic;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Question *question = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
    
    if ([segue.identifier isEqualToString:@"showQuestion"]) {
        QuestionInfoViewController *questionVC = segue.destinationViewController;
        questionVC.question = question;
    }
    else if([segue.identifier isEqualToString:@"newQuestion"]){
        QuestionInfoViewController *questionVC = segue.destinationViewController;
        NSManagedObjectContext *context = self.fetchedResultsController.managedObjectContext;
        
        Lecture *lecture = self.currentLecture;
        Topic *topic = self.currentTopic;
        
        if(!lecture)lecture = [[context executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:ENTITY_LECTURE] error:NULL] lastObject];
        
        questionVC.question = [Question nextQuestionForLecture:lecture];
        if (topic)[questionVC.question addTopicsObject:topic];
    }
}

#pragma mark - View life cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
    [self performFetch];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    _navcontroller = self.navigationController;
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    //[_navcontroller setToolbarHidden:YES animated:YES];
    [super viewDidDisappear:animated];
}
#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuestionCell";
    
    QuestionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[QuestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Question *question = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = question.questionName;
    cell.detailTextLabel.text = question.prompt;
    
    //Configure the iconView:
    BarGraphView *icon = (BarGraphView *)cell.iconView;
    icon.answerColor = [UIColor blueColor];
    icon.correctColor = [UIColor greenColor];
    icon.bottomYOffset = 0;
    icon.answerWidthFactor = .6;
    icon.roundedCorners = NO;
    
    //Test the view
    icon.correctIndex = question.correctIndex;
    
    [icon setAnswers:question.numberAnswers animated:YES]; 
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Question *question = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:question];
        [self.fetchedResultsController performFetch:NULL];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.fetchedResultsController.managedObjectContext save:NULL];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
}


@end
