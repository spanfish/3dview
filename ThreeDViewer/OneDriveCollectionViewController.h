//
//  OneDriveCollectionViewController.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneDriveSDK/OneDriveSDK.h>

@interface OneDriveCollectionViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSMutableDictionary *items;
@property (strong, nonatomic) NSMutableArray *itemsLookup;
@property (strong, nonatomic) NSMutableDictionary *thumbnails;
@property (strong, nonatomic) NSMutableArray *selectedItems;
@property (strong, nonatomic) ODClient *client;
@property (strong, nonatomic) ODItem *currentItem;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
