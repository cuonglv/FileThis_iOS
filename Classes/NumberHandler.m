//
//  NumberHandler.m
//  OnMat
//
//  Created by Cuong Le Viet on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NumberHandler.h"

@implementation NumberHandler

+ (NSString*)currencyStringFromDouble:(double)f {
//    NSMutableString *s = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"$%.2f",f]];
//    for (int i = [s length]-6; i > 1; i-=3) {
//        [s insertString:@"," atIndex:i];
//    }
    static NSNumberFormatter *currentcyFormatter = nil;
    if (currentcyFormatter == nil) {
        @synchronized(self) {
            if (currentcyFormatter == nil) {
                currentcyFormatter = [[NSNumberFormatter alloc] init];
                [currentcyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [currentcyFormatter setCurrencyCode:@"USD"];
    }
        }
    }
    return [currentcyFormatter stringFromNumber:[NSNumber numberWithFloat:f]];
}

+ (NSString*)getCountString:(int)count singularNoun:(NSString*)singularNoun pluralNoun:(NSString*)pluralNoun {
    if (count <= 1)
        return [NSString stringWithFormat:@"%i %@",count,singularNoun];
    else
        return [NSString stringWithFormat:@"%i %@",count,pluralNoun];
}
@end
