//
//  KTStoredSet.h
//  KTComponents
//
//  Copyright (c) 2005-2006, Karelia Software. All rights reserved.
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

#import "KTStoredArray.h"

@interface KTStoredSet : KTStoredArray
{
    // a gloss on managing "items" in a KTStoredArray
}

+ (id)setInManagedObjectContext:(KTManagedObjectContext *)aContext entityName:(NSString *)anEntityName;
+ (id)setWithArray:(NSArray *)anArray inManagedObjectContext:(KTManagedObjectContext *)aContext entityName:(NSString *)anEntityName;
+ (id)setWithSet:(id)aSet inManagedObjectContext:(KTManagedObjectContext *)aContext entityName:(NSString *)anEntityName;

#pragma mark value accessors

/*! returns an NSMutableSet of the internal array contents */
- (NSMutableSet *)set;
- (void)setSet:(id)aSet;

#pragma mark NSSet primitives

- (unsigned)count;
- (id)member:(id)anObject;
- (NSEnumerator *)objectEnumerator;

#pragma mark NSSet-like methods

- (NSArray *)allObjects;
- (BOOL)containsObject:(id)anObject;

@end
