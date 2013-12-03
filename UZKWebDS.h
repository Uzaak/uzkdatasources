//
//  PKDXWebDS.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 9/15/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UZKWebDSClient.h"

@interface UZKWebDS : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;

@property (nonatomic, strong) NSString * cellIdentifier;
@property (nonatomic, strong) void (^cellDequeueBlock)(id);
@property (nonatomic, strong) IBOutlet id<UZKWebDSClient> client;

@property (nonatomic, strong) NSDictionary * parameters;

@property (nonatomic) NSInteger sectionIndexOffset;

- (void)resetData;

@end
