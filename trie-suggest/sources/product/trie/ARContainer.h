
// BSD License. Created by jano@jano.com.es

/** Container. */
@protocol ARContainer <NSObject, NSCopying, NSCoding, NSFastEnumeration>

/** Returns the number of elements. */
@property (nonatomic,assign,readonly) NSUInteger count;

/** Return true if the container is empty. */
-(BOOL) isEmpty;

/** Return a default instance. */
-(id) init;

@end

