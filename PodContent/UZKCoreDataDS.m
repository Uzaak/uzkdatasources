//
//  PKDXCoreDataDS.m
//  Pokedex
//
//  Created by Tiago Furlanetto on 8/21/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import "UZKCoreDataDS.h"

#import "UITableViewCell+CustomObject.h"
#import "UICollectionViewCell+CustomObject.h"

#import "UZKContextManager.h"

@interface UZKCoreDataDS ()
@property (nonatomic, strong) NSFetchedResultsController * fetchedResultsController;
@end

@implementation UZKCoreDataDS
{
    UZKContextManager * pokedex;
}

- (id)init
{
    self = [super init];
    
    if ( self )
    {
        self.cellIdentifier = @"Cell";
        self.sortDescriptors = @[];
        pokedex = [UZKContextManager instance];
    }
    
    return self;
}

#pragma mark REFRESH FETCH ON RESETTING

- (void)setPredicate:(NSPredicate *)predicate
{
    _predicate = predicate;
    self.fetchedResultsController = nil;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    _sortDescriptors = sortDescriptors;
    self.fetchedResultsController = nil;
}

- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath
{
    _sectionNameKeyPath = sectionNameKeyPath;
    self.fetchedResultsController = nil;
}

#pragma mark COLLECTION

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)collectionView:(UITableView *)collectionView titleForHeaderInSection:(NSInteger)section
{
    return [self titleForHeaderInSection:section];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ( !self.reusableViewIdentifierBlock )
    {
        return nil;
    }

    NSString * reusableViewIdentifier = self.reusableViewIdentifierBlock(kind, indexPath);

    UICollectionReusableView * reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableViewIdentifier forIndexPath:indexPath];
    
    if ( self.reusableViewDequeueBlock )
    {
        NSString * textForReusableView = [self titleForHeaderInSection:indexPath.section];
        self.reusableViewDequeueBlock(reusableView, textForReusableView);
    }

    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.customObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.customObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark Generics

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if ( self.sectionNameKeyPath )
    {
        id obj = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        return [obj valueForKeyPath:self.sectionNameKeyPath];
    }
    
    return nil;
}

#pragma mark CoreData

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    _fetchedResultsController = [pokedex fetchedResultsControllerForName:self.entityName predicate:self.predicate sortDescriptors:self.sortDescriptors sectionNameKeyPath:self.sectionNameKeyPath];
    
    _fetchedResultsController.delegate = self;
    
    [pokedex performFromFetchedResultsController:_fetchedResultsController];
    
    return _fetchedResultsController;
}

@end
