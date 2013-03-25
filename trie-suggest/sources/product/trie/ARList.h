// BSD License. Author: jano@jano.com.es

#import "ARContainer.h"

/** 
 * Ordered collection where elements are inserted and removed anywhere. 
 * Implemented by ARArray.
 */
@protocol ARList <ARContainer>

#pragma mark - Create
-(id) initWithARList:(id<ARList>)list;
// -(id) initWithCapacity:(NSUInteger)capacity;
-(id) copy;

#pragma mark - Add
-(void) insertObject:(id)object atIndex:(NSUInteger)index;
-(void) insertObjectAtBeginning:(id)object;
-(void) insertObjectAtEnd:(id)object;
-(void) addObject:(id)anObject;

#pragma mark - Read
-(id) firstObject;
-(id) lastObject;
-(id) objectAtIndex:(NSUInteger)index;
-(id<ARList>) head: (NSUInteger)numberOfElements;
-(id<ARList>) tail: (NSUInteger)numberOfElements;

#pragma mark - Remove
-(void) removeAllObjects;
-(id) removeFirstObject;
-(id) removeLastObject;
-(id) removeObjectAtIndex:(NSUInteger)index;

#pragma mark - Update
-(void) setObject:(id)object atIndex:(NSUInteger)index;

#pragma mark - Iterate
-(void) until: (BOOL(^)(id object))block;
-(void) eachWithIndex: (void (^)(id object, int index))block;

@end