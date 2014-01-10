//
//  PKDXWebDSClient.h
//  Pokedex
//
//  Created by Tiago Furlanetto on 9/15/13.
//  Copyright (c) 2013 Tiago Furlanetto. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UZKWebDSClient <NSObject>

- (void)requestPage:(int)page withParameters:(NSDictionary *)parameters successBlock:(void(^)(NSArray * returnedObjects))successBlock;

@end
