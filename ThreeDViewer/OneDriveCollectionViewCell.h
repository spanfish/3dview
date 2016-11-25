//
//  OneDriveCollectionViewCell.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneDriveCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) IBOutlet UIImageView *checkImageView;
@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@end
