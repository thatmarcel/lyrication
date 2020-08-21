#import "ScrollingLyricsViewController+TableViewDataSource.h"

@implementation ScrollingLyricsViewController (TableViewDataSource)
    - (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        if ([self.lyrics count] < 1) {
            return 0;
        }
        return [self.lyrics count];
    }

    - (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        LyricsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"LyricsTableViewCell"];

        [cell setup];

        cell.index = indexPath.row;

        NSDictionary *item = self.lyrics[indexPath.row];
		cell.lineLabel.text = [item objectForKey:@"lyrics"];

        if (self.lastIndex && self.lastIndex == indexPath.row) {
            [cell highlight];
        }

        return cell;
    }

    - (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
    }
@end