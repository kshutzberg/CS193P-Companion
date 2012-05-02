//
//  PickerSelectionModes.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/9/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

/*
 Determines the rules for what the user can select in the Picker Table View Controller 
*/

typedef enum{
    PickerModeNoSelection = 0,
    PickerModeSingleSelection = 1,
    PickerModeMultipleSelection = 2,
    PickerModeOptionalSingleSelection = 3
}PickerSelectionMode;


