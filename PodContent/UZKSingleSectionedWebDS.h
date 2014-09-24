//
//  UZKSingleSectionedWebDS.h
//  UZKDataSources
//
//  Created by Tiago Furlanetto on 1/27/14.
//  Copyright (c) 2014 Uzaak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UZKWebDSClient.h"

@interface UZKSingleSectionedWebDS : NSObject <UICollectionViewDataSource, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;
@property (nonatomic, weak) IBOutlet UITableView * tableView;

@property (nonatomic, strong) NSInteger (^numberOfItemsInSectionBlock)(NSInteger calculatedNumber, NSInteger section);

@property (nonatomic, strong) NSString * cellIdentifier;
@property (nonatomic, strong) NSString * (^cellIdentifierBlock)(id);
@property (nonatomic, strong) id (^customObjectBlock)(id);
@property (nonatomic, strong) void (^cellDequeueBlock)(id);

@property (nonatomic, strong) NSString * loadMoreCellIdentifier;
@property (nonatomic, strong) NSString * noResultsCellIdentifier;

@property (nonatomic, strong) NSString * (^reusableViewIdentifierBlock)(NSString * kind, NSIndexPath * indexPath);
@property (nonatomic, strong) void (^reusableViewDequeueBlock)(UICollectionReusableView * reusableView);

@property (nonatomic, strong) NSArray * (^requestCallbackStartBlock)(NSArray * retrievedContent);
@property (nonatomic, strong) void (^requestCallbackFinishBlock)(NSArray * retrievedContent);

@property (nonatomic, strong) BOOL (^canEditRowBlock)(NSIndexPath * indexPath);
@property (nonatomic, strong) void (^itemDeletionBlock)(NSIndexPath * indexPath);

@property (nonatomic, strong) IBOutlet id<UZKWebDSClient> client;

@property (nonatomic, strong) NSDictionary * parameters;

@property (nonatomic) NSInteger sectionIndexOffset;

- (void)setSectionData:(NSArray *)dataForSection0, ... NS_REQUIRES_NIL_TERMINATION;

- (id)objectForIndexPath:(NSIndexPath *)indexPath;
- (id)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)hasNoResults;
- (BOOL)isDoneRequestingPages;

- (void)resetData;

// Forces load of next page. If you don't know what it's for, you probably don't need to use it.
- (void)forceLoadNextPage;

@end
