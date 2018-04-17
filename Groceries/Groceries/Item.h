//
//  Item.h
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Item : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) UIColor *color;

- (id)initWithName:(NSString *)name andWeight:(NSString *)weight andColor:(UIColor *)color;

@end

