//
//  ImageUtils.m
//  ThreeDViewer
//
//  Created by xiangwei wang on 10/8/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils

+(UIImage*) drawText:(NSString*) text atBottomInImage:(UIImage*)  image
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width,image.size.height)];
    CGRect rect = CGRectMake(55, image.size.height - 40, image.size.width, image.size.height);
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName,
                                [UIColor blueColor], NSForegroundColorAttributeName,
                                [NSNumber numberWithBool:TRUE], NSUnderlineStyleAttributeName,
                                style, NSParagraphStyleAttributeName, nil];
    
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:dictionary];
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    [logoImage drawAtPoint:CGPointMake(10, image.size.height - 50)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
