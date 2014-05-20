//
//  PKDXCoreDataDS.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 8/21/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface UZKCoreDataDS : NSObject <UITableViewDataSource, UICollectionViewDataSource, UIPickerViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSString * entityName;

@property (nonatomic, strong) NSString * cellIdentifier;
@property (nonatomic, strong) void (^cellDequeueBlock)(id);
@property (nonatomic, strong) NSString * (^reusableViewIdentifierBlock)(NSString * kind, NSIndexPath * indexPath);
@property (nonatomic, strong) void (^reusableViewDequeueBlock)(UICollectionReusableView * reusableView, NSString * reusableViewText);

@property (nonatomic, strong) NSPredicate * predicate;
@property (nonatomic, strong) NSArray * sortDescriptors;
@property (nonatomic, strong) NSString * sectionNameKeyPath;

@property (nonatomic, readonly) BOOL includesNilItem;
@property (nonatomic, readonly) NSString * nilItemTitle;

@property (nonatomic) NSInteger sectionIndexOffset;

@property (nonatomic, readonly) NSFetchedResultsController * fetchedResultsController;

- (NSIndexPath *)indexPathForObject:(id)object;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (void)setIncludesNilItemWithTitle:(NSString *)title;
- (void)removeNilItem;

#pragma mark - PICKER

// This is NOT a DataSource message, so you'll have to implement it in your code.
// I did this to make things easy for you, so just call it if you need to!
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

@end
