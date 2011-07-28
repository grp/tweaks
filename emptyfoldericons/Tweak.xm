
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


%hook SBFolderIcon

- (id)_miniIconGridFromRow:(int)row toRow:(int)row_ {
    return [UIImage imageNamed:@"FolderIconBG.png"];
}

%end


