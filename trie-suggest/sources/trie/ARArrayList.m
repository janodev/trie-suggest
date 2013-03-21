
#import "ARArrayList.h"


/* Default capacity for the array. */
const NSUInteger kArrayDefaultCapacity = 16;


@interface ARArrayList()

@property (nonatomic,assign,readwrite) NSUInteger count;

/* Insert object at the given index.
 *
 * Inserting in [self count] means adding a new object to the list.
 *
 * @param object The object.
 * @param index The index. Must be in range 0 to [self count].
 */
- (void)_insertObject:(id)object atIndex:(NSUInteger)index;

/* Return true if the array is full. That is, `[self count] == _capacity`. */
- (bool) isFull;

/* Assert that there is an array element at the given index. That is, `index < [self count]`.*/
- (void) assertExistingIndex:(NSUInteger)index;

/* Expand the array if it is full.
 *
 * If the array is not full, no changes are made.
 * If the array is full, capacity will be doubled
 * If the array is nil, new capacity will be 16.
 */
- (void) expandCapacity;

@end


@implementation ARArrayList {

    /* Number of elements */
    NSUInteger _count;

    /* Maximum number of elements. */
    NSUInteger _capacity;

    /* Objects. */
    id __strong *_objs;
}


#pragma mark - Subscripting

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectAtIndex:index];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index {
    return [self setObject:object atIndex:index];
}


#pragma mark - ARContainer

-(BOOL) isEmpty {
    return [self count]==0;
}

-(bool) isFull {
    return [self count] == _capacity;
}

-(BOOL) and: (BOOL(^)(id object))block {
	NSParameterAssert(block != nil);
    BOOL result = YES;
    for (id object in self) {
        if (!block(object)){
            result = NO;
            break;
        }
    }
    return result;
}

-(BOOL) or: (BOOL(^)(id object))block {
	NSParameterAssert(block != nil);
    BOOL result = NO;
    for (id object in self) {
        if (block(object)){
            result = YES;
            break;
        }
    }
    return result;
}

- (void) each: (void (^)(id object))block {
    NSParameterAssert(block != nil);
    for (id object in self) {
        block(object);
    }
}

-(id) find: (BOOL(^)(id object))block {
	NSParameterAssert(block != nil);
    id result;
    for (id object in self) {
        if (block(object)){
            result = object;
            break;
        }
    }
    return result;
}

- (id) reduce: (id(^)(id a, id b))block {
    NSParameterAssert(block != nil);
    id result;
    if ([self count]==0){
        result = block(nil,nil);
    } else if ([self count]==1){
        result = block([self objectAtIndex:0],nil);
    } else {
        result = block([self objectAtIndex:0],[self objectAtIndex:1]);
        for (NSUInteger index=2; index<_count; index++) {
            result = block(result,[self objectAtIndex:index]);
        }
    }
    return result;
}

-(instancetype) map: (id(^)(id object))block {
    NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (id object in self){
        [result addObject:block(object)];
    }
    return result;
}

- (instancetype) pluck: (NSString*)keyPath {
    NSParameterAssert(keyPath != nil);
    return [self map:^id(id object) {
        return [object valueForKeyPath:keyPath];
    }];
}

-(instancetype) split:(NSUInteger)numberOfPartitions
{
    id result = [NSMutableArray new];
    if (numberOfPartitions>0){
        NSUInteger i = 0;
        id subcollection = [[self class] emptyMutable];
        for (id object in self){
            [subcollection addObject:object];
            i++;
            if (i%numberOfPartitions==0) {
                [result addObject:subcollection];
                subcollection = [[self class] emptyMutable];
            } else if (i==[self count]){
                [result addObject:subcollection];
            }
        }
    }
	return [NSArray arrayWithArray:result];
}

- (instancetype) take: (NSUInteger)numberOfElements {
    id result = [[self class] emptyMutable];
    NSUInteger length = numberOfElements > [self count] ? numberOfElements : [self count];
    for (NSUInteger i = 0; i<length; i++) {
        [result addObject:[self objectAtIndex:i]];
    }
    return result;
}


- (instancetype) where: (BOOL(^)(id object))block {
	NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (id object in self){
        if (block(object)==YES){
            [result addObject:object];
        }
    }
	return result;
}


#pragma mark - NSArray specific


-(void) expandCapacity
{
    // start allocating with 16 elements, then double the capacity
    NSUInteger newCapacity = MAX(16, _capacity * 2);
    id __strong *newObjs = (id __strong *)calloc(newCapacity,sizeof(*newObjs));
    if (_objs!=nil){
        
        // copy old array to new array
        for (NSUInteger i = 0; i<_capacity; i++) {
            newObjs[i] = _objs[i];
            _objs[i] = nil;
        }
        [self freePointers:_objs size:_capacity];
    }
    // set the new data
    _objs = newObjs;
    _capacity = newCapacity;
}


-(ARArrayList*) inverseARArray {
    ARArrayList *array = [[ARArrayList alloc] initWithCapacity:[self count]];
    NSUInteger index=[self count];
    while (index>0){
        index--;
        [array insertObjectAtEnd:[self objectAtIndex:index]];
    }
    return array;
}


-(NSData*) bytes {
    size_t bytesToCopy = _capacity * sizeof(*_objs);
    NSData *data = [NSData dataWithBytes:_objs length:bytesToCopy];
    return data;
}


+(id<ARList>) emptyMutable {
    return [ARArrayList new];
}


- (void) eachWithIndex: (void (^)(id object, int index))block {
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj,idx);
    }];
}


- (id<ARList>) head: (NSUInteger)numberOfElements {
    if ([self count]<numberOfElements) numberOfElements = [self count];
    id<ARList> result = [[self class] emptyMutable];
    for (NSUInteger i=0; i<numberOfElements; i++) {
        [result addObject:self[i]];
    }
    return result;
}

- (id<ARList>) tail: (NSUInteger)numberOfElements {
    if ([self count]<numberOfElements) numberOfElements = [self count];
    id result = [[self class] emptyMutable];
    numberOfElements = [self count] - numberOfElements;
    while (numberOfElements!=[self count]){
        [result addObject:self[numberOfElements]];
        numberOfElements++;
    }
    return result;
}

-(void) until: (BOOL(^)(id object))block {
	NSParameterAssert(block != nil);
    for (id object in self) {
        if (block(object)){
            break;
        }
    }
}


#pragma mark - Other


-(void) freePointers:(__strong id*)pointers size:(NSUInteger)size {
    for (NSUInteger i=0; i<size; i++) {
        //pointers[i] = nil;
    }
    free(pointers);
}


- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    for (NSUInteger i=0; i<[self count]; i++) {
        BOOL stop = false;
        block([self objectAtIndex:i], i, &stop);
        if (stop) break;
    }
}


-(NSString*) componentsJoinedByString:(NSString*)string {
    if ([self count]==0){
        return @"";
    } else if ([self count]==1){
        return [[self objectAtIndex:0]description];
    } else {
        return [self reduce:^id(id a, id b) {
            return [NSString stringWithFormat:@"%@%@%@",a?a:@"",string,b?b:@""];
        }];
    }
}


-(void) assertExistingIndex:(NSUInteger)index {
    if (index >= [self count]){
        NSString *reason = [NSString stringWithFormat:@"Index out of range (%d) for an array with %d elements", index, [self count]];
        NSException* exception = [NSException exceptionWithName:NSRangeException reason:reason userInfo:nil];
        @throw exception;
    }
}


#pragma mark - Initialize

-(id)initWithData:(NSData*)data {
    self = [super init];
    if (self){
        _count = [data length] / sizeof(*_objs);
        _capacity = [self count];
        _objs = (id __strong *)calloc([self count], sizeof(*_objs));
        size_t bytesToCopy = [data length];
        const void *source = [data bytes];
        memcpy((void*)_objs, source, bytesToCopy); /* TODO: UNSAFE */
    }
    return self;
}

-(id) initWithARArray:(ARArrayList*)array {
    return [self initWithData:[array bytes]];
}

- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self){
        _objs = (id __strong *)calloc(capacity,sizeof(*_objs));
        _capacity = capacity;
    }
    return self;
}

+(ARArrayList*) createWithNSArray:(NSArray*)array {
    ARArrayList* __autoreleasing cArray = [[ARArrayList alloc] initWithCapacity:[array count]];
    for (id object in array) {
        [cArray insertObjectAtEnd:[object copy]];
    }
    //NSLog(@"%@",cArray);
    return cArray;
}


/**
 * Creates an array with the given amount of elements using the given block.
 * The generator block will be invoked 'elements' times, receiving the element
 * index as a parameter. 
 *
 * @param elements
 * @param generator
 * @return
 */
+(ARArrayList*) create:(NSUInteger)elements usingBlock:(generator_t)generator {
    ARArrayList* __autoreleasing cArray = [[ARArrayList alloc] initWithCapacity:elements];
    for (NSUInteger i=0; i<elements; i++) {
        [cArray addObject:generator(i)];
    }
    return cArray;
}


#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder*)encoder {
    size_t bytesToCopy = [self count] * sizeof(*_objs);
    NSData *data = [NSData dataWithBytes:_objs length:bytesToCopy];
    NSString *key = NSStringFromClass([self class]);
	[encoder encodeObject:data forKey:key];
}

- (id) initWithCoder:(NSCoder*)decoder {
    self = [super init];
	if (self) {
        NSString *key = NSStringFromClass([self class]);
        NSData *data = (NSData*)[decoder decodeObjectForKey:key];
        
        NSUInteger newCount = [data length] / sizeof(*_objs);
        NSUInteger newCapacity = [self count];
        id __strong *newObjs = (id __strong *)calloc(_count, sizeof(*_objs));
        size_t bytesToCopy = [data length];
        const void *source = [data bytes];
        memcpy((void*)newObjs, source, bytesToCopy); /* UNSAFE */
        
        NSUInteger oldCapacity = _capacity;
        
        id __strong *oldObjs = _objs;
        _objs = newObjs;
        _count = newCount;
        _capacity = newCapacity;
        
        [self freePointers:oldObjs size:oldCapacity];
    }
	return self;
}


#pragma mark - NSCopying

- (id) copyWithZone:(NSZone*)zone {
    ARArrayList *list = [[ARArrayList alloc] initWithCapacity:[self count]];
    for (id object in self) {
        [list insertObjectAtEnd:[object copy]];
    }
    return list;
}


#pragma mark - NSObject


- (void) dealloc {
    [self freePointers:_objs size:_capacity];
}


-(NSString*) description {
    return [self componentsJoinedByString:@","];
}


- (BOOL) isEqual:(id)array {
    BOOL isEqual = YES;
    if (self==array){
        isEqual = YES;
    } else if ([array isKindOfClass:[ARArrayList class]]){
        isEqual = [self isEqualToARArray:array];
    }
    return isEqual;
}


- (BOOL) isEqualToARArray:(ARArrayList*)array {
    BOOL isEqual = YES;
    if (self == array){
        isEqual = YES;
    } else if ([self count] != [array count]){
        isEqual = NO;
    } else {
        for (NSUInteger index=0; index<[self count]; index++) {
            id a = [array objectAtIndex:index];
            id b = [self objectAtIndex:index];
            if (![a isEqual:b]){
                isEqual = NO;
                break;
            }
        }
    }
    return isEqual;
}


- (NSUInteger)hash {
    return [[self bytes] hash];
}


#pragma mark - NSFastEnumeration

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (id __unsafe_unretained*)stackbuf
                                     count: (NSUInteger)len
{
    state->mutationsPtr = (unsigned long *) &_count;
    
    NSInteger count = MIN(len, [self count] - state->state);
    if (count > 0)
    {
        IMP	imp = [self methodForSelector: @selector(objectAtIndex:)];
        int	p = state->state;
        int	i;
        for (i = 0; i < count; i++, p++) {
            id obj = (*imp)(self, @selector(objectAtIndex:), p);
            stackbuf[i] = obj;
        }
        state->state += count;
    }
    else
    {
        count = 0;
    }
    state->itemsPtr = stackbuf;
    return count;
}


#pragma mark - List

- (id)init {
    self = [super init];
    if (self){
        _objs = (id __strong *)calloc(kArrayDefaultCapacity,sizeof(*_objs));
        _capacity = kArrayDefaultCapacity;
    }
    return self;
}

-(id) initWithARList:(id<ARList>)list {
    self = [self initWithCapacity:[list count]];
    if (self){
        for (id object in list) {
            [self insertObjectAtEnd:object];
        }
    }
    return self;
}


#pragma mark Insert
/** @name Insert */

-(void) insertObjectAtBeginning:(id)object {
    [self _insertObject:object atIndex:0];
}

- (void) insertObjectAtEnd:(id)object {
    [self _insertObject:object atIndex:[self count]];
}

- (void) addObject:(id)object {
    [self _insertObject:object atIndex:[self count]];
}

- (void) insertObject:(id)object atIndex:(NSUInteger)index {
    [self assertExistingIndex:index];
    [self _insertObject:object atIndex:index];
}

- (void) _insertObject:(id)object atIndex:(NSUInteger)index
{
    NSParameterAssert(object!=nil);
    if ([self isFull]){
        [self expandCapacity];
    }
    if (index!=[self count]){

        for (NSInteger i = [self count]; i!=index; i--) {
            _objs[i]=_objs[i-1];
        }
        /*
        // make space at the index position
        size_t objectSize = sizeof(*_objs);
        size_t bytesToCopy = ([self count] - index) * objectSize;
        void *source = (void*)_objs + index * objectSize;
        void *target = (void*)_objs + (index+1) * objectSize;
        memmove(target, source, bytesToCopy);
        */
    }
    // insert
    _objs[index] = object;
    _count++;
}


#pragma mark Replace
/** @name Replace */

- (void) setObject:(id)object atIndex:(NSUInteger)index
{
    NSParameterAssert(object!=nil);
    [self assertExistingIndex:index];
    
    _objs[index] = nil;
    _objs[index] = object;
}


#pragma mark Retrieve
/** @name Retrieve */

-(id) firstObject {
    id object;
    if ([self isEmpty]){
        object = nil;
    } else {
        NSUInteger firstIndex = 0;
        object = [self objectAtIndex:firstIndex];
    }
    return object;
}

-(id) lastObject {
    id object;
    if ([self isEmpty]){
        object = nil;
    } else {
        NSUInteger lastIndex = [self count]-1;
        object = [self objectAtIndex:lastIndex];
    }
    return object;
}

- (id)objectAtIndex:(NSUInteger)index {
    // throws exception when the index is out of range
    [self assertExistingIndex:index];
    return _objs[index];
    // not throwing version
    // return index >= [self count] ? nil : _objs[index];
}

#pragma mark Remove
/** @name Remove */

-(id) removeFirstObject
{
    id object;
    if ([self count]==0){
        object = nil;
    } else {
        NSUInteger firstIndex = 0;
        object = [self removeObjectAtIndex:firstIndex];
    }
    return object;
}

-(id)removeLastObject {
    id object;
    if ([self count]==0){
        object = nil;
    } else {
        NSUInteger lastIndex = [self count]-1;
        object = [self removeObjectAtIndex:lastIndex];
    }
    return object;
}


-(id)removeObjectAtIndex:(NSUInteger)index
{
    [self assertExistingIndex:index];
    id object = _objs[index];

    _objs[index] = nil;
    
    // move half the array on top of the empty position
    for (NSUInteger i = index; i<[self count]-1; i++) {
        _objs[i]=_objs[i+1];
    }
    _objs[[self count]-1] = nil;
    
    // commented because ARC loses its shit with memXXX operations
    /*
    // move half the array on top of the empty position
    size_t objectSize = sizeof(*_objs);
    size_t bytesToCopy = ([self count] - index - 1) * objectSize;
    void *source = (void*)_objs + (index + 1)*objectSize;
    void *target = (void*)_objs + index*objectSize;
    memmove(target, source, bytesToCopy);
    */
    
    _count--;
    
    return object;
}


-(void) removeAllObjects
{
    // nil all objects and let ARC free the space
    while ([self count]>0){
        _count--;
        _objs[[self count]] = nil;
    }
    
    // shrink the array to kDefaultCapacity if bigger than that
    if (_capacity>kArrayDefaultCapacity){
        [self freePointers:_objs size:_capacity];
        _objs = (id __strong *)calloc(kArrayDefaultCapacity,sizeof(*_objs));
        _capacity = kArrayDefaultCapacity;
    }
}


@end

