//
//  TopicsTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "TopicsTableViewController.h"
#import "Topic.h"
#import "QuestionsTableViewController.h"
#import "Entities+Create.h"

@interface TopicsTableViewController(){
    UINavigationController *_navcontroller;
}
@end

@implementation TopicsTableViewController
- (IBAction)addTopic:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Topic" message:@"Please enter the name of the new topic." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [alert show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showQuestions"]){
        QuestionsTableViewController *questionsTableViewController = segue.destinationViewController;
        
        UITableViewCell *cell = sender;
        Topic *topic = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
        questionsTableViewController.currentTopic = topic;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_QUESTION];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"questionName" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
        request.sortDescriptors = descriptors;
        request.predicate = [NSPredicate predicateWithFormat:@"any topics.topicName = %@",topic.topicName];
        
        questionsTableViewController.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.fetchedResultsController.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}

#pragma  mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *topicName = [alertView textFieldAtIndex:0].text;
    if ([topicName length]){
        [Topic topicWithString:topicName inContext:self.fetchedResultsController.managedObjectContext];
    }
    [self.fetchedResultsController.managedObjectContext save:NULL];
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
    static NSString *CellIdentifier = @"TopicCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_QUESTION];
    request.predicate = [NSPredicate predicateWithFormat:@"any topics.topicName = %@",topic.topicName];
    
    int numQuestions = [topic.managedObjectContext countForFetchRequest:request error:NULL];
    
    cell.textLabel.text = topic.topicName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i questions",numQuestions];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Topic *topic = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:topic];
        [self.fetchedResultsController.managedObjectContext save:NULL];
        [self performFetch];
    }   
}

@end
