/**
 @file CCFBrowserTextField.m
 @author Alan Duncan (www.cocoafactory.com)
 
 @date 2012-09-20 10:11:23
 @version 1.0
 
 Copyright (c) 2012 Cocoa Factory, LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "CCFBrowserTextField.h"
#import "CCFBrowserTextFieldCell.h"
#import "CCFBrowserTextFieldButton.h"
#import <objc/runtime.h>

@interface CCFBrowserTextField()<NSTextFieldDelegate>

@property(nonatomic,weak) id<NSTextFieldDelegate> actualDelegate;

@end

@implementation CCFBrowserTextField
{
    CCFBrowserTextFieldButton * _browserButton;
    CCFBrowserTextFieldButton * clearButton;
}

+ (Class)cellClass {
    return [CCFBrowserTextFieldCell class];
}

- (void) setDelegate: (id<NSTextFieldDelegate>) delegate
{
    super.delegate = self;

    if(self != delegate)
    {
        self.actualDelegate = delegate;
    }
} // End of setDelegate:

- (id) initWithFrame: (NSRect) frame
{
    self = [super initWithFrame:frame];
    
    return [self _initTextFieldCompletion];
}

- (id) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder:aDecoder];
    return [self _initTextFieldCompletion];
}

#pragma mark - Public API

- (void)setActionBlock:(CCFBrowserButtonBlock)aBlock {
    [_browserButton setActionHandler:aBlock];
}

#pragma mark - NSControl subclass methods

- (void)setEditable:(BOOL)flag {
    [super setEditable:flag];
    [_browserButton setEnabled:flag];
    [clearButton setHidden: !flag];
}

- (void) resetCursorRects
{
    NSRect beamRect = self.bounds;
    if(![_browserButton isHidden] )
    {
        beamRect.size.width -= _browserButton.bounds.size.width;
    }

    if( ![clearButton isHidden])
    {
        beamRect.size.width -= clearButton.bounds.size.width;
    }

    [self addCursorRect: beamRect
                 cursor: [NSCursor IBeamCursor]];

    CGFloat arrowWidth = self.bounds.size.width - beamRect.size.width;
    NSRect remainingRect = NSMakeRect(self.bounds.size.width - arrowWidth, beamRect.origin.y, arrowWidth, beamRect.size.height);
    [self addCursorRect: remainingRect
                 cursor: [NSCursor arrowCursor]];
}

- (void) didAddSubview: (NSView *)subview
{
    if( subview == _browserButton || subview == clearButton)
    {
        return;
    }

    [_browserButton removeFromSuperview];
    [self addSubview:_browserButton];
    
    [clearButton removeFromSuperview];
    [self addSubview: clearButton];
} // End of didAddSubview:

- (id) _initTextFieldCompletion
{
    // Need to watch ourself for text changed
    self.delegate = self;

    if ( !_browserButton )
    {
        NSSize browserImageSize = [CCFBrowserTextFieldButton browserImageSize];
        NSRect buttonFrame = NSMakeRect(0.0f, 0.0f, browserImageSize.width, browserImageSize.height);
        _browserButton = [[CCFBrowserTextFieldButton alloc] initWithFrame:buttonFrame];
        buttonFrame = [CCFBrowserTextFieldCell rectForBrowserFrame:self.bounds];
        
        [self _setCellClass];
        
        
        [self addSubview:_browserButton];
        [_browserButton setImage: [NSImage imageNamed: @"Dropdown"]];
        self.autoresizesSubviews = YES;

        [_browserButton setFrame: buttonFrame
                   actionHandler: ^{
            NSLog(@"pushed");
        }];
    }

    if ( !clearButton )
    {
        NSSize browserImageSize = [CCFBrowserTextFieldButton browserImageSize];
        NSRect buttonFrame = NSMakeRect(0.0f, 0.0f, browserImageSize.width, browserImageSize.height);
        clearButton = [[CCFBrowserTextFieldButton alloc] initWithFrame: buttonFrame];
        buttonFrame = [CCFBrowserTextFieldCell rectForBrowserFrame: self.bounds];
        buttonFrame.origin.x -= buttonFrame.size.width;

        [self _setCellClass];

        // Default clear button as hidden
        [clearButton setHidden: YES];
        [clearButton setImage: [NSImage imageNamed: @"ClearText"]];

        [self addSubview: clearButton];
        self.autoresizesSubviews = YES;

        [clearButton setFrame: buttonFrame
                   actionHandler: ^{
                       [self clearTextField];
                   }];
    }

    return self;
}

- (void) clearTextField
{
    [self setStringValue: @""];
    [clearButton setHidden: YES];
} // End of clearTextField

- (void)_setCellClass
{
    Class customClass = [CCFBrowserTextFieldCell class];
    
    //  since we are switching the isa pointer, we need to guarantee that the class layout in memory is the same
    NSAssert(class_getInstanceSize(customClass) == class_getInstanceSize(class_getSuperclass(customClass)), @"Incompatible class assignment");
    
    //  switch classes if we are not already switched
    NSCell *cell = [self cell];
    if( ![cell isKindOfClass:[CCFBrowserTextFieldCell class]] )
    {
        object_setClass(cell, customClass);
    }
}

#pragma mark - NSTextField delegate

- (void) controlTextDidChange: (NSNotification *) notification
{
    NSTextField *textField = [notification object];
    
    BOOL hidden = textField.stringValue.length > 0;
    if(!self.showClearButton)
    {
        hidden = true;
    }

    [clearButton setHidden: hidden];

    // Forward if needed
    if(nil != self.actualDelegate && [self.actualDelegate respondsToSelector: @selector(controlTextDidChange:)])
    {
        [self.actualDelegate controlTextDidChange: notification];
    }
}

#pragma mark - UIScrollViewDelegate forwarding

- (BOOL) respondsToSelector: (SEL) aSelector
{
    if ([self.actualDelegate respondsToSelector:aSelector])
    {
        return YES;
    }

    return [super respondsToSelector:aSelector];
}


- (id) forwardingTargetForSelector: (SEL) aSelector
{
    if ([self.actualDelegate respondsToSelector:aSelector])
    {
        return self.actualDelegate;
    }

    return [super forwardingTargetForSelector:aSelector];
}

@end
