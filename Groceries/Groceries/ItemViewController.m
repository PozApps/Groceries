//
//  ItemViewController.m
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "ItemViewController.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.item) {
        [self.itemNameLabel setText:self.item.name];
        [self.itemWeightLabel setText:self.item.weight];
        [self.colorView setBackgroundColor:self.item.color];
    }
}

- (IBAction)backToList:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
