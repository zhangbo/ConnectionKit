//
//  KTDocument.h
//  Sandvox
//
//  Copyright (c) 2004-2006, Karelia Software. All rights reserved.
//
//  THIS SOFTWARE IS PROVIDED BY KARELIA SOFTWARE AND ITS CONTRIBUTORS "AS-IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUR OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


// publishing mode
typedef enum {
	kGeneratingPreview = 0,
	kGeneratingLocal,
	kGeneratingRemote,
	kGeneratingRemoteExport,
	kGeneratingQuickLookPreview = 10,
} KTHTMLGenerationPurpose;


extern NSString *KTDocumentWillSaveNotification;


@class KTDocumentInfo, KTMediaManager, KTManagedObjectContext, KTTransferController, KTStalenessManager;
@class KTDocWindowController, KTHTMLInspectorController;
@class KTAbstractElement, KTPage, KTElementPlugin;


@interface KTDocument : NSPersistentDocument
{
	// New docs
	IBOutlet NSView			*oNewDocAccessoryView;
	IBOutlet NSPopUpButton	*oNewDocHomePageTypePopup;
	
	@private
	
	KTManagedObjectContext		*myManagedObjectContext;
	KTDocumentInfo				*myDocumentInfo;
	
	KTDocWindowController		*myDocWindowController;
	
	KTHTMLInspectorController	*myHTMLInspectorController;
	
	KTMediaManager				*myMediaManager;
	
	KTStalenessManager			*myStalenessManager;
	
	KTTransferController		*myLocalTransferController;
	KTTransferController		*myRemoteTransferController;
	KTTransferController		*myExportTransferController;
	
	NSTimer						*myAutosaveTimer;
	NSDate						*myLastSavedTime;	
		
	BOOL myIsSuspendingAutosave;
	BOOL myIsClosing;
    unsigned mySaveOperationCount;
	
    NSString    *mySiteCachePath;
	NSURL       *mySnapshotURL;
		
	
	// UI
	BOOL	myShowDesigns;				// is designs panel showing?
	BOOL	myDisplaySiteOutline;
	BOOL	myDisplaySmallPageIcons;
	BOOL	myDisplayStatusBar;
	BOOL	myDisplayEditingControls;
	short	mySiteOutlineSize;
	float	myTextSizeMultiplier;
	BOOL	myDisplayCodeInjectionWarnings;
}

+ (NSString *)defaultStoreType;
+ (NSString *)defaultMediaStoreType;

+ (NSURL *)datastoreURLForDocumentURL:(NSURL *)inURL UTI:(NSString *)documentUTI;
+ (NSURL *)siteURLForDocumentURL:(NSURL *)inURL;
+ (NSURL *)quickLookURLForDocumentURL:(NSURL *)inURL;
+ (NSURL *)mediaURLForDocumentURL:(NSURL *)inURL;
+ (NSURL *)mediaStoreURLForDocumentURL:(NSURL *)inURL;
- (NSString *)mediaPath;
- (NSString *)temporaryMediaPath;
- (NSString *)siteDirectoryPath;


- (id)initWithType:(NSString *)typeName error:(NSError **)outError;
- (id)initWithURL:(NSURL *)saveURL ofType:(NSString *)type homePagePlugIn:(KTElementPlugin *)plugin error:(NSError **)outError;


- (IBAction)setupHost:(id)sender;

- (KTDocWindowController *)windowController;

// cache support
- (BOOL)createImagesCacheIfNecessary;
- (NSString *)imagesCachePath;
- (BOOL)createUploadCacheIfNecessary;
- (BOOL)clearUploadCache;
- (NSString *)uploadCachePath;
- (NSString *)siteCachePath;

// snapshot support
- (IBAction)saveDocumentSnapshot:(id)sender;
- (IBAction)revertDocumentToSnapshot:(id)sender;

- (BOOL)createSnapshotDirectoryIfNecessary;
- (NSString *)snapshotName;
- (NSURL *)snapshotDirectoryURL;
- (NSURL *)snapshotURL;
- (BOOL)hasValidSnapshot;

// cover for KTDocWindowController method
- (BOOL)isClosing;
- (void)setClosing:(BOOL)aFlag;

- (IBAction)clearStaleness:(id)sender;
- (IBAction)markAllStale:(id)sender;

- (IBAction)editRawHTMLInSelectedBlock:(id)sender;
- (IBAction)viewPublishedSite:(id)sender;

// Editing

- (void)editDOMHTMLElement:(DOMHTMLElement *)anElement withTitle:(NSString *)aTitle;
- (void)editKTHTMLElement:(KTAbstractElement *)anElement;

- (void)addScreenshotsToAttachments:(NSMutableArray *)attachments attachmentOwner:(NSString *)attachmentOwner;
- (BOOL)mayAddScreenshotsToAttachments;

@end


@interface KTDocument ( Alert )
- (void)delayedAlertSheetWithInfo:(NSDictionary *)anInfoDictionary;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(id)contextInfo;
@end


@interface KTDocument ( CoreData )

//- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url 
//										   ofType:(NSString *)fileType 
//							   modelConfiguration:(NSString *)configuration 
//									 storeOptions:(NSDictionary *)storeOptions 
//											error:(NSError **)error

// this method is deprecated in Leopard, but we must continue to use its signature for Tiger
- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url 
										   ofType:(NSString *)fileType 
											error:(NSError **)error;

// backup
- (BOOL)createBackup;
- (BOOL)backupToURL:(NSURL *)anotherPath;

// snapshots
- (void)snapshotPersistentStore;
- (void)revertPersistentStoreToSnapshot;

// spotlight
- (BOOL)setMetadataForStoreAtURL:(NSURL *)aStoreURL error:(NSError **)outError;

// support
- (void)processPendingChangesAndClearChangeCount;

// notifications
/// these are now just used for debugging purposes
- (void)observeNotificationsForContext:(KTManagedObjectContext *)aManagedObjectContext;
- (void)removeObserversForContext:(KTManagedObjectContext *)aManagedObjectContext;

// exception handling
- (void)resetUndoManager;

@end


@interface KTDocument ( Lookup )

// derived properties
- (BOOL)hasRSSFeeds;	// determine if we need to show export panel

- (NSString *)titleHTML;
- (NSString *)siteSubtitleHTML;
- (NSString *)defaultRootPageTitleText;

- (NSString *)language;
- (NSString *)charset;

- (KTPage *)pageForURLPath:(NSString *)path;
@end


@interface KTDocument (Properties)

- (KTStalenessManager *)stalenessManager;

- (BOOL)isReadOnly;

- (NSIndexSet *)lastSelectedRows;
- (void)setLastSelectedRows:(NSIndexSet *)value;

- (NSSet *)requiredBundlesIdentifiers;
- (void)setRequiredBundlesIdentifiers:(NSSet *)identifiers;

//- (KTPage *)root;
//- (void)setRoot:(KTPage *)value;

- (float)textSizeMultiplier;
- (void)setTextSizeMultiplier:(float)value;

- (NSDate *)lastSavedTime;
- (void)setLastSavedTime:(NSDate *)aLastSavedTime;

// export/upload

- (KTTransferController *)exportTransferController;
- (void)setExportTransferController:(KTTransferController *)anExportTransferController;

- (KTTransferController *)localTransferController;
- (KTTransferController *)remoteTransferController;

- (BOOL)connectionsAreConnected;
- (void)terminateConnections;

// support

- (id)wrappedValueForKey:(NSString *)aKey;
- (void)setWrappedValue:(id)aValue forKey:(NSString *)aKey;

// these are really for properties stored in defaults
- (id)wrappedInheritedValueForKey:(NSString *)aKey;
- (void)setWrappedInheritedValue:(id)aValue forKey:(NSString *)aKey;
- (void)setPrimitiveInheritedValue:(id)aValue forKey:(NSString *)aKey;

- (KTDocumentInfo *)documentInfo;
- (void)setDocumentInfo:(KTDocumentInfo *)anObject;

- (NSTimer *)autosaveTimer;
- (void)setAutosaveTimer:(NSTimer *)aTimer;

- (KTHTMLInspectorController *)HTMLInspectorController;
- (void)setHTMLInspectorController:(KTHTMLInspectorController *)aController;

- (BOOL)showDesigns;
- (void)setShowDesigns:(BOOL)value;

// Display properties
- (BOOL)displayEditingControls;
- (void)setDisplayEditingControls:(BOOL)value;

- (BOOL)displaySiteOutline;
- (void)setDisplaySiteOutline:(BOOL)value;

- (BOOL)displayStatusBar;
- (void)setDisplayStatusBar:(BOOL)value;

- (BOOL)displaySmallPageIcons;
- (void)setDisplaySmallPageIcons:(BOOL)value;

- (NSRect)documentWindowContentRect;

@end


@interface KTDocument (Media)
- (KTMediaManager *)mediaManager;

@end


@interface KTDocument (Saving)

- (BOOL)isSaving;

// save/autosave
- (IBAction)autosaveDocument:(id)sender;
- (void)cancelAndInvalidateAutosaveTimers;
- (void)fireAutosave:(id)notUsedButRequiredParameter;
- (void)restartAutosaveTimersIfNecessary;
- (void)resumeAutosave;
- (void)suspendAutosave;

// Low-level
- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL includeMetadata:(BOOL)includeMetadata error:(NSError **)error;

@end

