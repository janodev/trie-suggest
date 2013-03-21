// BSD License. Author: jano@jano.com.es
#import "ARTST.h"

@implementation ARTSTNode
@end


@implementation ARTST


-(BOOL) isEmpty {
    return self.root==nil;
}


-(BOOL) containsKey:(NSString*)key
{
    return [self trieValueForKey:key] != nil;
}


// Find and return the longest prefix of the given string.
-(NSString*) longestPrefixOf:(NSString*)string
{
    if (string == nil || [string length] == 0) {
        return nil;
    }

    NSUInteger length = 0;
    ARTSTNode*node = self.root;
    NSUInteger index = 0;
    while (node != nil && index < [string length])
    {
        unichar c = [string characterAtIndex:index];
        if      (c < node.c) node = node.left;   // less than
        else if (c > node.c) node = node.right;  // greater than
        else {                                   // equal (found one character)
            index++;                                // advance to next character
            if (node.value != nil) length = index;  // save max length found
            node = node.mid;                        // continue
        }
    }

    // return the substring for the max length found
    return [string substringWithRange:NSMakeRange(0, length)];
}


#pragma mark - node, put


-(ARTSTValue*) trieValueForKey:(NSString*)key
{
    // return nil if 
    BOOL isInvalidKey = key==nil || [key length]==0;
    if (isInvalidKey) return nil;

    // return the value of the node with the given key, or nil if not found
    return [self nodeWithKey:key index:0 fromNode:self.root].value;
}


// Return the subtrie corresponding to the given key.
-(ARTSTNode*) nodeWithKey:(NSString*)  key
                    index:(NSUInteger) index
                 fromNode:(ARTSTNode*) node
{
    // return nil if the key or node are nil, or if the key is 0 characters
    BOOL isInvalidKey = key == nil || [key length] == 0;
    if (isInvalidKey || node==nil) return nil;

    unichar c = [key characterAtIndex:index];
    ARTSTNode *result;
    if (c < node.c)                   result = [self nodeWithKey:key index:index   fromNode:node.left];  // less than
    else if (c > node.c)              result = [self nodeWithKey:key index:index   fromNode:node.right]; // greater than
    else if (index < [key length]-1)  result = [self nodeWithKey:key index:index+1 fromNode:node.mid];   // equal (character found), move to the next
    else                              result = node;                                                     // end of the string, return the node

    return result;
}


-(void) putKey:(NSString*)string value:(ARTSTValue*)value
{
    if (string==nil || [string length]==0 || value==nil){
        NSLog(@"refusing to add invalid key-value: %@-%@",string,value);
        return;
    }
    if (![self containsKey:string]) {
        _numberOfKeys++;
    }
    _root = [self putKey:string value:value index:0 atNode:self.root];
}


-(ARTSTNode*) putKey:(NSString*)   key
               value:(ARTSTValue*) value
               index:(NSUInteger)  index
              atNode:(ARTSTNode*)  node
{
    unichar c = [key characterAtIndex:index];

    // create the node if needed
    if (node == nil) {
        node = [ARTSTNode new];
        node.c = c;
    }

    // recursive search
    if      (c < node.c)             node.left  = [self putKey:key value:value index:index atNode:node.left];     // less than
    else if (c > node.c)             node.right = [self putKey:key value:value index:index atNode:node.right];    // greater than
    else if (index < [key length]-1) node.mid   = [self putKey:key value:value index:index + 1 atNode:node.mid];  // equal (character found), move to the next
    else                             node.value = value;                                                          // end of the string, set the value

    return node;
}


#pragma mark - keys


// all keys in symbol table
-(ARQueueList*) keys
{
    ARQueueList* queue = [ARQueueList new];
    [self collectKeysFromNode:self.root prefix:@"" queue:queue];
    return queue;
}


// all keys starting with given prefix
-(ARQueueList*) keysWithPrefix:(NSString*)prefix
{
    return [self keysWithPrefix:prefix limit:0];
}


-(ARQueueList*) keysWithPrefix:(NSString*)prefix limit:(NSUInteger)limit {
    ARQueueList* queue = [ARQueueList new];
    ARTSTNode*node = [self nodeWithKey:prefix index:0 fromNode:self.root];
    if (node == nil) {
        return queue;
    }
    if (node.value != nil) {
        [queue enqueue:prefix];
    }
    [self collectKeysFromNode:node.mid prefix:prefix queue:queue limit:limit];
    return queue;
}


// return all keys matching given wilcard pattern
-(ARQueueList*) keysThatMatch:(NSString*)pattern
{
    ARQueueList* queue = [ARQueueList new];
    [self collectKeysFromNode:self.root prefix:@"" index:0 pattern:pattern queue:queue];
    return queue;
}


#pragma mark - collect


// all keys in subtrie rooted at node with given prefix.
-(void) collectKeysFromNode:(ARTSTNode*)   node
                     prefix:(NSString*)    prefix
                      queue:(ARQueueList*) queue
{
    [self collectKeysFromNode:node prefix:prefix queue:queue limit:0];
}


// all keys in subtrie rooted at node with given prefix.
-(void) collectKeysFromNode:(ARTSTNode*)   node
                     prefix:(NSString*)    prefix
                      queue:(ARQueueList*) queue
                      limit:(NSUInteger)   limit
{
    if (node == nil) {
        return;
    }
    
    [self collectKeysFromNode:node.left prefix:prefix queue:queue limit:limit];
    
    // collect the char for the current node
    NSString *tmpKey = [NSString stringWithFormat:@"%@%c",prefix, node.c];
    if (limit>0 && [queue count]==limit) {
        return;
    } else if (node.value != nil) {
        [queue enqueue:tmpKey];
    }
    
    [self collectKeysFromNode:node.mid   prefix:tmpKey queue:queue limit:limit];
    [self collectKeysFromNode:node.right prefix:prefix queue:queue limit:limit];
}


-(void) collectKeysFromNode:(ARTSTNode*)   node
                     prefix:(NSString*)    prefix
                      index:(NSUInteger)   index
                    pattern:(NSString*)    pattern
                      queue:(ARQueueList*) queue
{
    if (node == nil) return;
    unichar c = [pattern characterAtIndex:index];
    BOOL isWildcard = c == '.';

    if (isWildcard || c < node.c) {
        [self collectKeysFromNode:node.left prefix:prefix index:index pattern:pattern queue:queue];
    }

    if (isWildcard || c == node.c) {
        NSString *tmpKey = [NSString stringWithFormat:@"%@%c", prefix, node.c];
        if (index == [pattern length]-1 && node.value != nil) {
            [queue enqueue:tmpKey];
        }
        if (index < [pattern length]-1) {
            [self collectKeysFromNode:node.mid prefix:tmpKey index:index +1 pattern:pattern queue:queue];
        }
    }

    if (isWildcard || c > node.c) {
        [self collectKeysFromNode:node.right prefix:prefix index:index pattern:pattern queue:queue];
    }
}


@end
