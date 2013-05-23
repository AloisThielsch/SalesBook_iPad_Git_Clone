//
//  UIImage+ImageWithUIView.h
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (ImageWithUIView)

+ (UIImage *)imageWithUIView:(UIView *)view;
+ (UIImage *)imageWithUIView:(UIView *)view alpha:(float)alpha;

+ (UIImage *)renderImageWithTilesFromArray:(NSArray *)array number:(int)number;

@end