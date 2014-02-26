//
//  PKDXCoreDataDS.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 8/21/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface UZKCoreDataDS : NSObject <UITableViewDataSource, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSString * entityName;

@property (nonatomic, strong) NSString * cellIdentifier;
@property (nonatomic, strong) NSString * (^reusableViewIdentifierBlock)(NSString * kind, NSIndexPath * indexPath);
@property (nonatomic, strong) void (^reusableViewDequeueBlock)(UICollectionReusableView * reusableView, NSString * reusableViewText);

@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray * sortDescriptors;
@property (nonatomic, strong) NSString * sectionNameKeyPath;

@property (nonatomic) NSInteger sectionIndexOffset;

@property (nonatomic, readonly) NSFetchedResultsController * fetchedResultsController;

- (NSIndexPath *)indexPathForObject:(id)object;

@end
