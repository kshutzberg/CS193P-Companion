//
//  EntityPickerTableViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Entities+Create.h"

//A class to be used to pick an entity from a list shown in a core data table view controller

@protocol EntityPickerDelegate <NSObject>
@optional
- (void)userDidPickEntities:(NSArray *)entities forEntityType:(NSString *)type; //type is the class name
- (void)userWantsToAddNewEntityforEntityType:(NSString *)type;; //Implementing this method will add an add button to the bottom toolbar

@end

typedef enum{
    PickerModeNoSelection = 0,
    PickerModeSingleSelection = 1,
    PickerModeMultipleSelection = 2,
    PickerModeOptionalSingleSelection = 3
}EntityPickerSelectionMode;

@interface EntityPickerTableViewController : CoreDataTableViewController

@property (nonatomic, weak) id<EntityPickerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *selectedObjects; //An array of the dataObjects that correspond to the selected cells - set this to set which objects are selected

@property (nonatomic) BOOL hidesToolBarInNavigationController; //I would have made this showsToolBar... but then I would have to actually set it to yes each time I use it, so I am taking advantage of the fact that iOS defaults BOOLs to NO.

@property (nonatomic) EntityPickerSelectionMode mode; //PickerModeNoSelection by default

//Informs the delegate that the user wants to add a new entity.  At this point, the delegate should probably display a modal view contoller allowing the user to do so.
- (IBAction)addNewEntity;

@end