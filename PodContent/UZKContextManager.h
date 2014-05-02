//
//  PKDXPokedexContextManager.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 1/25/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface UZKContextManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext * context;

- (void)persist;

- (NSArray *)fetchForName:(NSString *)entityName;

- (NSArray *)fetchForName:(NSString *)entityName predicateString:(NSString *)predicateString sortDescriptors:(NSArray *)sorters;

- (NSArray *)fetchForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sorters;

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)fetchedResultsControllerForName:(NSString *)entityName predicateString:(NSString *)predicateString sortDescriptors:(NSArray *)sorters sectionNameKeyPath:(NSString *)sectionKey;

- (NSFetchedResultsController *)fetchedResultsControllerForName:(NSString *)entityName  predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sorters sectionNameKeyPath:(NSString *)sectionKey;

- (void)performFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;
#endif

- (NSManagedObject *)createInstanceForEntityForName:(NSString *)name;

+ (UZKContextManager *)instance;

@end
