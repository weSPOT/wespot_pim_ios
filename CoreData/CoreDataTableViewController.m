//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Fall 2011.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface CoreDataTableViewController()

@property (nonatomic) BOOL beganUpdates;

@end

@implementation CoreDataTableViewController

#pragma mark - Properties

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;
@synthesize sectionOffset = _sectionOffset;

//- (id)init {
//    if (self = [super init] ){
//        _sectionOffset = 0;
//        
//        return self;
//    }
//    
//    return nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        if (self.debug) {
            if (self.fetchedResultsController.fetchRequest.predicate) {
                NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
            }
        } else {
            NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
        }
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        if (error) {
            NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
        }
    } else {
        if (self.debug) {
            NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    
    [self.tableView reloadData];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        newfrc.delegate = self;
        
        if ((!self.title || [self.title isEqualToString:oldfrc.fetchRequest.entity.name]) && (!self.navigationController || !self.navigationItem.title)) {
            //            self.title = newfrc.fetchRequest.entity.name;
        }
        
        if (newfrc) {
            if (self.debug) {
                NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            }
            [self performFetch];
        } else {
            if (self.debug) {
                NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UITableViewDataSource

/*!
 *  Returns the number of Sections in the Table Data.
 *
 *  @param tableView The UITableView.
 *
 *  @return The number of sections.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

/*!
 *  Returns the number of Rows in a Section of the Table Data.
 *
 *  @param tableView The UITableView.
 *  @param section   The Section.
 *
 *  @return The number of Rows in the requested Section.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section+self.sectionOffset] numberOfObjects];
}

/*!
 *  Get the Section Title of the Table Header.
 *
 *  @param tableView The UITableView.
 *  @param section   The Section.
 *
 *  @return The Section Title.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([self.tableView respondsToSelector:@selector(beginUpdates)]) {
        [self.tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex+self.sectionOffset]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex+self.sectionOffset]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    NSIndexPath *oip = [self coreDataIndexPathToTableIndexPath:indexPath];
    NSIndexPath *nip = [self coreDataIndexPathToTableIndexPath:newIndexPath];
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nip]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oip]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:oip]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:oip]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nip]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

/*!
 *  Notifies the UITableView a model update has ended.
 *
 *  @param controller <#controller description#>
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"[%s]", __func__);
    if ([self.tableView respondsToSelector:@selector(endUpdates)]) {
        [self.tableView endUpdates];
    }
}

/*!
 *  Override this method to beb notified of any changes.
 *
 *  @param cell      The cell changed.
 *  @param indexPath The indexPath of the change.
 */
-(void) configureCell: (id) cell atIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+self.sectionOffset];
    NSLog(@"cell changed %@ at %@", cell, ip);
}

-(NSIndexPath *)tableIndexPathToCoreDataIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-(int)self.sectionOffset];
}

-(NSIndexPath *)coreDataIndexPathToTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+(int)self.sectionOffset];
}

@end

