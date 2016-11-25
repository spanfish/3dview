//
//  ModelInfoViewController.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/9/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "ModelInfoViewController.h"

@interface ModelInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ModelInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelTouched:(id)sender {
    [self.delegate infoDidFinished];
    [self.view removeFromSuperview];
}

#pragma mark -
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 8;
    } else if(section == 1) {
        return [_model.materialFiles count];
    } else if(section == 2) {
        NSInteger i = 0;
        for (ModelGroup *mg in _model.modelGroup) {
            for (MaterialGroup *materialGroup in mg.materialGroup) {
                if(materialGroup.numOfVertices > 0) {
                    NSString *materialName = materialGroup.name;
                    Material *material = [_model.materialDict objectForKey:materialName];
                    if(material && material.kdName != nil) {
                        i++;
                    }
                }
            }
        }

        return i;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"File name";
                cell.detailTextLabel.text = [_model.path lastPathComponent];
            }
                break;
            case 1: {
                cell.textLabel.text = @"File size";
                NSFileManager *fm = [NSFileManager defaultManager];
                NSDictionary *attribute = [fm attributesOfItemAtPath:_model.path error:nil];
                //NSDate *creationDate = [attribute objectForKey:NSFileCreationDate];
                //NSDate *modificationDate = [attribute objectForKey:NSFileModificationDate];
                NSNumber *fileSize = [attribute objectForKey:NSFileSize];
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ bytes", [f stringFromNumber:fileSize]];
            }
                break;
            case 2: {
                cell.textLabel.text = @"Vertices";
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                cell.detailTextLabel.text = [f stringFromNumber:[NSNumber numberWithUnsignedInteger:_model.numOfVertex]];
            }
                break;
            case 3: {
                cell.textLabel.text = @"Triangles";
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                cell.detailTextLabel.text = [f stringFromNumber:[NSNumber numberWithUnsignedInteger:_model.numOfTriangles]];
            }
                break;
            case 4: {
                cell.textLabel.text = @"Box Min";
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@",
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.minX]],
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.minY]],
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.minZ]]];
            }
                break;
            case 5: {
                cell.textLabel.text = @"Box Max";
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@",
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.maxX]],
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.maxY]],
                                             [f stringFromNumber: [NSNumber numberWithFloat:_model.maxZ]]];
            }
                break;
            case 6: {
                cell.textLabel.text = @"VT";
                cell.detailTextLabel.text = _model.hasVertexCoord ? @"Yes" : @"No";
            }
                break;
            case 7: {
                cell.textLabel.text = @"VN";
                cell.detailTextLabel.text = _model.hasNormal ? @"Yes" : @"No";
            }
                break;
            default:
                break;
        }
    } else if(indexPath.section == 1) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = [_model.materialFiles objectAtIndex:indexPath.row];
    } else if(indexPath.section == 2) {
        int i = -1;
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        for (ModelGroup *mg in _model.modelGroup) {
            for (MaterialGroup *materialGroup in mg.materialGroup) {
                if(materialGroup.numOfVertices > 0) {
                    NSString *materialName = materialGroup.name;
                    Material *material = [_model.materialDict objectForKey:materialName];
                    if(material && material.kdName != nil) {
                        i++;
                        if(i == indexPath.row) {
                            cell.textLabel.text = [material.kdName lastPathComponent];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"OBJ File Info";
    } else if(section == 1) {
        return @"Materials Info";
    } else if(section == 2) {
        return @"Textures Info";
    }
    return nil;
}
@end
