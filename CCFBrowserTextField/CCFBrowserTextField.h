//
//  CCFBrowserTextField.h
//  CCFBrowserTextField
//
//  Created by Kyle Hankinson on 2019-01-18.
//  Copyright © 2019 Hankinsoft Development, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for CCFBrowserTextField.
FOUNDATION_EXPORT double CCFBrowserTextFieldVersionNumber;

//! Project version string for CCFBrowserTextField.
FOUNDATION_EXPORT const unsigned char CCFBrowserTextFieldVersionString[];

#import "CCFBrowserTextFieldButton.h"
#import "CCFBrowserTextFieldCell.h"

// In this header, you should import all the public headers of your framework using statements like #import <CCFBrowserTextField/PublicHeader.h>

@interface CCFBrowserTextField : NSTextField

/** Set the action block from the browser button
 
 If the class user wishes to receive mouse down events in the field's
 button, it should use this method to provide a block to be executed.
 
 @param aBlock the block to be executed with the field's button is
 tapped.
 */
- (void) setActionBlock: (CCFBrowserButtonBlock) aBlock;
- (void) setButtonImage: (NSImage*) image;

@property(nonatomic,assign) BOOL showClearButton;

@end

