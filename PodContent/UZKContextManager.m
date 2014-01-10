//
//  PKDXPokedexContextManager.m
//  Pokedex
//
//  Created by Tiago Furlanetto on 1/25/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import "UZKContextManager.h"

@implementation UZKContextManager

+ (UZKContextManager *)instance
{
    static UZKContextManager * instance = nil;
    if ( !instance )
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[super allocWithZone:nil] init];
        });
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self instance];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"Pokedex" withExtension:@"mom"];
    
    NSManagedObjectModel * managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    NSPersistentStoreCoordinator * coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSURL * sqliteURL = [[NSBundle mainBundle] URLForResource:@"Pokedex" withExtension:@"sqlite"];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqliteURL options:nil error:nil];
    
    return coordinator;
}

- (NSManagedObjectContext *)context
{
    if ( context )
    {
        return context;
    }
    
    NSPersistentStoreCoordinator * coordinator = [self coordinator];
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = coordinator;
    
    return context;
}

- (void)persist
{
    NSError * error;
    
    NSLog(@"%@", self.context.persistentStoreCoordinator);
    
    if ( ![self.context save:&error] )
    {
        NSDictionary * userInfo = [error userInfo];
        NSArray * errorList = [userInfo objectForKey:NSDetailedErrorsKey];
        
        NSLog(@"Context Saving Errors:");
        
        if ( errorList )
        {
            for ( NSError * eachError in errorList )
            {
                NSLog(@"%@", [eachError userInfo]);
            }
        }
        else
        {
            NSLog(@"%@", userInfo);
        }
    }
}

- (NSArray *)fetchForName:(NSString *)entityName
{
    return [self fetchForName:entityName predicate:nil sortDescriptors:nil];
}

- (NSArray *)fetchForName:(NSString *)entityName predicateString:(NSString *)predicateString sortDescriptors:(NSArray *)sorters
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateString];
    return [self fetchForName:entityName predicate:predicate sortDescriptors:sorters];
}

- (NSArray *)fetchForName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sorters
{
    NSError * error;
    NSFetchRequest * fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sorters];
    
    NSArray * fetchResponse = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if ( error )
    {
        NSDictionary * userInfo = [error userInfo];
        NSArray * errorList = [userInfo objectForKey:NSDetailedErrorsKey];
        
        NSLog(@"Context Saving Errors:");
        
        if ( errorList )
        {
            for ( NSError * eachError in errorList )
            {
                NSLog(@"%@", [eachError userInfo]);
            }
        }
        else
        {
            NSLog(@"%@", userInfo);
        }
    }
    
    return fetchResponse;
}

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)fetchedResultsControllerForName:(NSString *)entityName predicateString:(NSString *)predicateString sortDescriptors:(NSArray *)sorters sectionNameKeyPath:(NSString *)sectionKey
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:predicateString];
    return [self fetchedResultsControllerForName:entityName predicate:predicate sortDescriptors:sorters sectionNameKeyPath:sectionKey];
}
#endif

#if TARGET_OS_IPHONE
- (NSFetchedResultsController *)fetchedResultsControllerForName:(NSString *)entityName  predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sorters sectionNameKeyPath:(NSString *)sectionKey
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setSortDescriptors:sorters];
    [fetchRequest setPredicate:predicate];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:self.context sectionNameKeyPath:sectionKey
                                                   cacheName:nil];
}
#endif

#if TARGET_OS_IPHONE
- (void)performFromFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    NSError * error;
    [fetchedResultsController performFetch:&error];
    
    if ( error )
    {
        NSDictionary * userInfo = [error userInfo];
        NSArray * errorList = [userInfo objectForKey:NSDetailedErrorsKey];
        
        NSLog(@"Fetched Results Controller Perform Errors:");
        
        if ( errorList )
        {
            for ( NSError * eachError in errorList )
            {
                NSLog(@"%@", [eachError userInfo]);
            }
        }
        else
        {
            NSLog(@"%@", userInfo);
        }
    }
}
#endif

- (NSManagedObject *)createInstanceForEntityForName:(NSString *)name
{
    return [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.context];
}

@end
