//
//  NumberHandler.h
//  OnMat
//
//  Created by Cuong Le Viet on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NumberHandler : NSObject

+ (NSString*)currencyStringFromDouble:(double)f;
+ (NSString*)getCountString:(int)count singularNoun:(NSString*)singularNoun pluralNoun:(NSString*)pluralNoun;
@end
