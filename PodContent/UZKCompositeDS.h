//
//  PKDXCompositeDS.h
//  Pokedex
//
//  Created by Tiago Felisoni Furlanetto on 04/09/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UZKCompositeDS : NSObject <UITableViewDataSource, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray * innerDataSources;

- (id)dataSourceForSection:(NSInteger)section;
- (NSInteger)dataSourceSectionForSection:(NSInteger)section;
- (NSIndexPath *)dataSourceIndexPathForIndexPath:(NSIndexPath *)indexPath;

- (UICollectionViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

@end