//
//  PKDXWebDS.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 9/15/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UZKWebDSClient.h"

@interface UZKWebDS : NSObject <UICollectionViewDataSource, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSString * cellIdentifier;
@property (nonatomic, strong) NSString * (^cellIdentifierBlock)(id);
@property (nonatomic, strong) void (^cellDequeueBlock)(id);
@property (nonatomic, strong) IBOutlet id<UZKWebDSClient> client;

@property (nonatomic, readonly) NSArray * pages;

@property (nonatomic, strong) NSDictionary * parameters;

@property (nonatomic) NSInteger sectionIndexOffset;

- (void)setSectionData:(NSArray *)dataForSection0, ... NS_REQUIRES_NIL_TERMINATION;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;

- (void)resetData;

@end
