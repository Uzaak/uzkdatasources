//
//  UZKCompositeDS.m
//  Pokedex
//
//  Created by Tiago Felisoni Furlanetto on 04/09/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import "UZKCompositeDS.h"

#import "UZKCoreDataDS.h"
#import "UITableViewCell+CustomObject.h"
#import "UICollectionViewCell+CustomObject.h"

@interface UZKCompositeDS ()

@property (nonatomic, strong) NSArray * innerDataSourceSections;

@property (nonatomic, strong) NSMutableDictionary * cellDictionary;

@end

@implementation UZKCompositeDS

#pragma mark COLLECTION

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger number = 0;
    NSMutableArray * innerSectionCount = [@[] mutableCopy];
    
    for (id source in self.innerDataSources) {
        if ( [source respondsToSelector:@selector(setSectionIndexOffset:)] )
        {
            [source setSectionIndexOffset:number];
        }
        NSInteger numberForSection = [source numberOfSectionsInCollectionView:collectionView];
        number += numberForSection;
        [innerSectionCount addObject:[NSNumber numberWithInteger:numberForSection]];
    }
    
    self.innerDataSourceSections = innerSectionCount;
    
    return number;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger newSection = [self dataSourceSectionForSection:section];
    return [[self dataSourceForSection:section] collectionView:collectionView numberOfItemsInSection:newSection];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    id dataSource = [self dataSourceForSection:indexPath.section];
    NSIndexPath * newIndexPath = [self dataSourceIndexPathForIndexPath:indexPath];
    
    return [dataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id ds = [self dataSourceForSection:indexPath.section];
    UICollectionViewCell * cell;
    
    if ( [ds isKindOfClass:[UZKCoreDataDS class]] )
    {
    
        UZKCoreDataDS * coreds = [self dataSourceForSection:indexPath.section];
        NSString * identifier = coreds.cellIdentifier;

        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
        cell.customObject = [coreds.fetchedResultsController objectAtIndexPath:[self dataSourceIndexPathForIndexPath:indexPath]];
        
    }
    else
    {
        cell = [ds collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    self.cellDictionary[indexPath] = cell;
    return cell;
}

#pragma mark TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger number = 0;
    NSMutableArray * innerSectionCount = [@[] mutableCopy];
    
    for (id source in self.innerDataSources) {
        if ( [source respondsToSelector:@selector(setSectionIndexOffset:)] )
        {
            [source setSectionIndexOffset:number];
        }
        NSInteger numberForSection = [source numberOfSectionsInTableView:tableView];
        number += numberForSection;
        [innerSectionCount addObject:[NSNumber numberWithInteger:numberForSection]];
    }
    
    self.innerDataSourceSections = innerSectionCount;
    
    return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger newSection = [self dataSourceSectionForSection:section];
    return [[self dataSourceForSection:section] tableView:tableView numberOfRowsInSection:newSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id ds = [self dataSourceForSection:indexPath.section];
    UITableViewCell * cell;
    
    if ( [ds isKindOfClass:[UZKCoreDataDS class]] )
    {
        
        UZKCoreDataDS * coreds = [self dataSourceForSection:indexPath.section];
        NSString * identifier = coreds.cellIdentifier;
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.customObject = [coreds.fetchedResultsController objectAtIndexPath:[self dataSourceIndexPathForIndexPath:indexPath]];
        
    }
    else
    {
        cell = [ds tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    self.cellDictionary[indexPath] = cell;
    return cell;
}


#pragma mark - Cell at Index Path

- (NSMutableDictionary *)cellDictionary
{
    if ( !_cellDictionary )
    {
        self.cellDictionary = [NSMutableDictionary new];
    }
    
    return _cellDictionary;
}

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellDictionary[indexPath];
}


#pragma mark Generics

- (id)dataSourceForSection:(NSInteger)section
{
    NSInteger number = 0;
    int i = 0;
    
    for (id source in self.innerDataSources) {
        number += [[self.innerDataSourceSections objectAtIndex:i] integerValue];
        if ( section < number )
        {
            return source;
        }
        i++;
    }

    return nil;
}

- (NSInteger)dataSourceSectionForSection:(NSInteger)section
{
    NSInteger newSection = section;
    int i = 0;
    
    for (id source in self.innerDataSources) {
        NSInteger number = [[self.innerDataSourceSections objectAtIndex:i] integerValue];
        if ( newSection < number )
        {
            return newSection;
        }
        newSection -= number;
        i++;
    }
    
    return nil;
}


- (NSIndexPath *)dataSourceIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger newSection = indexPath.section;
    int i = 0;
    
    for (id source in self.innerDataSources) {
        NSInteger number = [[self.innerDataSourceSections objectAtIndex:i] integerValue];
        if ( newSection < number )
        {
            return [NSIndexPath indexPathForRow:indexPath.row inSection:newSection];
        }
        newSection -= number;
        i++;
    }
    
    return nil;
}

@end
