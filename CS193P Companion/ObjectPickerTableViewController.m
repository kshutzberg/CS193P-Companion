//
//  AnswerPickerTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/9/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ObjectPickerTableViewController.h"
#import "EditableCell.h"



@interface ObjectPickerTableViewController()<EditableCellDelegate>{ UINavigationController *_navcon; }

/* Use these properties to temporary disable certain functions, even if they are generally allowed */
@property (nonatomic) BOOL canAdd;
@property (nonatomic) BOOL canDelete;
@property (nonatomic) BOOL canEdit;

- (IBAction)addNewObject;

@end

@implementation ObjectPickerTableViewController
@synthesize name = _name;
@synthesize identifier = _identifier;

@synthesize hidesToolBarInNavigationController = _hidesToolBarInNavigationController;

@synthesize objects = _objects;
@synthesize selectedObjects = _selectedObjects;

@synthesize mode = _mode;
@synthesize delegate = _delegate;

@synthesize allowsAdding = _allowsAdding    , canAdd = _canAdd;
@synthesize allowsDeletion = _allowsDeletion, canDelete = _canDelete;
@synthesize allowsEditting = _allowsEditting, canEdit = _canEdit;

@synthesize doneButton = _doneButton;
@synthesize cancelButton = _cancelButton;
@synthesize addButton = _addButton;


- (void)configureDefaultValues
{
    self.canEdit = YES;
    self.canAdd = YES;
    self.canDelete = YES;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self configureDefaultValues];
    }
    return self;
}

- (void)awakeFromNib{ [super awakeFromNib]; [self configureDefaultValues]; }

- (void)addNewObject { [self.delegate objectPicker:self wantsToAddNewObjectAtIndexPath:nil]; }

- (void)setName:(NSString *)name
{
    _name = [name copy];
    if(!self.title)self.title = name;
    [self.tableView reloadSectionIndexTitles];
}

- (void)setObjects:(NSArray *)objects
{
    if (_objects != objects) {
        _objects = objects;
        [self.tableView reloadData];
    }
}

- (UIBarButtonItem *)addButton
{
    if(!_addButton){
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewObject)];
    }
    return _addButton;
}

- (NSMutableArray *)selectedObjects
{
    if(!_selectedObjects){
        _selectedObjects = [[NSMutableArray alloc] init];
    }
    return _selectedObjects;
}

-(void)setSelectedObjects:(NSMutableArray *)selectedObjects
{
    _selectedObjects = selectedObjects;
    for (id object in selectedObjects) {
        NSIndexPath *indexPath = [self indexPathForObject:object];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self visualSelectCell:cell];
    }
}


- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.objects objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id)object
{
    NSUInteger index = [self.objects indexOfObject:object];
    return [NSIndexPath indexPathForRow:index inSection:0];
}


#pragma mark - Editable cell delegate

-(BOOL)userCanEditCell:(EditableCell *)sender
{
    return [self.delegate respondsToSelector:@selector(objectPicker:didChangeCellTitleForObject:atIndexPath:toTitle:)];
}

-(void)userDidChangeCellTitleToTitle:(NSString *)toTitle forCell:(EditableCell *)sender
{
    if([self.delegate respondsToSelector:@selector(objectPicker:didChangeCellTitleForObject:atIndexPath:toTitle:)])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        id object = [self.objects objectAtIndex:indexPath.row];
        
        [self.delegate objectPicker:self didChangeCellTitleForObject:object atIndexPath:indexPath toTitle:toTitle];
    }
}

- (void)editableCelldidBeginEditting:(EditableCell *)cell
{
    self.canEdit = NO;
    self.canDelete = NO;
    
    if(self.tableView.editing){
        [self.tableView setEditing:NO animated:YES];
        
        //Update the edit button item to say Editting instead of done
    }
    self.editButtonItem.enabled = NO;
    self.doneButton.enabled = NO;
}

- (void)editableCelldidEndEditting:(EditableCell *)cell
{
    self.canEdit = YES;
    self.canDelete = YES;
    
    self.editButtonItem.enabled = YES;
    if([self.editButtonItem.title isEqualToString:@"Done"])
        [self.tableView setEditing:YES animated:YES];
    self.doneButton.enabled = YES;
}

#pragma mark - Modal view controller

- (void)cancel
{
    if ([self.delegate respondsToSelector:@selector(objectPickerDidCancel:)]) {
        [self.delegate objectPickerDidCancel:self];
    }
    else [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)done
{
    if ([self.delegate respondsToSelector:@selector(objectPicker:finishedWithSelectedObjects:)]) {
        [self.delegate objectPicker:self finishedWithSelectedObjects:self.selectedObjects];
    }
    else [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (UIBarButtonItem *)cancelButton
{
    if(!_cancelButton){
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    }
    return _cancelButton;
}

- (UIBarButtonItem *)doneButton
{
    if(!_doneButton){
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    }
    return _doneButton;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.navigationController.presentingViewController){
        if(self.allowsEditting){
            self.navigationItem.leftBarButtonItem = self.doneButton;
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
        }
        else
        {
            self.navigationItem.leftBarButtonItem = self.cancelButton;
            self.navigationItem.rightBarButtonItem = self.doneButton;
        }
        
    }
    
    if (!self.hidesToolBarInNavigationController && self.navigationController.toolbarHidden){
        [self.navigationController setToolbarHidden:NO animated:YES];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //If the delegae supports ADD and an ADD button doesn't exist, make one:
    if([self.delegate respondsToSelector:@selector(objectPicker:wantsToAddNewObjectAtIndexPath:)] && !_addButton)
    {
        NSMutableArray *items = [self.toolbarItems mutableCopy];
        [items  addObject:self.addButton];
        self.toolbarItems = items;
    }
    //Else If the delegae does NOT support ADD and an ADD button DOES exist, delete it:
    else if(![self.delegate respondsToSelector:@selector(objectPicker:wantsToAddNewObjectAtIndexPath:)] && _addButton)
    {
        NSMutableArray *items = [self.toolbarItems mutableCopy];
        [items  removeObject:self.addButton];
        self.toolbarItems = items;
    }
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count];
}

- (EditableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[EditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //This provides a basic cell with text for STRINGS.  Anything else it is highly recommended that this class be subclassed with a custom implementation of - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    
    id object = [self.objects objectAtIndex:indexPath.row];
    NSString *cellText = [object description];
    
    // Configure the cell...
    
    if(cell.textField){
        cell.textField.text = cellText;
        cell.textField.textAlignment = UITextAlignmentCenter;
    }
    else
    {
        cell.textLabel.text = cellText;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    if ([self.selectedObjects containsObject:object]) {
        [self visualSelectCell:cell];
    }
    
    cell.delegate = self;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.name ? self.name : @" ";
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsDeletion && self.canDelete && [self.delegate respondsToSelector:@selector(objectPicker:wantsToDeleteObject:)];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        id object = [self objectAtIndexPath:indexPath];
        
        [self.delegate objectPicker:self wantsToDeleteObject:object];
    }     
}


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

- (void)visualDeselectCell:(UITableViewCell *)cell { cell.highlighted = NO; }
- (void)visualSelectCell:(UITableViewCell *)cell { cell.highlighted = YES; }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Notify the delegae what the user has picked: (If the delegate wants these messages and the VC is configured to send them)
    if(self.mode == PickerModeNoSelection || ![self.delegate respondsToSelector:@selector(objectPicker:didChooseObjects:)])return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    id object = [self objectAtIndexPath:indexPath];
    
    
    if (self.mode == PickerModeSingleSelection || self.mode == PickerModeOptionalSingleSelection) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[self indexPathForObject:[self.selectedObjects lastObject]]];
        
        //If the user has already selected an object and they choose a DIFFERENT object
        if ([self.selectedObjects lastObject] && [self.selectedObjects lastObject]!= object) {
            [self.selectedObjects replaceObjectAtIndex:0 withObject:object];
            [self visualDeselectCell:oldCell];
            [self visualSelectCell:cell];
        }
        //If the user has selected an object and they try to DESELECT the same object (Do nothing here if MODE = PickerSingleSelection)
        else if([self.selectedObjects lastObject] && [self.selectedObjects lastObject] == object && self.mode == PickerModeOptionalSingleSelection){
            [self.selectedObjects removeObject:object];
            [self visualDeselectCell:cell];
            [self visualDeselectCell:oldCell];; //This line of code should be redundant, because oldCell should equal cell
        }
        //If selected objects is empty, add it
        else if (![self.selectedObjects count]){
            [self.selectedObjects addObject:object];
            [self visualSelectCell:cell];
        }
    }
    
    else if(self.mode == PickerModeMultipleSelection){
        if ([self.selectedObjects containsObject:object]) {
            [self visualDeselectCell:cell];
            [self.selectedObjects removeObject:object];
        }
        else{
            [self visualSelectCell:cell];
            [self.selectedObjects addObject:object];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.delegate objectPicker:self didChooseObjects:self.selectedObjects];
}

@end
