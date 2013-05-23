//
//  HTMLtoPDFViewController.m
//  SalesBook
//
//  Created by Matthias Spohn on 21.04.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "HTMLtoPDFViewController.h"
#import "SAGHelper.h"
#import "PRKGenerator.h"
#import "PRKRenderHtmlOperation.h"
#import "ShoppingCardItem.h"

#import "SBClerk+Extensions.h"
#import "SBDocument+Extensions.h"
#import "SBDocumentPosition+Extensions.h"
#import "SBVariant+Extensions.h"
#import "SBAddress+Extensions.h"
#import "SBCustomer+Extensions.h"
#import "SBMedia+Extensions.h"
#import "SBPrice+Extensions.h"

#import "SBDocumentType+Extensions.h"
#import "NSManagedObject+CustomFields.h"

#import "ShoppingCartOverviewViewController.h"
#import "NSDate+Extensions.h"

#import "SBAssortment+Extensions.h"

@interface HTMLtoPDFViewController ()

@end

@implementation HTMLtoPDFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setDocument:(SBDocument *)document
{
    if (document == nil)
    {
        DDLogError(@"document not set!");
        return;
    }
    
    _document = document;
    [self refresh];
}

- (void)refresh
{
    int pos = 1;
    NSMutableArray * articles = [NSMutableArray array];
    
    NSArray *positions =[_document.positions allObjects];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"referencedVariant.variantNumber" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"calculatedDeliveryDate" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor1, sortDescriptor2, nil];
    NSArray *sortedPositions = [positions sortedArrayUsingDescriptors:sortDescriptors];
    
    for (SBDocumentPosition *position in sortedPositions)
    {
        NSArray *customFields = [position.referencedVariant getVisibleData];
        NSDictionary *assortment = [SBAssortment sizeIndexWithAssortment:position.referencedVariant.assortment andSeason:position.referencedVariant.season];
        
        ShoppingCardItem *sc = [[ShoppingCardItem alloc] init];
        
        sc.pos = pos++;
        //sc.number = position.referencedVariant.variantNumber;
        
        /* * Preise * */
        sc.preis1 = [position.referencedVariant getPriceAsStringForCustomerOrNil:position.document.customer]; //TODO: Der Ausdruck darf keine Preise oder so ermitteln
    
        sc.preis2 = [position.referencedVariant getPrice2AsStringForCustomerOrNil:position.document.customer];
        
        /* * Medien * */
        NSArray *medias = [position.referencedVariant getDownloadedMediaFilesWithImageMediaType:SAGMediaTypeMedium];
        if (!medias.count == 0)
        {
            sc.imagepath = [(SBMedia *)[medias objectAtIndex:0] fullFilename];
        }
        
        /* * Labels für die Artikel * */
        sc.number = [self customField:customFields WithID:@"SBVariant.ColorLevel"];
        sc.ME = [self customField:customFields WithID:@"SBVariant.salesUnitDenotation"];
        sc.Farbe = [self customField:customFields WithID:@"SBVariant.color"];
        sc.Produktlinie = [self customField:customFields WithID:@"SBVariant.Produktlinie"];
        sc.Markenbezeichnung = [self customField:customFields WithID:@"SBVariant.Markenbezeichnung"];
        sc.Obermaterial = [self customField:customFields WithID:@"SBVariant.Obermaterial"];
        sc.Artikeltext1 = [self customField:customFields WithID:@"SBVariant.Artikeltext1"];
        sc.Artikeltext2 = [self customField:customFields WithID:@"SBVariant.Artikeltext2"];
        sc.Projektname = [self customField:customFields WithID:@"SBVariant.Projektname"];
        sc.totalpairs = [NSString stringWithFormat:@"%u", position.amount.intValue * position.referencedVariant.packQuantity.intValue];
        
        /* * Sortiment * */
        NSArray *keys = [assortment allKeys];
        for (NSString *key in keys)
        {
            if ([key isEqual: @"assortment"])
            {
                sc.sortiment = [NSString stringWithFormat:@"%@*%@", [assortment valueForKey:@"season"],[assortment valueForKey:key]]; // Bin mir nicht sicher ob ich "season" korrekt interpetiert habe
            }
            if ([key isEqual: @"sizeIndex"])
            {
                NSArray *sizeIndex = [assortment valueForKey:key];
                NSMutableArray *mysizes = [[NSMutableArray alloc] init];
                NSMutableArray *myquantites = [[NSMutableArray alloc] init];
                
                for (NSDictionary *col in sizeIndex)
                {
                    NSDictionary *qtty = [NSDictionary dictionaryWithObject:[col valueForKey:@"quantity"] forKey:@"quantity"];
                    NSDictionary *size = [NSDictionary dictionaryWithObject:[col valueForKey:@"size"] forKey:@"size"];
                    [myquantites addObject:qtty];
                    [mysizes addObject:size];
                }
                
                /* * Kosmetik um die Tabellen immer auf die gleiche Breite zu bringen (12 ist die max. Anzahl an Spalten in der Tabelle, kann also auch verändert werden) * */
                for (int i=1; i < (12 - [sizeIndex count]); i++)
                {
                    NSDictionary *qtty = [NSDictionary dictionaryWithObject:@"" forKey:@"quantity"];
                    NSDictionary *size = [NSDictionary dictionaryWithObject:@"" forKey:@"size"];
                    [myquantites addObject:qtty];
                    [mysizes addObject:size];
                }
                
                sc.quantites = [NSArray arrayWithArray:myquantites];
                sc.sizes = [NSArray arrayWithArray:mysizes];
            }
        }
        
        [articles addObject:sc];
    }
    
    SBClerk *clerk = [SBClerk MR_findFirst];
    
    NSString *creationdate = [_document.creationDate asLocalizedString];
    NSString *documentHeadline = [SBDocumentType getDenoationWith:_document.documentType.intValue andLangauge:[[SAGSettingsManager sharedManager] itemDisplayLanguage]]; //TODO: Remove Language
    
    /* * Adressen im Kopf auf Seite 1 * */
    defaultValues = @{
                      @"articles"         : articles,
                      @"invoicename"      : [self stringIsEmpty:_document.invoiceAddress.name1],
                      @"invoicestreet"    : [self stringIsEmpty:_document.invoiceAddress.street],
                      @"invoicezip"       : [self stringIsEmpty:_document.invoiceAddress.postalCode],
                      @"invoiceort"       : [self stringIsEmpty:_document.invoiceAddress.city],
                      @"invoicecountry"   : [self stringIsEmpty:_document.invoiceAddress.country],
                      
                      @"deliveryname"     : [self stringIsEmpty:_document.deliveryAddress.name1],
                      @"deliverystreet"   : [self stringIsEmpty:_document.deliveryAddress.street],
                      @"deliveryzip"      : [self stringIsEmpty:_document.deliveryAddress.postalCode],
                      @"deliveryort"      : [self stringIsEmpty:_document.deliveryAddress.city],
                      @"deliverycountry"  : [self stringIsEmpty:_document.deliveryAddress.country],
                      
                      @"clerkname"        : [self stringIsEmpty:clerk.clerkDenotaion],
                      @"clerkstreet"      : [self stringIsEmpty:clerk.address.street],
                      @"clerkzip"         : [self stringIsEmpty:clerk.address.postalCode],
                      @"clerkcity"        : [self stringIsEmpty:clerk.address.city],
                      @"clerkphone"       : [self stringIsEmpty:clerk.address.phone],
                      @"clerkfax"         : [self stringIsEmpty:clerk.address.fax],
                      @"clerkmobile"      : [self stringIsEmpty:clerk.address.mobile],
                      @"clerkemail"       : [self stringIsEmpty:clerk.mailAddress],
                      
                      @"customernumber"   : [self stringIsEmpty:_document.customerNumber],
                      @"documentnumber"   : [self stringIsEmpty:_document.documentNumber],
                      @"externalnumber"   : [self stringIsEmpty:_document.externalReference],
                      @"referencenumber"  : [self stringIsEmpty:_document.referenceNumber],
                      @"creationdate"     : [self stringIsEmpty:creationdate],
                      @"documentname"     : [self stringIsEmpty:documentHeadline]
                      
                      };
    
    NSError *error;
    
    NSString *templateName = @"wortmann"; //TODO: Replace
    
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"mustache"];
    
    /* * HTML Template aufrufen und befüllen * */
    [[PRKGenerator sharedGenerator] createReportWithName:templateName
                                       templateURLString:templatePath
                                          itemsFirstPage:6
                                            itemsPerPage:8
                                              totalItems:articles.count
                                         pageOrientation:PRKPortraitPage
                                              dataSource:self
                                                delegate:self
                                                   error:&error];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* * Berechnung des Seiteitenumbruchs * */
- (id)reportsGenerator:(PRKGenerator *)generator
         dataForReport:(NSString *)reportName
               withTag:(NSString *)tagName
               forPage:(NSUInteger)pageNumber
{
    
    if ([tagName isEqualToString:@"articles"])
    {
        int totalItems     = [[PRKGenerator sharedGenerator] totalItems];
        int itemsPerPage   = [[PRKGenerator sharedGenerator] itemsPerPage];
        int itemsFirstPage = [[PRKGenerator sharedGenerator] itemsFirstPage];
        int processedItems = ((pageNumber - 1) * itemsPerPage) + itemsFirstPage; // auf die 1. Seite passen nur 6 Items!
        
        if (processedItems == itemsFirstPage)
        {
            if (totalItems > itemsFirstPage)
            {
                // Die erste Seite kann i.d.R. nicht soviele Items als die Folgeseiten
                return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange(0, itemsFirstPage)];
            }
            
            // alle unter 1 bis max. Anzahl für 1. Seite
            return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange(0, totalItems)];
        }
        
        
        if ((totalItems - processedItems) < 0)
        {
            // alle haben gepasst fertig!
            int start = (pageNumber - 1) * itemsPerPage - (itemsPerPage - itemsFirstPage);
            int items = (totalItems - processedItems + itemsFirstPage + (itemsPerPage - itemsFirstPage));
            
            return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange(start, items)];
        }
        else if ((totalItems - processedItems) >= itemsPerPage)
        {
            // ganze Seite füllen
            return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange((pageNumber - 1) * itemsPerPage, itemsPerPage)];
        }
        else if ((totalItems - processedItems) < itemsPerPage)
        {
            int start = (pageNumber - 1) * itemsPerPage - (itemsPerPage - itemsFirstPage);
            return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange(start, itemsPerPage)];
        }
        else
        {
            // nichts mehr anfügen!
            return [[defaultValues valueForKey:tagName] subarrayWithRange:NSMakeRange(0, 0)];
        }
    }
    return [defaultValues valueForKey:tagName];
}

/* * Anzeigen der Daten im Webview * */
- (void)reportsGenerator:(PRKGenerator *)generator didFinishRenderingWithData:(NSData *)data
{
    _pdfData = data;
    
    [_webview loadData:_pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}

/* * Hilfsfunktion damit nicht nil übergeben wird * */
- (NSString *)stringIsEmpty:(NSString *) aString
{
    if ((NSNull *) aString == [NSNull null] || (aString == nil))
    {
        return @"";
    }
    
    return aString;
}

- (IBAction)close:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)print:(UIBarButtonItem *)sender
{
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
	
    if (printController && [UIPrintInteractionController canPrintData:_pdfData]) {
		
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputGeneral;
        printInfo.duplex = UIPrintInfoDuplexLongEdge;
        printController.printInfo = printInfo;
        printController.showsPageRange = NO;
        printController.printingItem = _pdfData;
		
        [printController presentFromBarButtonItem:sender animated:YES completionHandler:nil];
    }
}

- (NSString *)customField:(NSArray *)customFields WithID:(NSString *)uniqueID
{
    NSDictionary *customField = [[customFields filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uniqueID == %@", uniqueID]] lastObject];
    return customField[@"value"];
}

@end
