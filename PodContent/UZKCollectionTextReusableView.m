//
//  UZKCollectionTitleReusableView.m
//  UZKDataSources
//
//  Created by Tiago Furlanetto on 1/10/14.
//  Copyright (c) 2014 Uzaak. All rights reserved.
//

#import "UZKCollectionTextReusableView.h"

@interface UZKCollectionTextReusableView()

@property (nonatomic, strong) IBOutlet UILabel * label;

@end

@implementation UZKCollectionTextReusableView

- (void)setText:(NSString *)text
{
    _text = text;
    self.label.text = text;
}

@end
