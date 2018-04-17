//
//  ViewController.m
//  Groceries
//
//  Created by Nadav on 17/04/2018.
//  Copyright © 2018 PozApps. All rights reserved.
//

#import "ViewController.h"
#import "GridItemCell.h"
#import "Item.h"
#import "ItemViewController.h"
#import <SocketRocket/SocketRocket.h>

@interface ViewController () <SRWebSocketDelegate> {
    SRWebSocket *_webSocket;
}
@property (weak, nonatomic) IBOutlet UICollectionView *itemsGridView;
@property (nonatomic) NSMutableArray *itemsArray;
@property (assign) BOOL isGrid;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isGrid = NO;
    
    self.itemsGridView.delegate = self;

    self.itemsArray = [NSMutableArray new];
    
    [self reconnect:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_webSocket close];
    _webSocket = nil;
}


///--------------------------------------
#pragma mark - Actions
///--------------------------------------


- (IBAction)toggleLayouts:(id)sender {
    self.isGrid = !self.isGrid;
    [self.itemsGridView reloadData];
}

- (IBAction)reconnect:(id)sender
{
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://superdo-groceries.herokuapp.com/receive"]];
    _webSocket.delegate = self;
    
    NSLog(@"Opening Connection");
    [_webSocket open];
}

- (void)sendPing:(id)sender;
{
    [_webSocket sendPing:nil];
}

#pragma UICollectionViewDataSource

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
    
    GridItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
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

#pragma UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self.itemsArray objectAtIndex:indexPath.row];
    NSString *selected = item.name;
    NSLog(@"selected = %@",selected);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ItemViewController *itemViewController = [storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    [itemViewController setItem:item];
//    [self.navigationController pushViewController:itemViewController animated:YES];
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    
    [self presentViewController:itemViewController animated:NO completion:nil];
}

#pragma UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isGrid) {
        return CGSizeMake(100, 100);
    } else {
        return CGSizeMake(300, 100);
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
    NSLog(@"Received \"%@\"", message);
    
    NSError *jsonError = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (jsonDictionary && jsonError == nil) {
        Item *item = [[Item alloc] initWithName:[jsonDictionary objectForKey:@"name"]
                                      andWeight:[jsonDictionary objectForKey:@"weight"]
                                       andColor:[self colorFromHexString:([jsonDictionary objectForKey:@"bagColor"])]];
        [self.itemsArray insertObject:item atIndex:0];
        
        //  NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        //  [self.itemsGridView insertItemsAtIndexPaths:indexPathArray];
        [self.itemsGridView reloadData];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed code = %ld, reason = %@",code,reason);
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"WebSocket received pong");
}

#pragma mark - Helper Methods
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
