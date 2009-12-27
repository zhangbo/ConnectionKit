// 
//  SVPagelet.m
//  Sandvox
//
//  Created by Mike on 11/10/2009.
//  Copyright 2009 Karelia Software. All rights reserved.
//

#import "SVPagelet.h"

#import "KTPage.h"
#import "SVBody.h"
#import "SVHTMLTemplateParser.h"
#import "SVSidebar.h"
#import "SVTemplate.h"
#import "SVTextField.h"

#import "NSSortDescriptor+Karelia.h"
#import "NSString+Karelia.h"


@interface SVPagelet ()
@property(nonatomic, retain, readwrite) SVBody *body;
@end


#pragma mark -


@implementation SVPagelet 

#pragma mark Initialization

+ (SVPagelet *)insertNewPageletIntoManagedObjectContext:(NSManagedObjectContext *)moc;
{
	OBPRECONDITION(moc);
	
	
    // Create the pagelet
	SVPagelet *result = [NSEntityDescription insertNewObjectForEntityForName:@"Pagelet"
													  inManagedObjectContext:moc];
	OBASSERT(result);
	
    
	return result;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    
    // UID
    [self setPrimitiveValue:[NSString shortUUIDString] forKey:@"elementID"];
    
    
    // Title
    [self setTitleWithString:[[self class] placeholderTitleText]];
    
    
    // Create corresponding body text
    [self setBody:[SVBody insertPageletBodyIntoManagedObjectContext:[self managedObjectContext]]];
}

#pragma mark Title

@dynamic title;

- (void)setTitleWithString:(NSString *)title;
{
    SVTextField *text = [self title];
    if (!text)
    {
        text = [NSEntityDescription insertNewObjectForEntityForName:@"PageletTitle" inManagedObjectContext:[self managedObjectContext]];
        [self setTitle:text];
    }
    [text setText:title];
}

+ (NSString *)placeholderTitleText;
{
    return NSLocalizedString(@"Pagelet", "pagelet title placeholder");
}

#pragma mark Body Text

@dynamic body;

#pragma mark Layout/Styling

@dynamic showBorder;

- (BOOL)isCallout;
{
    BOOL result = ([self enclosingBody] != nil);
    return result;
}

#pragma mark Sidebar

@dynamic sidebars;

- (void)moveBeforePagelet:(SVPagelet *)pagelet
{
    OBPRECONDITION(pagelet);
    
    NSArray *pagelets = [[self class] sortedPageletsInManagedObjectContext:[self managedObjectContext]];
    
    // Locate after pagelet
    NSUInteger index = [pagelets indexOfObject:pagelet];
    OBASSERT(index != NSNotFound);
    
    // Set our sort key to match
    NSNumber *pageletSortKey = [pagelet sortKey];
    OBASSERT(pageletSortKey);
    NSInteger previousSortKey = [pageletSortKey integerValue] - 1;
    [self setSortKey:[NSNumber numberWithInteger:previousSortKey]];
    
    // Bump previous pagelets along as needed
    for (NSUInteger i = index; i > 0; i--)  // odd handling of index so we can use an *unsigned* integer
    {
        SVPagelet *previousPagelet = [pagelets objectAtIndex:(i - 1)];
        if (previousPagelet != self)    // don't want to accidentally process self twice
        {
            previousSortKey--;
            
            if ([[previousPagelet sortKey] integerValue] > previousSortKey)
            {
                [previousPagelet setSortKey:[NSNumber numberWithInteger:previousSortKey]];
            }
            else
            {
                break;
            }
        }
    }
}

- (void)moveAfterPagelet:(SVPagelet *)pagelet;
{
    OBPRECONDITION(pagelet);
    
    NSArray *pagelets = [[self class] sortedPageletsInManagedObjectContext:[self managedObjectContext]];
    
    // Locate after pagelet
    NSUInteger index = [pagelets indexOfObject:pagelet];
    OBASSERT(index != NSNotFound);
    
    // Set our sort key to match
    NSNumber *pageletSortKey = [pagelet sortKey];
    OBASSERT(pageletSortKey);
    NSInteger nextSortKey = [pageletSortKey integerValue] + 1;
    [self setSortKey:[NSNumber numberWithInteger:nextSortKey]];
    
    // Bump following pagelets along as needed
    for (NSUInteger i = index+1; i < [pagelets count]; i++)
    {
        SVPagelet *nextPagelet = [pagelets objectAtIndex:i];
        if (nextPagelet != self)    // don't want to accidentally process self twice
        {
            nextSortKey++;
            
            if ([[nextPagelet sortKey] integerValue] < nextSortKey)
            {
                [nextPagelet setSortKey:[NSNumber numberWithInteger:nextSortKey]];
            }
            else
            {
                break;
            }
        }
    }
}

#pragma mark Sorting

+ (NSArray *)pageletSortDescriptors
{
    static NSArray *result;
    if (!result)
    {
        result = [NSSortDescriptor sortDescriptorArrayWithKey:@"sortKey"
                                                             ascending:YES];
        [result retain];
        OBASSERT(result);
    }
    
    return result;
}

+ (NSArray *)sortedPageletsInManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Pagelet"
                                   inManagedObjectContext:context]];
    [request setSortDescriptors:[self pageletSortDescriptors]];
    
    NSArray *result = [context executeFetchRequest:request error:NULL];
    
    // Tidy up
    [request release];
    return result;
}

+ (NSArray *)arrayBySortingPagelets:(NSSet *)pagelets;
{
    NSArray *sortDescriptors = [self pageletSortDescriptors];
    NSArray *result = [[pagelets allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    return result;
}

+ (BOOL)validatePagelets:(NSSet **)pagelets error:(NSError **)error;
{
    BOOL result = YES;
    
    // All our pagelets should have unique sort keys
    NSSet *sortKeys = [*pagelets valueForKey:@"sortKey"];
    if ([sortKeys count] != [*pagelets count])
    {
        result = NO;
        if (error)
        {
            NSDictionary *info = [NSDictionary dictionaryWithObject:@"Pagelet sort keys are not unique" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSManagedObjectValidationError userInfo:info];
        }
    }
    
    return result;
}

#pragma mark HTML

- (NSString *)HTMLString
{
    //  All SVContentObject subclasses must implement this to suit themselves
    
    SVTemplate *template = ([self isCallout] ?
                            [[self class] calloutHTMLTemplate] :  // will call pagelet template internally
                            [[self class] pageletHTMLTemplate]);
    
    SVHTMLTemplateParser *parser = [[SVHTMLTemplateParser alloc] initWithTemplate:[template templateString]
                                         component:self];
    
    NSString *result = [parser parseTemplate];
    [parser release];
    
    return result;
}

+ (SVTemplate *)pageletHTMLTemplate;
{
    static SVTemplate *result;
    if (!result)
    {
        result = [[SVTemplate templateNamed:@"PageletTemplate.html"] retain];
    }
    
    return result;
}

+ (SVTemplate *)calloutHTMLTemplate;
{
    static SVTemplate *result;
    if (!result)
    {
        result = [[SVTemplate templateNamed:@"CalloutTemplate.html"] retain];
    }
    
    return result;
}

- (NSString *)editingElementID
{
    // Sidebar pagelets can use default, callouts need to generate their own. #59325
    if ([self isCallout])
    {
        return [NSString stringWithFormat:@"%p", self];
    }
    else
    {
        return [super editingElementID];
    }
}

- (BOOL)shouldPublishEditingElementID
{
    return (![self isCallout]);
}

@end


#pragma mark -


@implementation SVPagelet (Deprecated)

#pragma mark Title

- (NSString *)titleHTMLString
{
    return [[self title] textHTMLString];
}

+ (NSSet *)keyPathsForValuesAffectingTitleHTMLString
{
    return [NSSet setWithObject:@"title.textHTMLString"];
}

- (NSString *)titleText	// get title, but without attributes
{
	return [[self title] text];
}

- (void)setTitleText:(NSString *)value
{
	[self setTitleWithString:value];
}

+ (NSSet *)keyPathsForValuesAffectingTitleText
{
    return [NSSet setWithObject:@"title.textHTMLString"];
}

@end
