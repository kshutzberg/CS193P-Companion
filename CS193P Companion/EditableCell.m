//
//  EditableCell.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/11/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "EditableCell.h"

@interface EditableCell() <UITextFieldDelegate>
- (void)setup;
- (void)userWantsToEditCell;
@end

@implementation EditableCell
@synthesize textField = _textField;
@synthesize delegate = _delegate;

- (void)setTextField:(UITextField *)textField
{
    _textField = textField;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        
        
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userWantsToEditCell)];
    [self addGestureRecognizer:recognizer];
}

- (void)userWantsToEditCell
{
    if([self.delegate userCanEditCell:self])
    {
        self.textField.enabled = YES;
        [self.textField becomeFirstResponder];
    }
}

//Handles resigning the first responder when a touch event happens in this cell or another cell.
- (void)touchesEnded: (NSSet *)touches withEvent: (UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    for (EditableCell *cell in [(UITableView *)self.superview visibleCells]) {
        [cell.textField resignFirstResponder];
    }
}



#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate editableCelldidBeginEditting:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(![textField.text length])return NO;
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate userDidChangeCellTitleToTitle:textField.text forCell:self];
    textField.enabled = NO;
    [self.delegate editableCelldidEndEditting:self];
}
@end
