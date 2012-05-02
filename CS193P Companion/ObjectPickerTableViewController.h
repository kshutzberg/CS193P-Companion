//
//  AnswerPickerTableViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/9/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableCell.h"
#import "PickerSelectionModes.h"

/*
 Object Picker Table View Controller (OPTVC)
 -------------------------------------------
 A tool for getting user input, specifically for selecting from  and/or modifying a list of objects. 
 This class provides a table view that can be presented modally that will report user selections and or changes to its delegate.
 
 For Core Data integration and NSFetchedResultsController compatability, see EntityPickerTableViewController.
*/

@class ObjectPickerTableViewController;

/*
 Object Picker Table View Controller Delegate Protocol
 -----------------------------------------------------
 The OPTVC's delegate can optionally subscribe to changes in the user selection, or user modification of the actual data if such modification is allowed.
 Actions that the delegate can choose to enable and handle:
 
    - Deleting: See "Deleting" below
    - Adding:   See "Adding" below
    - Editting: See ""Editting" below
 
 */

@protocol ObjectPickerTableViewControllerDelegate <NSObject>

@optional

/* Called Every time the user chooses an object */


- (void)objectPicker:(ObjectPickerTableViewController *)picker didChooseObjects:(NSArray *)objects;


/* Methods for when the OPTVC is Modal */


- (void)objectPicker:(ObjectPickerTableViewController *)picker finishedWithSelectedObjects:(NSArray *)objects;

- (void)objectPickerDidCancel:(ObjectPickerTableViewController *)picker ;   //If there is no implementation, the modal view controller is dismissed automatically


/*
 Deleting:
 ---------
 To allow deleting, implement the required delegate methods AND set OPTVC's @property BOOL allowsDeletion to YES.
 This will put an edit button as the rightBarButtonItem of the navigationItem, unless a rightBrButtonItem has already been specified.
 */


- (void)objectPicker:(ObjectPickerTableViewController *)picker wantsToDeleteObject:(id)object;      //Required for Deleting


/*
 Adding:
 -------
 To allow the user to add objects, implement the required delegate methods AND set OPTVC's @property BOOL allowsAdding to YES.
 This will add an Add (+) button at the bottom left of the OPTVC if the addButton property has not already been set.
 */


- (void)objectPicker:(ObjectPickerTableViewController *)picker wantsToAddNewObjectAtIndexPath:(NSIndexPath *)indexPath;     //Required for Adding

//! @param indexPath: The indexPath at which the user clicked the + button, or nill if it was not clicked on a cell
//! @param indexPath: For now, this will ALWAYS be nil.


/*
 Editting:
 ---------
 To allow the user to edit objects, implement the required delegate methods AND set OPTVC's @property BOOL allowsEditting to YES.
 This will make all cells editable when the user long presses on the cell.
 */


- (void)objectPicker:(ObjectPickerTableViewController *)picker didChangeCellTitleForObject:(id)object atIndexPath:(NSIndexPath *)indexPath toTitle:(NSString *)toTitle;

- (BOOL)objectPicker:(ObjectPickerTableViewController *)canEditObject:(id)object;   //Default is YES.  Implement to enable conditional editting


@end



@interface ObjectPickerTableViewController : UITableViewController <EditableCellDelegate>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSMutableArray *selectedObjects; //An array of the dataObjects that correspond to the selected cells - set this to set which objects are selected


/* Configuring the Picker */
@property (nonatomic) PickerSelectionMode mode; //DEFAULT: PickerModeNoSelection (See PickerSelectionModes.h)

@property (nonatomic, weak) id<ObjectPickerTableViewControllerDelegate> delegate;


/* Extra Functionality */
@property (nonatomic) BOOL allowsAdding;
@property (nonatomic) BOOL allowsDeletion;
@property (nonatomic) BOOL allowsEditting; //This will not be useful (for now) unless allows deletion is set to YES.  Unfortunately reordering without deletion is not yet supported

@property (nonatomic) BOOL hidesToolBarInNavigationController;

@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;



/* Table View Methods */

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForObject:(id)object;



//UI representation of SELECTED and DESELECTED cells.

- (void)visualDeselectCell:(UITableViewCell *)cell;

- (void)visualSelectCell:(UITableViewCell *)cell;

@end


/*
 Subclassing Notes:
 -----------------------------------
 Methods NOT to override:
 
 
 Methods to override CAREFULLY:
 
 - tableView:cellForRowAtIndexPath:
    Use EditableCell instead of UITableViewCell
    You MUST set the cell's delegate to self.
    You MUST visually select cells that are contained in selected objects
 
 
 Methods you will likely want to override:

 - tableView:cellForRowAtIndexPath: (see above)
 
 - visualSelectCell, - visualDeselectCell
    Override these mtehods to change how cells look when they are selected or deselected.
 */
