//
//  EditableCell.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/11/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditableCell;

@protocol EditableCellDelegate <NSObject>

//Should have passed the cell here...
- (BOOL)userCanEditCell:(EditableCell *)sender;

- (void)editableCelldidBeginEditting:(EditableCell *)cell;

- (void)editableCelldidEndEditting:(EditableCell *)cell;

@optional

//This method must be implemented to allow editting
- (void)userDidChangeCellTitleToTitle:(NSString *)toTitle forCell:(EditableCell *)sender;

@end

@interface EditableCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<EditableCellDelegate> delegate;
@end
