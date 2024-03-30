#import "./LXScrollingLyricsViewController+TableViewDataSource.h"

@implementation LXScrollingLyricsViewController (TableViewDataSource)
    - (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
        if ([self.lyrics count] < 1) {
            return 0;
        }
        return [self.lyrics count];
    }

    - (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
        LXLyricsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"LXLyricsTableViewCell"];

        cell.standardLineColor = self.standardLineColor;
        cell.highlightedLineColor = self.highlightedLineColor;

        cell.distanceFromHighlighted = indexPath.row - self.lastIndex;
        if (cell.distanceFromHighlighted < 0) {
            cell.distanceFromHighlighted = 1;
        }

        [cell setup];

        cell.index = indexPath.row;

        NSDictionary* item = self.lyrics[indexPath.row];

		cell.lineLabel.text = [item objectForKey: @"lyrics"];

        if (self.lastIndex && self.lastIndex == indexPath.row) {
            [cell highlight];
        }

        return cell;
    }

    - (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
        return 1;
    }
@end
