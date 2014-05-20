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

@property (nonatomic, strong) NSString * nilItemTitle;

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


#pragma mark - Nil Item

- (void)setIncludesNilItemWithTitle:(NSString *)title
{
    _includesNilItem = YES;
    self.nilItemTitle = title;
}

- (void)removeNilItem
{
    _includesNilItem = NO;
    self.nilItemTitle = nil;
}


#pragma mark - PICKER

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSUInteger numberOfRows = [[[self.fetchedResultsController sections] objectAtIndex:component] numberOfObjects];
    if ( self.includesNilItem )
    {
        numberOfRows++;
    }
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ( ( self.includesNilItem ) && ( row == 0 ) )
    {
        return self.nilItemTitle;
    }
    
    return [[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForItem:(self.includesNilItem ? row-1 : row) inSection:component]] description];
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
        NSString * textForReusableView = [self titleForHeaderInSection:indexPath.section - self.sectionIndexOffset];
        self.reusableViewDequeueBlock(reusableView, textForReusableView);
    }
    
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.customObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ( self.cellDequeueBlock )
    {
        self.cellDequeueBlock(cell);
    }
    
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
    
    if ( self.cellDequeueBlock )
    {
        self.cellDequeueBlock(cell);
    }
    
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

- (NSIndexPath *)indexPathForObject:(id)object
{
    return [self.fetchedResultsController indexPathForObject:object];
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


#pragma mark - Objects

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.includesNilItem )
    {
        if ( indexPath.item == 0 )
        {
            return nil;
        }
        
        NSIndexPath * relativeIndexPath = [NSIndexPath indexPathForItem:(indexPath.item - 1) inSection:indexPath.section];
        
        return [self.fetchedResultsController objectAtIndexPath:relativeIndexPath];
    }
    
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


@end
