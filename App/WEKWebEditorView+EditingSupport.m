//
//  WEKWebEditorView+EditingSupport.m
//  Sandvox
//
//  Created by Mike on 15/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//


#import "WEKWebEditorView.h"
#import "WEKWebEditorItem.h"

#import "SVLinkManager.h"

#import "NSResponder+Karelia.h"
#import "DOMNode+Karelia.h"


@interface SVValidatedUserInterfaceItem : NSObject <NSValidatedUserInterfaceItem>
{
  @private
    SEL         _action;
    NSInteger   _tag;
}

@property(nonatomic) SEL action;
@property(nonatomic) NSInteger tag;

@end


#pragma mark -


@implementation WEKWebEditorView (EditingSupport)

#pragma mark Cut, Copy & Paste

- (void)cut:(id)sender
{
    // Let the WebView handle it unless there is no text selection
    if ([self selectedDOMRange])
    {
        [self forceWebViewToPerform:_cmd withObject:sender];
    }
    else
    {
        if ([self copySelectedItemsToGeneralPasteboard])
        {
            [self delete:sender];
        }
    }
}

- (void)copy:(id)sender
{
    // Let the WebView handle it unless there is no text selection
    if ([self selectedDOMRange])
    {
        [self forceWebViewToPerform:_cmd withObject:sender];
    }
    else
    {
        [self copySelectedItemsToGeneralPasteboard];
    }
}

- (BOOL)copySelectedItemsToGeneralPasteboard;
{
    BOOL result = YES;
    
    // Rely on the datasource to serialize items to the pasteboard
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:nil owner:nil];
    
    if ([self selectedDOMRange])
    {
        [[self focusedText] webEditorTextDidSetSelectionTypesForPasteboard:pasteboard];
    }
    else
    {
        result = [[self dataSource] webEditor:self writeItems:[self selectedItems] toPasteboard:pasteboard];
    }
    
    if (!result) NSBeep();
    return result;
}

// Presently, WEKWebEditorView doesn't implement paste directly itself, so we can jump in here
- (IBAction)paste:(id)sender;
{
    if (![[self delegate] webEditor:self doCommandBySelector:_cmd])
    {
        // Does the text view want to take command?
        if (![_focusedText webEditorTextDoCommandBySelector:_cmd])
        {
            [self forceWebViewToPerform:_cmd withObject:sender];
        }
    }
}

- (void)delete:(id)sender forwardingSelector:(SEL)action;
{
    DOMRange *selection = [self selectedDOMRange];
    if (selection)// && ![selection collapsed])
    {
        [self forceWebViewToPerform:action withObject:sender];
    }
    else
    {
        if (![[self dataSource] webEditor:self deleteItems:[self selectedItems]]) NSBeep();
    }
}

- (void)delete:(id)sender;
{
    [self delete:sender forwardingSelector:_cmd];
}

- (void)deleteForward:(id)sender;
{
    [self delete:sender forwardingSelector:_cmd];
}

- (void)deleteBackward:(id)sender;
{
    [self delete:sender forwardingSelector:_cmd];
}

#pragma mark Links

- (void)createLink:(SVLinkManager *)sender;
{
    //  Pass on to focused text
    if (![[self dataSource] webEditor:self createLink:sender])
    {
        if ([[self focusedText] respondsToSelector:_cmd])
        {
            [[self focusedText] performSelector:_cmd withObject:sender];
        }
    }
}

#pragma mark Undo

/*  Covers for private WebKit methods
 */

- (BOOL)allowsUndo { return [(NSTextView *)[self webView] allowsUndo]; }
- (void)setAllowsUndo:(BOOL)undo { [(NSTextView *)[self webView] setAllowsUndo:undo]; }

- (void)removeAllUndoActions
{
    [[self webView] performSelector:@selector(_clearUndoRedoOperations)];
}

#pragma mark Key presses

/*  In practice this seems to a bad idea. I wanted -moveUp: and -moveDown: actions, but it interprets everything else too!
- (void)keyDown:(NSEvent *)theEvent;
{
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}*/

- (void)moveUp:(id)sender;
{
    if (![[self delegate] webEditor:self doCommandBySelector:_cmd])
    {
        [self makeNextResponderDoCommandBySelector:_cmd];
    }
}

- (void)moveDown:(id)sender;
{
    if (![[self delegate] webEditor:self doCommandBySelector:_cmd])
    {
        [self makeNextResponderDoCommandBySelector:_cmd];
    }
}

#pragma mark Validation

- (BOOL)validateAction:(SEL)action;
{
    BOOL result = NO;
    
    NSView *view = [[[[self webView] selectedFrame] frameView] documentView];
    if ([view respondsToSelector:action])
    {
        result = YES;
        if ([view conformsToProtocol:@protocol(NSUserInterfaceValidations)] ||
            [view respondsToSelector:@selector(validateUserInterfaceItem:)])
        {
            SVValidatedUserInterfaceItem *item = [[SVValidatedUserInterfaceItem alloc] init];
            [item setAction:action];
            
            _isForwardingCommandToWebView = YES;
            result = [(id)view validateUserInterfaceItem:item];
            _isForwardingCommandToWebView = NO;
            
            [item release];
        }
    }
    
    
    return result;
}

#pragma mark Querying

- (WEKWebEditorItem <SVWebEditorText> *)textItemForDOMRange:(DOMRange *)range;
{
    return [[self dataSource] webEditor:self textBlockForDOMRange:range];
}

#pragma mark Scrolling

- (void)scrollItemToVisible:(WEKWebEditorItem *)item;
{
    OBPRECONDITION(item);
    
    DOMHTMLElement *selectedElement = [item HTMLElement];
    NSRect selectionRect = [selectedElement boundingBox];
    [[selectedElement documentView] scrollRectToVisible:selectionRect];
}

- (void)centerSelectionInVisibleArea:(id)sender;
{
    if ([self selectedDOMRange])
    {
        [[self webView] centerSelectionInVisibleArea:sender];
    }
    else
    {
        // Strictly speaking this only brings the selection into view; it doesn't center it. But this is a damn good first pass!
        WEKWebEditorItem *item = [self selectedItem];
        if (item) [self scrollItemToVisible:item];
    }
}

@end


#pragma mark -


@implementation SVValidatedUserInterfaceItem

@synthesize action = _action;
@synthesize tag = _tag;

@end

