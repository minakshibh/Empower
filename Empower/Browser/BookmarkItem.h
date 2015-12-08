//
//  BookmarkItem.h
//
//  Created by Alexandru Catighera on 6/17/11.
//  Copyright 2011 Evidon. All rights reserved.
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BookmarksController;

@interface BookmarkItem : UITableViewCell {
	BookmarksController *bookmarksController;
	
	UITableView *tableView;
	NSIndexPath *indexPath;
	
	IBOutlet UILabel *cellLabel;
	IBOutlet UIImageView *cellImage;
	
	IBOutlet UIButton *deleteCircle;
	IBOutlet UIButton *deleteConfirmation;
}
@property(nonatomic, strong) BookmarksController *bookmarksController;

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) UILabel *cellLabel;
@property(nonatomic, strong) UIImageView *cellImage;

@property(nonatomic, strong) UIButton *deleteCircle;
@property(nonatomic, strong) UIButton *deleteConfirmation;

-(void) enableEdit;
-(void) disableEdit;
-(void) enableDelete;
-(void) disableDelete;

-(IBAction) deleteCircleClick:(id)sender;
-(IBAction) deleteItem:(id)sender;
- (void) deleteItemFromDB:(NSManagedObject *) dbItem;

@end
