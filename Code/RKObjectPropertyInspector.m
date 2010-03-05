//
//  RKObjectPropertyInspector.m
//  RestKit
//
//  Created by Blake Watters on 3/4/10.
//  Copyright 2010 Two Toasters. All rights reserved.
//

#import <objc/message.h>

#import "RKObjectPropertyInspector.h"

@implementation RKObjectPropertyInspector

- (NSString*)propertyTypeFromAttributeString:(NSString*)attributeString {
	NSString *type = [NSString string];
	NSScanner *typeScanner = [NSScanner scannerWithString:attributeString];
	[typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"@"] intoString:NULL];
	
	// we are not dealing with an object
	if([typeScanner isAtEnd]) {
		return @"NULL";
	}
	[typeScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"@"] intoString:NULL];
	// this gets the actual object type
	[typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""] intoString:&type];
	return type;
}

- (NSDictionary *)propertyNamesAndTypesForClass:(Class)class {
	NSMutableDictionary *propertyNames = [NSMutableDictionary dictionary];
	
	//include superclass properties
	Class currentClass = class;
	while (currentClass != nil) {
		// Get the raw list of properties
		unsigned int outCount;
		objc_property_t *propList = class_copyPropertyList(currentClass, &outCount);
		
		// Collect the property names
		int i;
		NSString *propName;
		for (i = 0; i < outCount; i++) {
			// TODO: Add support for custom getter and setter methods
			// property_getAttributes() returns everything we need to implement this...
			// See: http://developer.apple.com/mac/library/DOCUMENTATION/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW5
			objc_property_t* prop = propList + i;
			NSString* attributeString = [NSString stringWithCString:property_getAttributes(*prop) encoding:NSUTF8StringEncoding];			
			propName = [NSString stringWithCString:property_getName(*prop) encoding:NSUTF8StringEncoding];
			
			if (![propName isEqualToString:@"_mapkit_hasPanoramaID"]) {
				const char* className = [[self propertyTypeFromAttributeString:attributeString] cStringUsingEncoding:NSUTF8StringEncoding];
				Class class = objc_getClass(className);
				[propertyNames setObject:class forKey:propName];
			}
		}
		
		free(propList);
		currentClass = [currentClass superclass];
	}
	return propertyNames;
}

@end