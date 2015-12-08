//
//  BookmarkFolderFormController.h
//
//  Created by Alexandru Catighera on 8/10/11.
//  Copyright 2011 Evidon. All rights reserved.
//

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net

#import <UIKit/UIKit.h>
#import	<CoreData/CoreData.h>

@class BookmarksController;

@interface BookmarkFolderFormController : UIViewController {
	BookmarksController *bookmarksController;
	
	IBOutlet UITextField *nameField;
	
	char mode;
	
	NSManagedObjectContext *managedObjectContext;
	NSManagedObject *folder;
}
@property(nonatomic,strong) BookmarksController *bookmarksController;

@property(nonatomic,strong) UITextField *nameField;

@property(nonatomic,assign) char mode;

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSManagedObject *folder;


-(IBAction) saveFolder:(id)sender;

@end
