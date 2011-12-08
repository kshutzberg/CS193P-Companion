//
//  EntityPickerTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "EntityPickerTableViewController.h"

@interface EntityPickerTableViewController()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@end

@implementation EntityPickerTableViewController{
    UINavigationController * _navcon;
}
@synthesize addButton = _addButton;
@synthesize delegate = _delegate;
@synthesize selectedObjects = _selectedObjects;
@synthesize mode = _mode;

@synthesize hidesToolBarInNavigationController = _hidesToolBarInNavigationController;


- (NSMutableArray *)selectedObjects
{
    if(!_selectedObjects){
        _selectedObjects = [[NSMutableArray alloc] init];
    }
    return _selectedObjects;
}

- (void)addNewEntity
{
    [self.delegate userWantsToAddNewEntityforEntityType:self.fetchedResultsController.fetchRequest.entityName];
    //[self.fetchedResultsController.managedObjectContext save:NULL];
    [self performFetch];
    
}

- (UIBarButtonItem *)addButton
{
    if(!_addButton){
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewEntity)];
    }
    return _addButton;
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    //If the delegae supports ADD and an ADD button doesn't exist, make one:
    if([self.delegate respondsToSelector:@selector(userWantsToAddNewEntityforEntityType:)] && !_addButton)
    {
        NSMutableArray *items = [self.toolbarItems mutableCopy];
        [items  addObject:self.addButton];
        self.toolbarItems = items;
    }
    //Else If the delegae does NOT support ADD and an ADD button DOES exist, delete it:
    else if(![self.delegate respondsToSelector:@selector(userWantsToAddNewEntityforEntityType:)] && _addButton)
    {
        NSMutableArray *items = [self.toolbarItems mutableCopy];
        [items  removeObject:self.addButton];
        self.toolbarItems = items;
    }
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.hidesToolBarInNavigationController && self.navigationController.toolbarHidden)
        [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    _navcon = self.navigationController;
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if(!_navcon.toolbarHidden)[_navcon setToolbarHidden:YES animated:animated];
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EntityCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([object isKindOfClass:[Topic class]]) {
        cell.textLabel.text = [(Topic *)object topicName];
    }
    else if ([object isKindOfClass:[Lecture class]]) {
        cell.textLabel.text = [(Lecture *)object lectureName];
    }
    else if ([object isKindOfClass:[Answer class]]) {
        cell.textLabel.text = [(Answer *)object answerText];
    }
    
    cell.accessoryType = [self.selectedObjects containsObject:object] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:object];
        
        //Remove the object from selected if it is selected
        if([self.selectedObjects containsObject:object]){
            NSMutableArray *arr = [self.selectedObjects mutableCopy];
            [arr removeObject:object];
            self.selectedObjects = arr;
        }
        
        [self.fetchedResultsController.managedObjectContext save:NULL];
        [self performFetch];
    }   
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Dont allow the selected cell to be deleted when the mode requires at least one cell to be deleted
    if (self.mode == PickerModeSingleSelection && [self.selectedObjects containsObject:object]){
        return UITableViewCellEditingStyleNone;
    }
    
    else{
        return UITableViewCellEditingStyleDelete;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    //Notify the delegae what the user has picked: (If the delegate wants these messages and the VC is configured to send them)
    if(self.mode == PickerModeNoSelection || ![self.delegate respondsToSelector:@selector(userDidPickEntities:forEntityType:)])return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    if (self.mode == PickerModeSingleSelection || self.mode == PickerModeOptionalSingleSelection) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[self.fetchedResultsController indexPathForObject:[self.selectedObjects lastObject]]];
        
        //If the user has already selected an object and they choose a DIFFERENT object
        if ([self.selectedObjects lastObject] && [self.selectedObjects lastObject]!= object) {
            [self.selectedObjects replaceObjectAtIndex:0 withObject:object];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        //If the user has selected an object and they try to DESELECT the same object (Do nothing here if MODE = PickerSingleSelection)
        else if([self.selectedObjects lastObject] && [self.selectedObjects lastObject] == object && self.mode == PickerModeOptionalSingleSelection){
            [self.selectedObjects removeObject:object];
            cell.accessoryType = UITableViewCellAccessoryNone;
            oldCell.accessoryType = UITableViewCellAccessoryNone; //This line of code should be redundant, because oldCell should equal cell
        }
        else if (self.mode == PickerModeOptionalSingleSelection){
            [self.selectedObjects addObject:object];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    else if(self.mode == PickerModeMultipleSelection){
        if ([self.selectedObjects containsObject:object]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedObjects removeObject:object];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selectedObjects addObject:object];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.delegate userDidPickEntities:self.selectedObjects forEntityType:self.fetchedResultsController.fetchRequest.entityName];
}


@end
