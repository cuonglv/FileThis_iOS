//
//  ButtonGroup.h
//  TKD
//
//  Created by decuoi on 6/28/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyValueItem.h"
#import "CommonLayout.h"

#define kButtonGroup_TextColor          kTextOrangeColor
#define kButtonGroup_SelectedTextColor  [UIColor whiteColor]

@protocol ButtonGroupDelegate <NSObject>
- (void)changeSelection:(id)buttonGroup;
@end

@interface ButtonGroup : UIView {
    NSArray *keyValueItems;
    NSArray *itemTexts;
    NSMutableArray *selectedButtonIndexes;
    int itemCount, rowCount, columnCount;
    BOOL allowMultipleSelection, allowNoneSelection;
    
    NSMutableArray *buttons;
    UIImage *buttonLeftImage, *buttonCenterImage, *buttonRightImage;
    UIImage *buttonLeftImage2, *buttonCenterImage2, *buttonRightImage2;
    
    id<ButtonGroupDelegate> buttonGroupDelegate;
    
    KeyValueItem *selectedKeyValueItem;
}
@property (nonatomic, retain) NSMutableArray *selectedButtonIndexes;
@property (atomic, assign) BOOL allowMultipleSelection, allowNoneSelection;
@property (nonatomic, assign) id<ButtonGroupDelegate> buttonGroupDelegate;
@property (nonatomic, retain) KeyValueItem *selectedKeyValueItem;
@property (nonatomic, retain) NSString *selectedButtonText;


- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView;  //A call G

- (id)initWithPoint:(CGPoint)p width:(float)width rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView;   //B call G

- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView;  //C call G

- (id)initWithPoint:(CGPoint)p width:(float)width rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView; //D call G

- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount columnWidths:(NSArray*)columnWidths allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView;  //E call G

//- (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView; //F call G

//- (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView;

- (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount columnWidths:(NSArray*)columnWidths allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView; //G

- (void)selectButton:(int)buttonIndex;
- (int)selectedButtonIndex;
- (UIButton*)selectedButton;
- (NSMutableArray*)selectedKeys;
- (void)selectKeyValueItem:(KeyValueItem*)item;
- (void)selectKeyValueItems:(NSArray*)items;
- (void)selectKey:(NSString*)key;
- (void)selectKeys:(NSArray*)keys;
- (void)setButtonTexts:(NSArray*)texts;
@end
