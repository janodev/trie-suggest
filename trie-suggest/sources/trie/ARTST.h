
// BSD License. Author: jano@jano.com.es

#import "ARQueueList.h"

typedef NSObject ARTSTValue;

@interface ARTSTNode : NSObject
@property(nonatomic,assign) unichar c;
@property(nonatomic,strong) ARTSTValue *value;
@property(nonatomic,strong) ARTSTNode *left, *mid, *right;
@end


/* Ternary Search Tree.
 * A trie representation that requires less space.
 *
 * A trie where
 *   - Each node has 3 links, a character, and a value.
 *   - Search advances left, middle, or right depending if the next character is <, =, or > than the current one.
 *  The shape of the tree depends on the insertion order.
 *
 *  A search miss in a TST built from N random string keys requires ~ln N character compares, on the average.
 *  A search hit or an insertion in a TST uses a character compare for each character in the search key.
 */
@interface ARTST : NSObject

@property(nonatomic,assign,readonly) NSUInteger numberOfKeys;
@property(nonatomic,strong,readonly) ARTSTNode *root;

// Return YES if the trie is empty (root is nil).
-(BOOL) isEmpty;

// Return YES if the trie contains the key.
-(BOOL) containsKey:(NSString*)key;

// Return the longest prefix of the trie for the given string.
-(NSString*) longestPrefixOf:(NSString*)string;

-(void) collectKeysFromNode:(ARTSTNode*)   node
                     prefix:(NSString*)    prefix
                      index:(NSUInteger)   index
                    pattern:(NSString*)    pattern
                      queue:(ARQueueList*) queue;

#pragma mark - keys

// All keys in the table.
-(ARQueueList*) keys;

// All keys with the given prefix.
-(ARQueueList*) keysWithPrefix:(NSString*)prefix;

// All keys with the given prefix.
-(ARQueueList*) keysWithPrefix:(NSString*)prefix limit:(NSUInteger)limit;

// All keys that match the given pattern.
// A period (.) in the pattern matches any character.
-(ARQueueList*) keysThatMatch:(NSString*)pattern;

#pragma mark put, get, delete

-(void) putKey:(NSString*)string value:(ARTSTValue*)value;

// Return the value for the key, or nil if not found.
-(ARTSTValue*) trieValueForKey:(NSString*)key;

@end



