
// BSD License. Author: jano@jano.com.es

#import "ARQueueList.h"

@implementation ARQueueList

-(void) enqueue:(id)item {
    [self insertObjectAtBeginning:item];
}

-(id) dequeue {
    return [self removeLastObject];
}

-(id) peek {
    return [self lastObject];
}

-(id<ARList>) allObjects {
    return [self copy];
}

-(id) initWithARList:(id<ARList>)list {
    self = [self initWithCapacity:[list count]];
    if (self){
        for (id object in list) {
            [self insertObjectAtBeginning:object];
        }
    }
    return self;
}

- (BOOL) isEqual:(id)object
{
    BOOL isEqual = NO;
    if (self==object){
        isEqual = YES;
    } else if ([object conformsToProtocol:@protocol(ARQueue)]){
        isEqual = [self isEqualToARQueue:object];
    }
    return isEqual;
}

-(BOOL) isEqualToARQueue:(NSObject<ARQueue>*)queue {
    BOOL isEqual = NO;
    if ([queue isKindOfClass:[ARQueueList class]]){
        ARQueueList *queueList = (ARQueueList*)queue;
        isEqual = [queueList isEqualToARArray:self];
    } else {
        [self isEqual:[queue allObjects]];
    }
    return isEqual;
}

- (id) copyWithZone:(NSZone*)zone {
    ARQueueList *list = [[ARQueueList alloc] initWithCapacity:[self count]];
    for (id object in self) {
        [list insertObjectAtEnd:[object copy]];
    }
    return list;
}

-(NSString*) description {
    NSMutableString *string = [NSMutableString string];
    for (NSInteger i=[self count]-1; i>-1; i--) {
        [string appendFormat:@"%@%@",[self objectAtIndex:i], i>0?@",":@""];
    }
    return string;
}

@end
