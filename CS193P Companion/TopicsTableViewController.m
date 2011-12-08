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

@implementation TopicsTableViewController

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

#pragma mark - View life cycle

-(void)viewDidAppear:(BOOL)animated
{
    if(!self.navigationController.toolbarHidden){
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    [super viewDidAppear:animated];
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
    
    cell.textLabel.text = topic.topicName;
    
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
