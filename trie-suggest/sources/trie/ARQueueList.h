
// BSD License. Author: jano@jano.com.es

#import "ARQueue.h"
#import "ARArrayList.h"

/**
 * A queue backed by a list.
 *
 * Array based implementation where the beginning of the queue is the beginning of the array.
 * That is, elements ar added at the beginning and removed at the end.
 * Performance is Θ(1) for add/read, and Θ(n) for removal. Expanding the array is Θ(n).
 */
@interface ARQueueList : ARArrayList <ARQueue>
@end
