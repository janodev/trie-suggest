
// BSD License. Author: jano@jano.com.es

#import "ARList.h"

typedef id (^generator_t) (NSUInteger index);

/**
 * Mutable array list backed by a C array of objects.
 *
 * This would be faster caching IMPs and other trickery, 
 * but Apple's implementation would still be faster.
 * See http://ridiculousfish.com/blog/posts/array.html
 *
 * TODO: add mutations field (currently using _count)
 */
@interface ARArrayList : NSObject <ARList>

#pragma mark - Create
-(id) initWithCapacity:(NSUInteger)capacity;
+(ARArrayList*) createWithNSArray:(NSArray*)array;
+(ARArrayList*) create:(NSUInteger)elements usingBlock:(generator_t)generator;

#pragma mark - Other

-(NSData*) bytes;
-(ARArrayList*) inverseARArray;
-(NSString*) componentsJoinedByString:(NSString*)string;
-(BOOL) isEqualToARArray:(ARArrayList*)array;


#pragma mark - Iterators

+(id) emptyMutable;

-        (BOOL)           and: (BOOL (^) (id object)) block;
-        (void)          each: (void (^) (id object)) block;
-        (void) eachWithIndex: (void (^) (id object, int index))block;
-          (id)          find: (BOOL (^) (id object)) block;
-(instancetype)           map: (id   (^) (id object)) block;
-        (BOOL)            or: (BOOL (^) (id object)) block;
-(instancetype)         pluck: (NSString*) keyPath;
-(instancetype)         split: (NSUInteger) numberOfPartitions;
-(instancetype)          take: (NSUInteger) numberOfElements;
-       (void)          until: (BOOL (^) (id object)) block;
-(instancetype)         where: (BOOL (^) (id object)) block;

/**
 * Reduces the collection to one value by running `result=block(first,second)`,
 * then `result=block(result,next)` until the end of the list.
 *   - If collection is empty, block(nil,nil) is returned.
 *   - If collection has one element, block(element,nil) is returned.
 */
-(id) reduce: (id(^)(id a, id b))block;

-(void) enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

@end
