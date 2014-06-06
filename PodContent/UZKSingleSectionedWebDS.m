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


- (id)init
{
    self = [super init];
    
    if ( self )
    {
        self.cellIdentifier = @"Cell";
        self.pages = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark Gambizarra

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;

    self.loadMoreCellIdentifier = @"UZKWebDSLoadMoreCollectionCell";
    self.noResultsCellIdentifier = @"UZKWebDSNoResultsCollectionCell";
    
    [_collectionView registerNib:[UINib nibWithNibName:@"UZKWebDSLoadMoreCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"UZKWebDSLoadMoreCollectionCell"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"UZKWebDSNoResultsCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"UZKWebDSNoResultsCollectionCell"];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    self.loadMoreCellIdentifier = @"UZKWebDSLoadMoreTableCell";
    self.noResultsCellIdentifier = @"UZKWebDSNoResultsTableCell";
    
    [_tableView registerNib:[UINib nibWithNibName:@"UZKWebDSLoadMoreTableCell" bundle:nil] forCellReuseIdentifier:@"UZKWebDSLoadMoreTableCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"UZKWebDSNoResultsTableCell" bundle:nil] forCellReuseIdentifier:@"UZKWebDSNoResultsTableCell"];
}


#pragma mark Initial Stuff

- (void)setSectionData:(NSArray *)dataForSection0, ... NS_REQUIRES_NIL_TERMINATION
{
    [self resetData];
    
    va_list args;
    va_start(args, dataForSection0);
    for (NSArray * dataForSection = dataForSection0; dataForSection != nil; dataForSection = va_arg(args, NSArray *))
    {
        [self.pages addObject:dataForSection];
    }
    va_end(args);
}


#pragma mark COLLECTION

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = [self sumOfAllPages];
    
    if ( !finished ) //not yet finished
    {
        numberOfItemsInSection++; //loadMore
    }
    else if ( numberOfItemsInSection == 0 ) //finished and has no results
    {
        numberOfItemsInSection++; //noResults
    }
    
#warning Gnomes cause crashy crashy behaviour in custom layouts. This kills gnomes.
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    return numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished)
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:self.noResultsCellIdentifier forIndexPath:indexPath];
    }
    
    if ( indexPath.item == [self sumOfAllPages] )
    {
        // Posterga o "load", para evitar condições de corrida ao "fritar a tela" que travavam a carga da próxima página
        [self performSelectorOnMainThread:@selector(loadPage:) withObject:@([self.pages count]) waitUntilDone:NO];
        return [collectionView dequeueReusableCellWithReuseIdentifier:self.loadMoreCellIdentifier forIndexPath:indexPath];
    }
    
    id customObject = [self objectForIndexPath:indexPath];
    
    if ( self.customObjectBlock )
    {
        customObject = self.customObjectBlock(customObject);
    }
    
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
        self.reusableViewDequeueBlock(reusableView);
    }
    
    return reusableView;
}


#pragma mark TABLE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = [self sumOfAllPages];
    
    if ( !finished )
    {
        numberOfRowsInSection++; //loadMore
    }
    
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished) {
        return [tableView dequeueReusableCellWithIdentifier:self.noResultsCellIdentifier forIndexPath:indexPath];
    }
    
    if (indexPath.row == [self sumOfAllPages])
    {
        // Posterga o "load", para evitar condições de corrida ao "fritar a tela" que travavam a carga da próxima página
        [self performSelectorOnMainThread:@selector(loadPage:) withObject:@([self.pages count]) waitUntilDone:NO];
        return [tableView dequeueReusableCellWithIdentifier:@"UZKWebDSLoadMoreTableCell" forIndexPath:indexPath];
    }
    
    id customObject = [self objectForIndexPath:indexPath];
    
    if ( self.customObjectBlock )
    {
        customObject = self.customObjectBlock(customObject);
    }
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( self.canEditRowBlock )
    {
        return self.canEditRowBlock(indexPath);
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ( self.itemDeletionBlock )
        {
            self.itemDeletionBlock(indexPath);
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        for ( NSArray * page in self.pages )
        {
            if ( [page count] > 0 )
            {
                return;
            }
        }
        
        self.pages = [NSMutableArray new];
        [self.tableView reloadData];
    }
}


#pragma mark Custom Object Management

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
    long objectCount = indexPath.row;
    for ( int x = 0 ; x < [self.pages count] ; x++ )
    {
        if ( objectCount - (long)[[[self pages] objectAtIndex:x] count] >= 0 )
        {
            objectCount -= (long)[[[self pages] objectAtIndex:x] count];
        }
        else
        {
            return [[self.pages objectAtIndex:x] objectAtIndex:objectCount];
        }
    }
    
    return nil;
}

- (id)removeObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = 0;
    long objectCount = indexPath.row;
    for ( int x = 0 ; x < [self.pages count] ; x++ )
    {
        if ( objectCount - (long)[[[self pages] objectAtIndex:x] count] >= 0 )
        {
            objectCount -= (long)[[[self pages] objectAtIndex:x] count];
        }
        else
        {
            section = x;
            break;
        }
    }
    
    if ( ! section )
    {
        return nil;
    }
    
    NSMutableArray * page = [[self.pages objectAtIndex:section] mutableCopy];
    id object = [page objectAtIndex:indexPath.item];
    [page removeObjectAtIndex:indexPath.item];
    
    [self.pages setObject:page atIndexedSubscript:section];
    
    return object;
}


#pragma mark Async loading

- (void)loadPage:(NSNumber *)n
{
    if (loading) return;
    loading = YES;
    
    int number = [n intValue];
    
    void(^successBlock)(NSArray * stuff) = ^(NSArray * stuff)
    {
        [refreshControl endRefreshing];
        
        if ( self.requestCallbackStartBlock )
        {
            self.requestCallbackStartBlock(stuff);
        }
        
        if (![stuff count] && number == 0) {
            // Primeira página sem resultados
            finished = YES;
            [self performSelectorOnMainThread:@selector(animateNothingReallyPage)
                                   withObject:nil
                                waitUntilDone:NO];
        } else if (![stuff count]) {
            // Última página
            finished = YES;
            [self performSelectorOnMainThread:@selector(animateLastPage)
                                   withObject:nil
                                waitUntilDone:NO];
        } else {
            [self.pages addObject:stuff];
            [self performSelectorOnMainThread:@selector(animatePageInsertion:)
                                   withObject:n
                                waitUntilDone:NO];
        }
        
        loading = NO;
        
        if ( self.requestCallbackFinishBlock )
        {
            self.requestCallbackFinishBlock(stuff);
        }
    };
    
    [self.client requestPage:number + 1
              withParameters:self.parameters
                successBlock:successBlock];
}

#pragma mark Animating Insertions

- (void)animatePageInsertion:(NSNumber *)page
{
    [self updateCollectionAnimator];
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)animateLastPage
{
    [self updateCollectionAnimator];
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)animateNothingReallyPage
{
    [self updateCollectionAnimator];
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)updateCollectionAnimator
{
    if ( [self.collectionView.collectionViewLayout respondsToSelector:@selector(updateAnimator)] )
    {
        [self.collectionView.collectionViewLayout performSelector:@selector(updateAnimator)];
    }
}


#pragma mark You can't change what isn't there

- (BOOL)hasNoResults
{
    return ( [self.pages count] == 0 );
}

- (BOOL)isDoneRequestingPages
{
    return finished;
}


#pragma mark Helpers are helpful

- (NSInteger)sumOfAllPages
{
    NSInteger sumOfAllPages = 0;
    
    for (NSArray * page in self.pages)
    {
        sumOfAllPages += [page count];
    }
    
    return sumOfAllPages;
}


#pragma mark Start All Over

- (void)resetData
{
    self.pages = [NSMutableArray new];
    finished = NO;
    loading = NO;
}


- (void)forceLoadNextPage
{
    [self performSelectorOnMainThread:@selector(loadPage:) withObject:@([self.pages count]) waitUntilDone:NO];
}


@end
