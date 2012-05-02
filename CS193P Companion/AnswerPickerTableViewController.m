//
//  AnswerPickerTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/11/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "AnswerPickerTableViewController.h"
#import "Entities+Create.h"
#import "EditableCell.h"

@interface AnswerPickerTableViewController()

@end

@implementation AnswerPickerTableViewController

-(void)visualSelectCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)visualDeselectCell:(UITableViewCell *)cell
{
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (EditableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AnswerCell";
    
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Answer *answer = [self objectAtIndexPath:indexPath];
    
    cell.textField.text = answer.answerText;
    
    if ([self.selectedObjects containsObject:answer]) {
        [self visualSelectCell:cell];
    }
    
    cell.delegate = self;
    return cell;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    Answer *answer = [self objectAtIndexPath:sourceIndexPath];
    
    NSMutableOrderedSet *answers = [answer.question.answers mutableCopy];
    [answers removeObject:answer];
    [answers insertObject:answer atIndex:destinationIndexPath.row];
    answer.question.answers = answers;
    self.objects = [answers array];
    if([self.delegate respondsToSelector:@selector(objectPicker:didChooseObjects:)])
        [self.delegate objectPicker:self didChooseObjects:self.selectedObjects];
    
    for (UITableViewCell *cell in [tableView visibleCells] ) {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        Answer *answer = [self objectAtIndexPath:indexPath];
        if([self.selectedObjects containsObject:answer])
            [self visualSelectCell:cell];
        else
            [self visualDeselectCell:cell];
    }
    
}

@end
