//
//  UZKSingleSectionedWebDS.m
//  UZKDataSources
//
//  Created by Tiago Furlanetto on 1/27/14.
//  Copyright (c) 2014 Uzaak. All rights reserved.
//

#import "UZKSingleSectionedWebDS.h"

#import "UICollectionViewCell+CustomObject.h"
#import "UITableViewCell+CustomObject.h"

@interface UZKSingleSectionedWebDS ()

@property (nonatomic, strong) NSMutableArray * pages;

@end

@implementation UZKSingleSectionedWebDS
{
    BOOL finished;
    BOOL loading;
    UIRefreshControl * refreshControl;
}


#pragma mark COLLECTION

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    
    for (NSArray * page in self.pages)
    {
        numberOfItemsInSection += [page count];
    }
    
    if ( !finished )
    {
        numberOfItemsInSection++; //loadMore
    }
    
    return numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished)
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UZKWebDSNoResultsCollectionCell" forIndexPath:indexPath];
    }
    
    if (indexPath.item == [self collectionView:collectionView numberOfItemsInSection:0] - 1)
    {
        // Posterga o "load", para evitar condições de corrida ao "fritar a tela" que travavam a carga da próxima página
        [self performSelectorOnMainThread:@selector(loadPage:) withObject:@([self.pages count]) waitUntilDone:NO];
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UZKWebDSLoadMoreCollectionCell" forIndexPath:indexPath];
    }
    
    id customObject = [self objectForIndexPath:indexPath];
    NSString * cellIdentifier;
    
    if ( self.cellIdentifierBlock )
    {
        cellIdentifier = self.cellIdentifierBlock(customObject);
    }
    
    if ( !cellIdentifier ) //previous block can return nil
    {
        cellIdentifier = self.cellIdentifier;
    }
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.customObject = customObject;
    
    if ( self.cellDequeueBlock )
    {
        self.cellDequeueBlock(cell);
    }
    
    return cell;
}


#pragma mark TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    
    for (NSArray * page in self.pages)
    {
        numberOfRowsInSection += [page count];
    }
    
    if ( !finished )
    {
        numberOfRowsInSection++; //loadMore
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished) {
        return [tableView dequeueReusableCellWithIdentifier:@"UZKWebDSNoResultsTableCell" forIndexPath:indexPath];
    }
    
    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:0] - 1)
    {
        // Posterga o "load", para evitar condições de corrida ao "fritar a tela" que travavam a carga da próxima página
        [self performSelectorOnMainThread:@selector(loadPage:) withObject:@([self.pages count]) waitUntilDone:NO];
        return [tableView dequeueReusableCellWithIdentifier:@"UZKWebDSLoadMoreTableCell" forIndexPath:indexPath];
    }
    
    id customObject = [self objectForIndexPath:indexPath];
    NSString * cellIdentifier;
    
    if ( self.cellIdentifierBlock )
    {
        cellIdentifier = self.cellIdentifierBlock(customObject);
    }
    
    if ( !cellIdentifier ) //previous block can return nil
    {
        cellIdentifier = self.cellIdentifier;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.customObject = customObject;
    
    if ( self.cellDequeueBlock )
    {
        self.cellDequeueBlock(cell);
    }
    
    return cell;
}


#pragma mark Custom Object Management

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger objectCount = indexPath.row;
    for ( int x = 0 ; x < [self.pages count] ; x++ )
    {
        if ( objectCount - [[[self pages] objectAtIndex:x] count] > 0 )
        {
            objectCount -= [[[self pages] objectAtIndex:x] count];
        }
        else
        {
            return [[self.pages objectAtIndex:x] objectAtIndex:objectCount];
        }
    }
    
    return nil;
}

@end
