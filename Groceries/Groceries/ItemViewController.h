//
//  ItemViewController.h
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemWeightLabel;
@property (nonatomic, strong) Item *item;

@end
