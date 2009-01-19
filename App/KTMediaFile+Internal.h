//
//  KTMediaFile+MediaManagerPrivate.h
//  Marvel
//
//  Created by Mike on 07/11/2007.
//  Copyright 2007-2009 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "KTMediaFile.h"
#import "KTExternalMediaFile.h"
#import "KTInDocumentMediaFile.h"

#import "KTPasteboardArchiving.h"


@class KTImageScalingSettings;


@interface KTMediaFile (Internal) <KTPasteboardArchiving>

+ (id)insertNewMediaFileWithPath:(NSString *)path inManagedObjectContext:(NSManagedObjectContext *)moc;

- (NSString *)preferredFileName;

@end


@interface KTExternalMediaFile (Internal) <KTPasteboardArchiving>
+ (id)insertNewMediaFileWithAlias:(BDAlias *)alias inManagedObjectContext:(NSManagedObjectContext *)moc;
@end