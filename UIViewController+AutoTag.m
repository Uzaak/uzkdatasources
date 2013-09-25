//
//  UIViewController+AutoTag.m
//  Pokedex
//
//  Created by Tiago Felisoni Furlanetto on 03/09/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import "UIViewController+AutoTag.h"

#import <objc/runtime.h>
#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

@implementation UIViewController (AutoTag)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method original = class_getInstanceMethod(self, @selector(viewWillAppear:));
        Method replacey = class_getInstanceMethod(self, @selector(viewWillAppearPlusPlus:));

        IMP originalImp = method_getImplementation(original);
        IMP replaceyImp = method_getImplementation(replacey);
        
        method_setImplementation(original, replaceyImp);
        method_setImplementation(replacey, originalImp);
    });
}

- (void)viewWillAppearPlusPlus:(BOOL)animated
{
    // Atenção, isto NÃO É um loop infinito, pois as implementações são trocadas em runtime, vide +(void)load;
    [self viewWillAppearPlusPlus:animated];
    
    // Envia o tracking se houver nome para ser enviado
    NSString * viewName = [self viewNameForGA];
    if ( viewName )
    {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:viewName];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
        
        NSLog(@"sendView: %@", viewName);
    }
}

- (NSString *)viewNameForGA
{
    NSString * className = NSStringFromClass([self class]);
    NSString * viewName  = NSLocalizedStringFromTable(className, @"GAViewNames", @"");
    NSString * suffix    = [self viewNameSuffix];
    
    if ( suffix )
    {
        viewName = [NSString stringWithFormat:@"%@ %@", viewName, suffix];
    }
    
    return [viewName isEqualToString:className] ? nil : viewName;
}

- (NSString *)viewNameSuffix
{
    // Override to return suffix
    return nil;
}

@end
