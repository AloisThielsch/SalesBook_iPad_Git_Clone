/* Copyright 2012 Antonio Scandurra
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. */

#import "PRKGenerator.h"
#import "PRKRenderHtmlOperation.h"
#import "GRMustache.h"
#import "PRKPageRenderer.h"
#import "PRKFakeRenderer.h"

@implementation PRKGenerator

// Static fields
static PRKGenerator * instance = nil;
static NSArray * reportDefaultTags = nil;

+ (PRKGenerator *)sharedGenerator
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[PRKGenerator alloc] init];
            
            
            reportDefaultTags = @[ @"documentHeader", @"pageHeader", @"pageContent", @"pageFooter", @"pageNumber" ];
        }
        
        return instance;
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {        
        // Initialize rendering queue
        self.renderingQueue = [[NSOperationQueue alloc] init];
        self.renderingQueue.name = @"Rendering Queue";
        self.renderingQueue.maxConcurrentOperationCount = 1;
        
        renderedTags = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)createReportWithName:(NSString *)reportName
           templateURLString:(NSString *)templatePath
              itemsFirstPage:(NSUInteger)itemsFirstPage
                itemsPerPage:(NSUInteger)itemsPerPage
                  totalItems:(NSUInteger)totalItems
             pageOrientation:(PRKPageOrientation)orientation
                  dataSource: (id<PRKGeneratorDataSource>)dataSource
                    delegate: (id<PRKGeneratorDelegate>)delegate
                       error:(NSError *__autoreleasing *)error;
{
    // TODO: replace and add report processing to queue
    if (self.renderingQueue.operationCount > 0)
        return;
    
    self.dataSource = dataSource;
    self.delegate = delegate;
    self.totalItems = totalItems;
    self.itemsFirstPage = itemsFirstPage;
    self.itemsPerPage = itemsPerPage;

    currentReportData = [NSMutableData data];
    GRMustacheTemplate * template = [GRMustacheTemplate templateFromContentsOfFile:templatePath error:error];
    if (*error)
        return;
    
    if (orientation == PRKPortraitPage)
        UIGraphicsBeginPDFContextToData(currentReportData, CGRectMake(0, 0, 595.28, 841.89), nil);
    else
        UIGraphicsBeginPDFContextToData(currentReportData, CGRectMake(0, 0, 841.89, 595.28), nil);
    
    int pagesCount = 1;
    
    if ((totalItems / itemsFirstPage) > 0)
    {
        pagesCount = 2 + (totalItems - itemsFirstPage) / itemsPerPage;
    }
    
    for (int i = 1; i <= pagesCount; i++)
    {
        [renderedTags removeAllObjects];
        currentReportPage = i;
        
        if (currentReportPage > 1)
        {
            currentReportItemsPerPage = itemsPerPage;
        }
        else
        {
            currentReportItemsPerPage = itemsFirstPage;
        }
        
        // PRKGenerator is key-value "get" compliant (as GRMustache needs), so we could use self
        NSString * renderedHtml = [template renderObject:self error:error];        
        NSMutableString * wellFormedHeader = [NSMutableString stringWithString:renderedHtml];
        NSMutableString * wellFormedContent = [NSMutableString stringWithString:renderedHtml];
        NSMutableString * wellFormedFooter = [NSMutableString stringWithString:renderedHtml];
        
        
        // Trim content and footer to get header
        [wellFormedHeader replaceOccurrencesOfString:[renderedTags objectForKey:@"pageContent"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedHeader.length)];
        [wellFormedHeader replaceOccurrencesOfString:[renderedTags objectForKey:@"pageFooter"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedHeader.length)];
        
        // Trim header and footer to get content
        [wellFormedContent replaceOccurrencesOfString:[renderedTags objectForKey:@"documentHeader"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedContent.length)];
        [wellFormedContent replaceOccurrencesOfString:[renderedTags objectForKey:@"pageHeader"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedContent.length)];
        [wellFormedContent replaceOccurrencesOfString:[renderedTags objectForKey:@"pageFooter"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedContent.length)];
        
        // Trim content and header to get footer
        [wellFormedFooter replaceOccurrencesOfString:[renderedTags objectForKey:@"documentHeader"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedFooter.length)];
        [wellFormedFooter replaceOccurrencesOfString:[renderedTags objectForKey:@"pageHeader"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedFooter.length)];
        [wellFormedFooter replaceOccurrencesOfString:[renderedTags objectForKey:@"pageContent"] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, wellFormedFooter.length)];
        
        PRKRenderHtmlOperation * headerOperation = [[PRKRenderHtmlOperation alloc] initWithHtmlContent:wellFormedHeader andSectionType:PRKSectionTypeHeader];
        headerOperation.delegate = self;
        PRKRenderHtmlOperation * contentOperation = [[PRKRenderHtmlOperation alloc] initWithHtmlContent:wellFormedContent andSectionType:PRKSectionTypeContent];
        contentOperation.delegate = self;
        PRKRenderHtmlOperation * footerOperation = [[PRKRenderHtmlOperation alloc] initWithHtmlContent:wellFormedFooter andSectionType:PRKSectionTypeFooter];
        footerOperation.delegate = self;
        
        NSInvocationOperation * renderToPdf = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(renderPage) object:[NSNumber numberWithInteger:i]];
        
        [self.renderingQueue addOperations:@[headerOperation,
                                             contentOperation,
                                             footerOperation,
                                             renderToPdf] waitUntilFinished:NO];

    }
    
    [self.renderingQueue addOperationWithBlock:^{
        // Invoke on main thread, otherwise it won't work!
        [self performSelectorOnMainThread:@selector(closePdfContext) withObject:nil waitUntilDone:YES];
    }];
}

- (id)valueForKey:(NSString *)key
{
    id<PRKGeneratorDataSource> source = [reportDefaultTags containsObject:key] ? self : self.dataSource;
    id data = [source reportsGenerator:self dataForReport:currentReportName withTag:key forPage: currentReportPage];

    
    return data;
}

- (id)reportsGenerator:(PRKGenerator *)generator dataForReport:(NSString *)reportName withTag:(NSString *)tagName forPage:(NSUInteger)pageNumber
{
        
    return [GRMustache renderingObjectWithBlock:^NSString *(GRMustacheTag *tag, GRMustacheContext *context, BOOL *HTMLSafe, NSError *__autoreleasing *error)
    {
        NSString * renderedTag;
        if (pageNumber > 1 && [tagName isEqualToString:@"documentHeader"])
        {
            renderedTag =  @"";
        }
        else if ([tagName isEqualToString:@"pageNumber"])
        {
            renderedTag = [NSString stringWithFormat:@"%d", pageNumber];
        }
        else
            renderedTag = [tag renderContentWithContext:context HTMLSafe:HTMLSafe error:error];
        
        [renderedTags setObject:renderedTag forKey:tagName];
            
        return renderedTag;
    }];
}

- (void)didFinishLoadingSection:(PRKSectionType)sectionType withPrintFormatter:(UIPrintFormatter *)formatter
{
    if (sectionType == PRKSectionTypeHeader)
        headerFormatter = formatter;
    else if (sectionType == PRKSectionTypeContent)
        contentFormatter = formatter;
    else if (sectionType == PRKSectionTypeFooter)
        footerFormatter = formatter;
    else
        [NSException raise:@"Invalid Section Type" format:@"Section Type: %d is invalid", sectionType];
}

- (void)renderPage
{
    // Invoke this operation on UI Thread, otherwise it won't work!
    [self performSelectorOnMainThread:@selector(internalRenderPage) withObject:nil waitUntilDone:YES];
}

- (void)internalRenderPage
{
    PRKFakeRenderer * headerFakeRenderer = [[PRKFakeRenderer alloc] init];
    [headerFakeRenderer addPrintFormatter:headerFormatter startingAtPageAtIndex:0];
    PRKFakeRenderer * footerFakeRenderer = [[PRKFakeRenderer alloc] init];
    [footerFakeRenderer addPrintFormatter:footerFormatter startingAtPageAtIndex:0];
    
    int headerHeight = [headerFakeRenderer contentHeight] * .7;
    int footerHeight = [footerFakeRenderer contentHeight] * .7;
    
    PRKPageRenderer * pageRenderer = [[PRKPageRenderer alloc] initWithHeaderFormatter:headerFormatter headerHeight:headerHeight andContentFormatter:contentFormatter andFooterFormatter:footerFormatter footerHeight:footerHeight];
    [pageRenderer addPagesToPdfContext];
}

- (void)closePdfContext
{    
    UIGraphicsEndPDFContext();
    [self.delegate reportsGenerator:self didFinishRenderingWithData:currentReportData];
    currentReportData = nil;
}

@end
