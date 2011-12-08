//
//  QuestionInfoViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "QuestionInfoViewController.h"
#import "Entities+Create.h"
#import "EntityPickerTableViewController.h"
#import "BarGraphView.h"
#import "BarGraphViewController.h"
#import "GKMatchHandler.h"
#import "QuestionMessage.h"

@interface QuestionInfoViewController() <EntityPickerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *promptField;

@property (weak, nonatomic) IBOutlet UITableViewCell *lectureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *topicCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *askCell;
@end

@implementation QuestionInfoViewController
@synthesize question = _question;

@synthesize titleField = _titleField;
@synthesize promptField = _promptField;
@synthesize lectureCell = _lectureCell;
@synthesize topicCell = _topicCell;
@synthesize askCell = _askCell;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLectures"]) {
        EntityPickerTableViewController *lecturesVC = segue.destinationViewController;
        lecturesVC.mode = PickerModeSingleSelection;
        lecturesVC.selectedObjects = [NSMutableArray arrayWithObject:self.question.lecture];
        lecturesVC.delegate = self;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_LECTURE];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lectureName" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
        request.sortDescriptors = descriptors;
        lecturesVC.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.question.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    
    else if([segue.identifier isEqualToString:@"showTopics"]){
        EntityPickerTableViewController *topicsVC = segue.destinationViewController;
        topicsVC.mode = PickerModeMultipleSelection;
        topicsVC.selectedObjects = [[self.question.topics allObjects] mutableCopy];
        topicsVC.delegate = self;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_TOPIC];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"topicName" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
        request.sortDescriptors = descriptors;
        
        topicsVC.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.question.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    
    else if([segue.identifier isEqualToString:@"showAnswers"]){
        EntityPickerTableViewController *answersVC = segue.destinationViewController;
        answersVC.mode = PickerModeOptionalSingleSelection;
        if (self.question.correctIndex >=0 && self.question.correctIndex < self.question.answers.count) {
            answersVC.selectedObjects = [NSMutableArray arrayWithObject:[self.question.answers objectAtIndex:self.question.correctIndex]];
        }
        answersVC.delegate = self;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_ANSWER];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"answerText" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
        request.sortDescriptors = descriptors;
        request.predicate = [NSPredicate predicateWithFormat:@"question = %@",self.question];
        
        answersVC.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.question.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }

    else if([segue.identifier isEqualToString:@"showResults"]){
        BarGraphViewController *viewController = segue.destinationViewController;
        viewController.question = self.question;
    }
    
}

- (void)broadCastQuestion:(Question *)question
{
    NSData *packet = [QuestionMessage dataWithQuestion:self.question];
    
    NSError *error;
    [GKMatchHandler sharedHandler].currentQuestion = question;
    [[GKMatchHandler sharedHandler].match sendDataToAllPlayers: packet withDataMode: GKMatchSendDataUnreliable error:&error];
    if (error != nil)
    {
        NSLog(@"%@",error.debugDescription);
    }
}

#pragma mark - Entity picker delegate

-(void)userDidPickEntities:(NSArray *)entities forEntityType:(NSString *)type
{
    if ([type isEqualToString:ENTITY_LECTURE]) {
        self.question.lecture = [entities lastObject];
    }
    else if ([type isEqualToString:ENTITY_TOPIC]) {
        self.question.topics = [NSSet setWithArray:entities];
    }
    else if([type isEqualToString:ENTITY_ANSWER]) {
        self.question.correctIndex = [self.question.answers indexOfObject:[entities lastObject]];
    }
    [self.question.managedObjectContext save:NULL];
}

-(void)userWantsToAddNewEntityforEntityType:(NSString *)type
{
    if ([type isEqualToString:ENTITY_LECTURE]) {
        Lecture *lecture = [Lecture nextLectureInContext:self.question.managedObjectContext];
        self.question.lecture = lecture;
    }
    else if ([type isEqualToString:ENTITY_TOPIC]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Topic" message:@"Please enter the name of the new topic." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
        [alert show];
    }
    else if ([type isEqualToString:ENTITY_ANSWER]) {
        Answer *answer = [Answer nextAnswerForQuestion:self.question];
        NSMutableOrderedSet *set = [self.question.answers mutableCopy];
        [set addObject:answer];
        self.question.answers = set; //Good job apple on generating faulty core data accessors
    }
    [self.question.managedObjectContext save:NULL];
}

#pragma  mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *topicName = [alertView textFieldAtIndex:0].text;
    if ([topicName length]){
        Topic *topic = [Topic topicWithString:topicName inContext:self.question.managedObjectContext];
        [self.question addTopicsObject:topic];
        topic.numQuestions++;
    }
    [self.question.managedObjectContext save:NULL];
}

#pragma mark - Text view delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.titleField) {
        self.question.questionName = textField.text;
    }
    else if(textField == self.promptField){
        self.question.prompt = textField.text;
    }

    [self.question.managedObjectContext save:NULL];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleField && ![textField.text length])return NO;
    else{ 
        [textField resignFirstResponder];
        return YES;
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Edit Question";
    self.titleField.text = self.question.questionName;
    self.promptField.text = self.question.prompt;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTitleField:nil];
    [self setPromptField:nil];
    [self setLectureCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lectureCell.detailTextLabel.text = self.question.lecture.lectureName;
    int numTopics = [self.question.topics count];
    if (numTopics == 1) self.topicCell.detailTextLabel.text = @"1 Topic";
    else self.topicCell.detailTextLabel.text = [NSString stringWithFormat:@"%d Topics", numTopics];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(!self.navigationController.toolbarHidden){
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.question.managedObjectContext save:NULL];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath isEqual: [self.tableView indexPathForCell:self.askCell]]){
        [self broadCastQuestion:self.question];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
