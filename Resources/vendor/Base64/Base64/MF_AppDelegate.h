//
//  MF_AppDelegate.h
//  Base64
//
//  Created by Dave Poirier on 12-06-14.
//  Public Domain
//

#import <Cocoa/Cocoa.h>

@interface MF_AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField;

-(IBAction)encode:(id)sender;
-(IBAction)decode:(id)sender;
@end
