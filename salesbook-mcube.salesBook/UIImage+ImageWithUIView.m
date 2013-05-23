//
//  UIImage+ImageWithUIView.m
//

#import "UIImage+ImageWithUIView.h"

@implementation UIImage (ImageWithUIView)
#pragma mark -
#pragma mark TakeScreenShot

+ (UIImage *)imageWithUIView:(UIView *)view
{
//    CGSize imageSize = CGSizeMake(view.bounds.size.width, view.bounds.size.height);
//
//    void *data = malloc(imageSize.width * imageSize.height * 4);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//
//    CGContextRef ctx = CGBitmapContextCreate(data,
//                                             imageSize.width,
//                                             imageSize.height,
//                                             8,
//                                             imageSize.width * 4,
//                                             colorSpace,
//                                             kCGImageAlphaPremultipliedLast);
//    CGColorSpaceRelease(colorSpace);
//
//    [view.layer renderInContext:ctx];
//
//    CGImageRef image = CGBitmapContextCreateImage(ctx);
//
//    UIImage *returnImage = [UIImage imageWithCGImage:image];
//
//    CGImageRelease(image);
//
//    CGContextRelease(ctx);
//
//    free(data);
//    
//    return returnImage;

    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)imageWithUIView:(UIView *)view alpha:(float)alpha
{
    float originalAlpha = view.alpha;
    UIGraphicsBeginImageContext(view.bounds.size);
    view.alpha = alpha;
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    view.alpha = originalAlpha;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)renderImageWithTilesFromArray:(NSArray *)array number:(int)number
{
    static int WIDTH = 10, HEIGHT = 10, SPACE = 4;

    BOOL includeDots = array.count > number;

    int count = includeDots ? number - 1 : array.count;

    int totalWidth = count * WIDTH + (count - 1) * SPACE;

    if (includeDots) totalWidth += SPACE + WIDTH;

    UIGraphicsBeginImageContext(CGSizeMake(totalWidth, HEIGHT));

    CGContextRef context = UIGraphicsGetCurrentContext();

    for (int i = 0; i < count; i++)
    {
        UIImage *image = array[i];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

        [imageView.layer renderInContext:context];

        CGContextTranslateCTM(context, SPACE + WIDTH, 0);
    }

    if (includeDots)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        label.font = [label.font fontWithSize:12];
        label.layer.position = CGPointMake(0, 0);
        label.text = @"+";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];

        [label.layer renderInContext:context];
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

@end