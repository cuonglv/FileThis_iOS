//
//  OrderedDictionary.m
//  OrderedDictionary
//
//  Created by Matt Gallagher on 19/12/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSArray.h>
#import "OrderedDictionary.h"

NSString *DescriptionForObject(NSObject *object, id locale, NSUInteger indent)
{
	NSString *objectString;
	if ([object isKindOfClass:[NSString class]])
	{
		objectString = (NSString *)object;
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:indent:)])
	{
		objectString = [(NSDictionary *)object descriptionWithLocale:locale indent:indent];
	}
	else if ([object respondsToSelector:@selector(descriptionWithLocale:)])
	{
		objectString = [(NSSet *)object descriptionWithLocale:locale];
	}
	else
	{
		objectString = [object description];
	}
	return objectString;
}

@implementation OrderedDictionary

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self != nil)
	{
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
		array = [[NSMutableArray alloc] initWithCapacity:capacity];
	}
	return self;
}

+ (OrderedDictionary *)orderedDictionaryByKeyWithDictionary:(NSDictionary *)dictionary {
    NSArray *sortedKeys = [[dictionary allKeys] sortedArrayWithOptions:kNilOptions usingComparator:^(id s1, id s2) { return [s1 compare:s2]; }];
    OrderedDictionary *od = [[OrderedDictionary alloc] initWithCapacity:[sortedKeys count]];
    int i = 0;
    for (NSString *key in sortedKeys) {
        [od insertObject:dictionary[key] forKey:key atIndex:i];
        i++;
    }
    return od;
}


- (id)copy
{
	return [self mutableCopy];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	if (!dictionary[aKey])
	{
		[array addObject:aKey];
	}
	dictionary[aKey] = anObject;
}

- (void)removeObjectForKey:(id)aKey
{
	[dictionary removeObjectForKey:aKey];
	[array removeObject:aKey];
}

- (void)removeObjectAtIndex:(NSUInteger)anIndex {
    [self removeObjectForKey:[self keyAtIndex:anIndex]];
}

- (NSUInteger)count
{
	return [dictionary count];
}

- (id)objectForKey:(id)aKey
{
	return dictionary[aKey];
}

- (NSEnumerator *)keyEnumerator
{
	return [array objectEnumerator];
}

- (NSEnumerator *)reverseKeyEnumerator
{
	return [array reverseObjectEnumerator];
}

- (void)insertObject:(id)anObject forKey:(id)aKey atIndex:(NSUInteger)anIndex
{
	if (dictionary[aKey])
	{
		[self removeObjectForKey:aKey];
	}
	[array insertObject:aKey atIndex:anIndex];
	dictionary[aKey] = anObject;
}

- (id)objectAtIndex:(NSUInteger)anIndex {
    return self[[self keyAtIndex:anIndex]];
}

- (id)keyAtIndex:(NSUInteger)anIndex
{
	return array[anIndex];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
	NSMutableString *indentString = [NSMutableString string];
	NSUInteger i, count = level;
	for (i = 0; i < count; i++)
	{
		[indentString appendFormat:@"    "];
	}
	
	NSMutableString *description = [NSMutableString string];
	[description appendFormat:@"%@{\n", indentString];
	for (NSObject *key in self)
	{
		[description appendFormat:@"%@    %@ = %@;\n",
			indentString,
			DescriptionForObject(key, locale, level),
			DescriptionForObject(self[key], locale, level)];
	}
	[description appendFormat:@"%@}\n", indentString];
	return description;
}

@end
