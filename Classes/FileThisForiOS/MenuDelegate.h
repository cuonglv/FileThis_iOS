//
//  MenuDelegate.h
//  FileThis
//
//  Created by Cuong Le on 1/25/14.
//
//

#import <Foundation/Foundation.h>

@protocol MenuDelegate <NSObject>
- (void)menu_ShouldOpen:(id)sender;
- (void)menu_ShouldClose:(id)sender;
@end