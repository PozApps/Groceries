//
//  Item.m
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "Item.h"

@implementation Item

- (id)initWithName:(NSString *)name andWeight:(NSString *)weight andColor:(UIColor *)color {
    self = [super init];
    if (self) {
        self.name = name;
        self.weight = weight;
        self.color = color;
    }
    return self;
}

@end
