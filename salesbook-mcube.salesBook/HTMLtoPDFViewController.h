//
//  HTMLtoPDFViewController.h
//  SalesBook
//
//  Created by Matthias Spohn on 21.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRKGeneratorDataSource.h"
#import "PRKGeneratorDelegate.h"

@class SBDocument;

@interface HTMLtoPDFViewController : UIViewController <PRKGeneratorDataSource, PRKGeneratorDelegate>
{
    NSDictionary * defaultValues;
}

@property (nonatomic, weak) IBOutlet UIWebView *webview;
@property (nonatomic, weak) SBDocument *document;

@property (nonatomic, weak) NSData *pdfData;

- (IBAction)close:(UIBarButtonItem *)sender;
- (IBAction)print:(UIBarButtonItem *)sender;

@end