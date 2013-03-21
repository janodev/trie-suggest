
// BSD License. Author: jano@jano.com.es

#import "ARContainer.h"
#import "ARList.h"


/** Ordered collection where elements are inserted at the rear, and removed at the front. */
@protocol ARQueue <ARContainer,NSCoding,NSCopying>

-(id) initWithARList:(id<ARList>)list;
-(BOOL) isEqualToARQueue:(NSObject<ARQueue>*)stack;
-(id) copy;

-(id<ARList>) allObjects;

-  (id) dequeue;           // Removes and returns the item at the front.
-(void) enqueue:(id)item;  // Adds the given element to the rear of the queue.
-  (id) peek;              // Return the first element in the queue.

@end