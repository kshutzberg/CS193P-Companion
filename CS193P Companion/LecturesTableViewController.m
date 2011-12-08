//
//  LecturesTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "LecturesTableViewController.h"
#import "Lecture.h"
#import "QuestionsTableViewController.h"
#import "Entities+Create.h"

@interface LecturesTableViewController()<EntityPickerDelegate>{
    UINavigationController *_navcontroller;
}
@end

@implementation LecturesTableViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = sender;
    Lecture *lecture = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
    
    if([segue.identifier isEqualToString:@"showQuestions"]){
        QuestionsTableViewController *questionsTableViewController = segue.destinationViewController;
        questionsTableViewController.currentLecture = lecture;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_QUESTION];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"questionName" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
        request.sortDescriptors = descriptors;
        request.predicate = [NSPredicate predicateWithFormat:@"lecture.lectureName = %@",lecture.lectureName];
        
        questionsTableViewController.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.fetchedResultsController.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

-(IBAction)addLecture
{
    [Lecture nextLectureInContext:self.fetchedResultsController.managedObjectContext];
    [self.fetchedResultsController.managedObjectContext save:NULL];
    [self performFetch];
}

#pragma mark - View life cycle

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    _navcontroller = self.navigationController;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [_navcontroller setToolbarHidden:YES animated:animated];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LectureCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Lecture *lecture = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = lecture.lectureName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Lecture *lecture = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:lecture];
        [self.fetchedResultsController.managedObjectContext save:NULL];
        [self performFetch];
    }   
}


@end
