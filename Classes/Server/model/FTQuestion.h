//
//  FTQuestion.h
//  FileThis
//
//  Created by Drew Wilson on 10/26/12.
//
//

#import <Foundation/Foundation.h>

@interface FTQuestion : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *key;
@property (readonly) NSInteger uniqueId;
@property (readonly) NSInteger connectionId;
@property (strong) NSString *answer;
@property (assign) BOOL isNoticeMessage;
@property (nonatomic, strong) NSString *type;

- (id)initWithDictionary:(NSDictionary *) dictionary;
- (void)addInformationWithDictionary:(NSDictionary*)dictionary; //Loc Cao

- (BOOL)isMultipleChoice;
- (BOOL)isReadOnly;
- (BOOL)isCredentials;
- (BOOL)isActionRequired;

- (NSInteger)pickerRowCount;
- (NSString *)pickerTitleForRow:(NSInteger)row;
- (NSString *)pickerValueForRow:(NSInteger)row;

@end
