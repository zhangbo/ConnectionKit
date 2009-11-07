//
//  SVInspectorWindowController.m
//  Sandvox
//
//  Created by Mike on 22/10/2009.
//  Copyright 2009 Karelia Software. All rights reserved.
//

#import "SVInspector.h"
#import "SVInspectorViewController.h"

#import "KSTabViewController.h"


@implementation SVInspector

+ (void)initialize
{
    [self exposeBinding:@"inspectedPagesController"];
}

@synthesize inspectedPagesController = _inspectedPagesController;
- (void)setInspectedPagesController:(NSObjectController *)controller
{
    [_pageInspector setValue:controller
                      forKey:@"inspectedObjectsController"];
}

- (void)setInspectedWindow:(NSWindow *)window
{
    if ([self inspectedWindow])
    {
        [self unbind:@"inspectedPagesController"];
    }
    
    [super setInspectedWindow:window];
    
    if (window)
    {
        [self bind:@"inspectedPagesController"
          toObject:window
       withKeyPath:@"windowController.siteOutlineViewController.pagesController"
           options:nil];
    }
}

- (NSArray *)defaultInspectorViewControllers;
{
    //  Document
    _documentInspector = [[SVInspectorViewController alloc] initWithNibName:@"DocumentInspector" bundle:nil];
    [_documentInspector setTitle:NSLocalizedString(@"Document", @"Document Inspector")];
    [_documentInspector setIcon:[NSImage imageNamed:@"emptyDoc"]];
    [_documentInspector bind:@"inspectedDocument"
                   toObject:self
                withKeyPath:@"inspectedWindow.windowController.document"
                    options:nil];
    [_documentInspector setInspectedObjectsController:[self inspectedPagesController]];
    
    
    // Page
    _pageInspector = [[SVInspectorViewController alloc] initWithNibName:@"PageInspector" bundle:nil];
    [_pageInspector setTitle:NSLocalizedString(@"Page", @"Page Inspector")];
    [_pageInspector setIcon:[NSImage imageNamed:@"toolbar_new_page"]];
    [_pageInspector bind:@"inspectedDocument"
               toObject:self
            withKeyPath:@"inspectedWindow.windowController.document"
                options:nil];
    [_pageInspector setInspectedObjectsController:[self inspectedPagesController]];
    
    
    // Wrap
    _wrapInspector = [[SVInspectorViewController alloc] initWithNibName:@"WrapInspector" bundle:nil];
    [_wrapInspector setTitle:NSLocalizedString(@"Wrap", @"Wrap Inspector")];
    [_wrapInspector setIcon:[NSImage imageNamed:@"unsorted"]];
    [_wrapInspector bind:@"inspectedDocument"
               toObject:self
            withKeyPath:@"inspectedWindow.windowController.document"
                options:nil];
    [_wrapInspector setInspectedObjectsController:[self inspectedPagesController]];
    
    
    //  Finish up
    NSArray *result = [NSArray arrayWithObjects:
                       _documentInspector,
                       _pageInspector,
                       _wrapInspector,
                       nil];
    
    return result;
}

@end
