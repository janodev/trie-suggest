
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"
#import "ARTST.h"


@interface ARTSTTest : SenTestCase
@end

@implementation ARTSTTest

-(void) testEnglishWords
{
    ARTST *trie = [ARTST new];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"es.com.jano.testing"];
    NSString *path = [bundle pathForResource:@"english-words" ofType:@"txt"];

    NSLog(@"%@",path);
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    for (NSString *line in [contents componentsSeparatedByString:@"\n"]) {
        [trie putKey:line value:line];
    }
    
    NSLog(@"words with 'adjust' prefix:\n%@",[trie keysWithPrefix:@"adjust"]);
    
}

                        
@end
