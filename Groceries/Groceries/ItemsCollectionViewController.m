//
//  ViewController.m
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "ItemsCollectionViewController.h"
#import "ItemCell.h"
#import "Item.h"
#import "ItemViewController.h"
#import <SocketRocket/SocketRocket.h>
#import "TransitionAnimator.h"

@interface ItemsCollectionViewController () <SRWebSocketDelegate, UIViewControllerTransitioningDelegate> {
    SRWebSocket *_webSocket;
}

@property (weak, nonatomic) IBOutlet UICollectionView *itemsCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleButton;


@property (nonatomic) NSMutableArray *itemsArray;
@property BOOL isGrid;

@property (nonatomic) TransitionAnimator *transition;
@property (nonatomic) NSIndexPath *selectedIndexPath;
@property BOOL isPresentingItem;

@end

@implementation ItemsCollectionViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isGrid = NO;
    self.isPresentingItem = NO;
    self.itemsCollectionView.dataSource = self;
    self.itemsCollectionView.delegate = self;
    self.itemsArray = [NSMutableArray new];
    
    self.transition = [TransitionAnimator new];
    // Preparing the dismissal block which will run when returning from the ItemViewController
    __weak ItemsCollectionViewController *weakSelf = self;
    self.transition.dismissCompletion = ^{
        ItemCell *cell = (ItemCell *)[weakSelf.itemsCollectionView cellForItemAtIndexPath:weakSelf.selectedIndexPath];
        cell.colorView.hidden = NO;
        weakSelf.isPresentingItem = NO;
    };
    
    // Start receiving items from the web socket
    [self initWebSocket];
    [self connect];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)toggleLayouts:(id)sender {
    self.isGrid = !self.isGrid;
    if (self.isGrid) {
        self.toggleButton.title = @"List";
    } else {
        self.toggleButton.title = @"Grid";
    }
    [self.itemsCollectionView reloadData];
}

#pragma mark - WebSocket

- (void)initWebSocket {
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://superdo-groceries.herokuapp.com/receive"]];
    _webSocket.delegate = self;
}

- (void)connect {
    NSLog(@"Opening Connection");
    [_webSocket open];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier;
    if (self.isGrid) {
        cellIdentifier = @"GridCell";
    } else {
        cellIdentifier = @"ListCell";
    }
    
    ItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.itemsArray objectAtIndex:indexPath.row];
    
    [cell.itemNameLabel setText:item.name];
    [cell.itemWeightLabel setText:item.weight];
    [cell.colorView setBackgroundColor:item.color];
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    switch kind {
//    case UICollectionElementKindSectionHeader: {
//
//        break;
//    }
//    }
//}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ItemViewController *itemViewController = [storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    Item *item = [self.itemsArray objectAtIndex:indexPath.row];
    [itemViewController setItem:item];
    [itemViewController setTransitioningDelegate:self];
    
    self.selectedIndexPath = indexPath;
    self.isPresentingItem = YES;
    [self presentViewController:itemViewController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isGrid) {
        return CGSizeMake(100, 100);
    } else {
        return CGSizeMake(collectionView.frame.size.width, 100);
    }
    
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    [self addItemToCollection: [self getItemFromMessageData:message]];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed code = %ld, reason = %@",code,reason);
    _webSocket = nil;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    // We want to animated the color view itself and not the entire cell
    // We need to find the frame of the color view in relation to its superview (the cell) the collection view and the topmost view
    ItemCell *cell = (ItemCell *)[self.itemsCollectionView cellForItemAtIndexPath:self.selectedIndexPath];
    CGRect colorViewFrameInCell = [cell convertRect:cell.colorView.frame toView:self.itemsCollectionView];
    CGRect cellFrameInSuperview = [self.itemsCollectionView convertRect:colorViewFrameInCell toView:[self.itemsCollectionView superview]];
    self.transition.originFrame = cellFrameInSuperview;
    
    self.transition.presenting = YES;
    cell.colorView.hidden = YES;
    
    return self.transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transition.presenting = NO;
    return self.transition;
}

#pragma mark - Handle New Items
- (Item *)getItemFromMessageData:(NSString *)message {
    NSError *jsonError = nil;
    Item *item = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (jsonDictionary && jsonError == nil) {
        item = [[Item alloc] initWithName:[jsonDictionary objectForKey:@"name"]
                                   weight:[jsonDictionary objectForKey:@"weight"]
                                    color:[self colorFromHexString:([jsonDictionary objectForKey:@"bagColor"])]];
    }
    return item;
}

- (void)addItemToCollection:(Item *)item {
    if (item) {
        [self.itemsArray insertObject:item atIndex:0];
        
        //  NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        //  [self.itemsGridView insertItemsAtIndexPaths:indexPathArray];
        
        // Reload the collectionView only if we are not presenting the item view
        if (!self.isPresentingItem) {
            [self.itemsCollectionView reloadData];
        }
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
