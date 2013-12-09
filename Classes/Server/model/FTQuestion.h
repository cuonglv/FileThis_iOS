//
//  FTQuestion.h
//  FileThis
//
//  Created by Drew Wilson on 10/26/12.
//
//

#import <Foundation/Foundation.h>

@interface FTQuestion : NSObject

@property (readonly) NSString *label;
@property (readonly) NSString *key;
@property (readonly) NSInteger uniqueId;
@property (readonly) NSInteger connectionId;
@property (strong) NSString *answer;

- (id)initWithDictionary:(NSDictionary *) dictionary;
- (BOOL)isMultipleChoice;
- (BOOL)isReadOnly;
- (BOOL)isCredentials;

- (NSInteger)pickerRowCount;
- (NSString *)pickerTitleForRow:(NSInteger)row;
- (NSString *)pickerValueForRow:(NSInteger)row;

@end
