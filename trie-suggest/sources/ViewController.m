
// BSD License. Created by jano@jano.com.es

#import "ViewController.h"

@interface ViewController()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) ARArrayList *objects;
@property (nonatomic, strong) ARArrayList *filteredObjects;
@property (nonatomic, strong) ARTST *trie;
@end


@implementation ViewController


// Link to a button to show the search bar.
- (IBAction)focusSearchBar:(id)sender {
    [self.searchBar becomeFirstResponder];
}


-(void) loadEnglishDictionary {
    NSLog(@"wait for it, I'm loading 125,000 english words");
    self.trie = [ARTST new];
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"es.com.jano.trie-suggest"];
    NSString *path = [bundle pathForResource:@"english-words" ofType:@"txt"];
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    for (NSString *line in [contents componentsSeparatedByString:@"\n"]) {
        [self.trie putKey:line value:line];
    }
}


#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    BOOL isSearchTable = tableView == self.searchDisplayController.searchResultsTableView;
    NSInteger sections = isSearchTable ? 1 : 1;
    return sections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    BOOL isSearchTable = tableView == self.searchDisplayController.searchResultsTableView;
    NSInteger rows = isSearchTable ? [self.filteredObjects count] : [self.objects count];
    return rows;
}


- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL isIOS6 = [[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0;
    
    NSInteger row = [indexPath row];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }

    if (!isIOS6) {
        if (cell==nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // object for the row
    BOOL isSearchTable = tableView == self.searchDisplayController.searchResultsTableView;
    id object =  isSearchTable ? [self.filteredObjects objectAtIndex:row]
                               : [self.objects objectAtIndex:row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",object];
    
    return cell;
}


#pragma mark - UIViewController


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.objects = [NSArray arrayWithObjects:@"search",@"something",nil];
    self.filteredObjects = [NSMutableArray array];
    
    // start with the table scrolled up so it hides the search bar
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];

    [self loadEnglishDictionary];
}


#pragma mark - UISearchDisplayController


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    const NSUInteger resultLimit = 10;
    self.filteredObjects = [self.trie keysWithPrefix:searchText limit:resultLimit];
    //NSLog(@"objects:%@\nfiltered:%@",self.objects,self.filteredObjects);
}


// react to search string changes
- (BOOL) searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchString:(NSString*)searchString
{
    NSInteger selectedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    NSArray *scopeButtonTitles = [self.searchDisplayController.searchBar scopeButtonTitles];
    NSString *scope = [scopeButtonTitles objectAtIndex:selectedScopeButtonIndex];
    
    [self filterContentForSearchText:searchString scope:scope];
    
    return YES;
}


// react to scope bar changes
- (BOOL) searchDisplayController:(UISearchDisplayController*)controller
 shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString* text = [self.searchDisplayController.searchBar text];
    NSArray* scopeButtonTitles = [self.searchDisplayController.searchBar scopeButtonTitles];
    NSString* scope = [scopeButtonTitles objectAtIndex:searchOption];
    
    [self filterContentForSearchText:text scope:scope];
    
    return YES;
}


@end
