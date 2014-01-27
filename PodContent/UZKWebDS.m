//
//  PKDXWebDS.m
//  Pokedex
//
//  Created by Tiago Furlanetto on 9/15/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import "UZKWebDS.h"

#import "UICollectionViewCell+CustomObject.h"
#import "UITableViewCell+CustomObject.h"

@interface UZKWebDS ()

@property (nonatomic, strong) NSMutableArray * pages;

@end

@implementation UZKWebDS
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
    
    [_collectionView registerNib:[UINib nibWithNibName:@"UZKWebDSLoadMoreCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"UZKWebDSLoadMoreCollectionCell"];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"UZKWebDSNoResultsCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"UZKWebDSNoResultsCollectionCell"];
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
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
    return [self.pages count] + (([self.pages count] && finished) ? 0 : 1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == [self.pages count]) {
        return 1;
    }
    
    return [[self.pages objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UZKWebDSNoResultsCollectionCell" forIndexPath:indexPath];
    }
    
    if (indexPath.section - self.sectionIndexOffset >= [self.pages count]) {
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
    return [self.pages count] + (([self.pages count] && finished) ? 0 : 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == [self.pages count]) {
        return 1;
    }
    
    return [[self.pages objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pages count] && finished) {
        return [tableView dequeueReusableCellWithIdentifier:@"UZKWebDSNoResultsTableCell" forIndexPath:indexPath];
    }
    
    if (indexPath.section - self.sectionIndexOffset >= [self.pages count]) {
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
    NSInteger section = indexPath.section - self.sectionIndexOffset;
    if ( section == [self.pages count] )
    {
        return nil;
    }
    return [[self.pages objectAtIndex:section] objectAtIndex:indexPath.row];
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
