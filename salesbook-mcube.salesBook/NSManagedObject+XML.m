//
//  NSManagedObject+XML.m
//  SalesBook
//
//  Created by Matthias Spohn on 27.03.13.
//  Copyright (c) 2013 Siller AG. All rights reserved.
//

#import "NSManagedObject+XML.h"

#import "XMLHelper.h"
#import "XMLDocument.h"
#import "XMLElement.h"
#import "XMLAttribute.h"

#import "SBAttribute+Extensions.h"

@implementation NSManagedObject (XML)

- (NSString *)toXMLforDelete:(BOOL)deleteXML
{
    NSString *payloadType = [self.entity.userInfo valueForKeyPath:@"payloadType"]; //UserInfo 'payloadType' regelt den Payload des XML Files!
    
    if (payloadType.length == 0)
    {
        DDLogWarn(@"Error: Missing 'payloadType' for Class: %@", self.entity.name);
        return nil;
    }
    
    XMLDocument *doc = [XMLHelper xmlHeader];

    XMLElement *rootElement = [doc rootElement];

    if (deleteXML)
    {
        payloadType = [NSString stringWithFormat:@"%@Remove", payloadType];
    }
    
    XMLElement *payload = [XMLElement elementWithName:@"payload"];

    [payload addAttributeNamed:@"type" withValue:payloadType];
    [payload addAttributeNamed:@"version" withValue:@"1.0"];
    [rootElement appendValue:@"payload"];
    [rootElement addChild:payload];

    [payload addChild:[self getXMLElementWithName:payloadType excludeEntityNamed:self.entity.name]];
    
    NSString *prettyXML = [doc prettyXML];
    
    return prettyXML;
}

- (XMLElement *)getXMLElementWithName:(NSString *)name excludeEntityNamed:(NSString *)entity
{
    XMLElement *element = [XMLElement elementWithName:name];
    
    for (NSString *key in self.entity.attributesByName)
    {
        if ([[[(NSAttributeDescription *)[self.entity.attributesByName valueForKey:key] userInfo] valueForKeyPath:@"excludeInXML"] isEqualToString:@"1"]) continue;
        
        [element addChild:[self getXMLNodeWithValue:[self valueForKey:key] andKey:key]];
    }
    
    for (NSString *r in self.entity.relationshipsByName)
    {
        NSRelationshipDescription *rd = [self.entity.relationshipsByName objectForKey:r];

        if ([rd.destinationEntity.name isEqualToString:@"SBAttribute"]) //Attribute werden immer mit Serialisiert!
        {
            XMLElement *attribute = [XMLElement elementWithName:rd.name];

            if (rd.isToMany)
            {
                for (SBAttribute *obj in [[self valueForKey:r] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"theKey" ascending:YES]]])
                {
                    [attribute addChild:[self getXMLNodeFromAttribute:obj]];
                }
            }
            else
            {
                SBAttribute *obj = [self valueForKey:r];
                
                if (obj == nil)
                {
                    continue;
                }
                
                [attribute addChild:[self getXMLNodeFromAttribute:obj]];
            }
            
            [element addChild:attribute];
        }
        else if ([[rd.userInfo valueForKeyPath:@"includeInXML"] isEqualToString:@"1"]) //UserInfo 'includeInXML' Steuert ob das Objekt mit serialisiert wird! (Wichtig!!! Referenzen auf die eigene Entity werden nicht mit serialisiert!)
        {
            if ([rd.destinationEntity.name isEqualToString:entity])
            {
                continue;
            }
            
            if (rd.isToMany)
            {
                NSString *singular = [rd.name substringToIndex:[rd.name length] -1];
                
                XMLElement *knot = [XMLElement elementWithName:rd.name];
                
                for (NSManagedObject *obj in [self valueForKey:r])
                {
                    if ([[rd.destinationEntity.userInfo valueForKey:@"referenceOnly"] isEqualToString:@"1"]) //UserInfo 'referenceOnly' bewirkt, das nur die uniqueID des refenzierten Objekts ausgegeben wird!
                    {
                        [knot addChild:[self getXMLNodeWithValue:[obj valueForKey:@"uniqueID"] andKey:singular]];
                    }
                    else
                    {
                        [knot addChild:[obj getXMLElementWithName:singular excludeEntityNamed:entity]];
                    }
                }
                
                [element addChild:knot];
            }
            else
            {
                NSManagedObject *obj = [self valueForKey:r];
                
                if (obj == nil)
                {
                    [element addChild:[XMLElement elementWithName:r]];
                    continue;
                }
                
                if ([[rd.destinationEntity.userInfo valueForKey:@"referenceOnly"] isEqualToString:@"1"])
                {
                    [element addChild:[self getXMLNodeWithValue:[obj valueForKey:@"uniqueID"] andKey:rd.name]];
                }
                else
                {
                    [element addChild:[obj getXMLElementWithName:rd.name excludeEntityNamed:entity]];
                }
            }
        }
    }
    
    return element;
}

#pragma mark - internal

- (XMLElement *)getXMLNodeWithValue:(id)value andKey:(NSString *)key
{
    XMLElement *nextNode = [XMLElement elementWithName:key];
    [nextNode appendValue:[XMLHelper getXMLValue:value]];
    
    return nextNode;
}

- (XMLElement *)getXMLNodeFromAttribute:(SBAttribute *)attribute
{
    XMLElement *result = [XMLElement elementWithName:attribute.theKey];
    [result addAttribute:[XMLAttribute attributeWithName:@"value" value:[XMLHelper getXMLValue:attribute.theValue]]];
    [result addAttribute:[XMLAttribute attributeWithName:@"language" value:[XMLHelper getXMLValue:attribute.language]]];
    
    return result;
}
    
@end