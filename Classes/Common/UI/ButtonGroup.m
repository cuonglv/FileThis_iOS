//
//  ButtonGroup.m
//  TKD
//
//  Created by decuoi on 6/28/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "ButtonGroup.h"

@implementation ButtonGroup
@synthesize selectedButtonIndexes, buttonGroupDelegate, allowMultipleSelection, allowNoneSelection, selectedKeyValueItem;

- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {  //A call G
    return (self = [self initWithPoint:CGPointMake(frame.origin.x,frame.origin.y) equalColumnWidth:frame.size.width/columncount rowHeight:frame.size.height fontSize:fontSize isBold:isBold itemTexts:itemtexts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]);
}

- (id)initWithPoint:(CGPoint)p width:(float)width rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {   //B call G
    return (self = [self initWithPoint:p equalColumnWidth:width/columncount rowHeight:rowHeight fontSize:fontSize isBold:isBold itemTexts:itemtexts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]);
}

- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {  //C call G
    NSArray *texts = [KeyValueItem getValuesOfItems:keyvalueItems];
    if (self=[self initWithPoint:CGPointMake(frame.origin.x,frame.origin.y) equalColumnWidth:frame.size.width/columncount rowHeight:frame.size.height fontSize:fontSize isBold:isBold itemTexts:texts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]) {
        keyValueItems = [keyvalueItems retain];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)p width:(float)width rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {   //D call G
    NSArray *texts = [KeyValueItem getValuesOfItems:keyvalueItems];
    if (self=[self initWithPoint:p equalColumnWidth:width/columncount rowHeight:rowHeight fontSize:fontSize isBold:isBold itemTexts:texts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]) {
        keyValueItems = [keyvalueItems retain];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount columnWidths:(NSArray*)columnWidths allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {  //E call G
    return (self=[self initWithPoint:CGPointMake(frame.origin.x,frame.origin.y) equalColumnWidth:frame.size.width/columncount rowHeight:frame.size.height fontSize:fontSize isBold:isBold itemTexts:itemtexts columnCount:columncount columnWidths:columnWidths allowMultipleSelection:multipleSelection superView:superView]);
}


/* - (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold keyValueItems:(NSArray*)keyvalueItems columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {
    NSArray *texts = [KeyValueItem getValuesOfItems:keyvalueItems];
    if (self=[self initWithPoint:p equalColumnWidth:equalColumnWidth rowHeight:rowHeight fontSize:fontSize isBold:isBold itemTexts:texts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]) {
        keyValueItems = [keyvalueItems retain];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView { //F call G
    return (self = [self initWithPoint:p equalColumnWidth:equalColumnWidth rowHeight:rowHeight fontSize:fontSize isBold:isBold itemTexts:itemtexts columnCount:columncount columnWidths:nil allowMultipleSelection:multipleSelection superView:superView]);
} */

- (id)initWithPoint:(CGPoint)p equalColumnWidth:(float)equalColumnWidth rowHeight:(float)rowHeight fontSize:(FontSize)fontSize isBold:(BOOL)isBold itemTexts:(NSArray*)itemtexts columnCount:(int)columncount columnWidths:(NSArray*)columnWidths allowMultipleSelection:(BOOL)multipleSelection superView:(UIView*)superView {   //G
    
    int itemcount = [itemtexts count];
    float rowcount = (int)ceilf((float)itemcount / (float)columncount);
    int adjustedColumnCount = (int)ceilf((float)itemcount / (float)rowcount);
    
    if (self = [super initWithFrame:CGRectMake(p.x,p.y,adjustedColumnCount*equalColumnWidth,rowcount*rowHeight)]) {
        selectedKeyValueItem = nil;
        keyValueItems = nil;
        buttonGroupDelegate = nil;
        selectedButtonIndexes = [[NSMutableArray alloc] init];
        itemTexts = [itemtexts retain];
        itemCount = itemcount;
        
        rowCount = rowcount;
        columnCount = adjustedColumnCount;
        
        allowMultipleSelection = multipleSelection;
        allowNoneSelection = allowMultipleSelection;
        
        buttons = [[NSMutableArray alloc] init];
        
        buttonLeftImage = [[UIImage imageNamed:@"button_group_bg_left_blank.png"] retain];
        buttonRightImage = [[UIImage imageNamed:@"button_group_bg_right_blank.png"] retain];
        buttonCenterImage = [[UIImage imageNamed:@"button_group_bg_center_blank.png"] retain];
        buttonLeftImage2 = [[UIImage imageNamed:@"button_group_bg_left.png"] retain];
        buttonRightImage2 = [[UIImage imageNamed:@"button_group_bg_right.png"] retain];
        buttonCenterImage2 = [[UIImage imageNamed:@"button_group_bg_center.png"] retain];
        
        int index = 0;
        float x, y = 0;
        for (int i=0; i<rowCount; i++) {
            x = 0;
            for (int j=0; j<columnCount; j++) {
                UIButton *button;
                UIImage *buttonImage;
                if (j==0)
                    buttonImage = buttonLeftImage;
                else if (j == columnCount - 1)
                    buttonImage = buttonRightImage;
                else
                    buttonImage = buttonCenterImage;
                
                float columnWidth;
                if (columnWidths)
                    columnWidth = [[columnWidths objectAtIndex:j] floatValue];
                else
                    columnWidth = equalColumnWidth;
                
                button = [CommonLayout createImageButton:CGRectMake(x, y, columnWidth, rowHeight) fontSize:fontSize isBold:isBold textColor:kButtonGroup_TextColor backgroundImage:buttonImage text:[itemTexts objectAtIndex:index] touchTarget:self touchSelector:@selector(handleButton:) superView:self];
                [buttons addObject:button];
                
                x += columnWidth;
                
                if (++index >= itemCount)
                    break;
            }
            y += rowHeight;
        }
        [superView addSubview:self];
    }
    return self;
}

- (void)dealloc {
    [buttonLeftImage release];
    [buttonRightImage release];
    [buttonCenterImage release];
    [buttonLeftImage2 release];
    [buttonRightImage2 release];
    [buttonCenterImage2 release];
    [selectedButtonIndexes release];
    [keyValueItems release];
    [buttons release];
    [itemTexts release];
    [super dealloc];
}

- (float)autoWidth {
    float totalWidth = 0;
    for (int i = 0, count = [buttons count]; i < count; i++) {
        UIButton *button = [buttons objectAtIndex:i];
        [button setLeft:totalWidth];
        totalWidth += [button autoWidth];
    }
    [self setWidth:totalWidth];
    return totalWidth;
}

#pragma mark - Button
- (void)handleButton:(id)sender {
    UIButton *button = sender;
    int buttonIndex = [buttons indexOfObject:button];
    NSNumber *buttonIndexNumber = [NSNumber numberWithInt:buttonIndex];
    BOOL isButtonSelected = [selectedButtonIndexes containsObject:buttonIndexNumber];
    
    UIButton *buttonNeedToUnselect = nil, *buttonNeedToSelect = nil;
    if (allowMultipleSelection) {
        if (isButtonSelected) {
            if (allowNoneSelection || (!allowNoneSelection && [selectedButtonIndexes count] > 1)) {
                [selectedButtonIndexes removeObject:buttonIndexNumber];
                buttonNeedToUnselect = button;
            }
        } else {    //button is unselected, find suitable position to insert into array
            int position = 0;
            for (int count = [selectedButtonIndexes count]; position < count; position++) {
                NSNumber *currentNumber = [selectedButtonIndexes objectAtIndex:position];
                if (buttonIndex < [currentNumber intValue]) {
                    break; //suitable position
                }
            }
            [selectedButtonIndexes insertObject:buttonIndexNumber atIndex:position];
            buttonNeedToSelect = button;
        }
    } else { //only allow single selection
        if (isButtonSelected && allowNoneSelection) {
            buttonNeedToUnselect = [buttons objectAtIndex:[[selectedButtonIndexes objectAtIndex:0] intValue]];
            [selectedButtonIndexes removeAllObjects];
        } else {
            if ([selectedButtonIndexes count ] > 0) {
                buttonNeedToUnselect = [buttons objectAtIndex:[[selectedButtonIndexes objectAtIndex:0] intValue]];
                [selectedButtonIndexes removeAllObjects];
            }
            [selectedButtonIndexes addObject:buttonIndexNumber];
            buttonNeedToSelect = button;
        }
    }
    
    if (buttonNeedToUnselect) {
        if ([buttonNeedToUnselect backgroundImageForState:UIControlStateNormal] == buttonLeftImage2) {
            [buttonNeedToUnselect setBackgroundImage:buttonLeftImage forState:UIControlStateNormal];
        } else if ([buttonNeedToUnselect backgroundImageForState:UIControlStateNormal] == buttonRightImage2) {
            [buttonNeedToUnselect setBackgroundImage:buttonRightImage forState:UIControlStateNormal];
        } else {
            [buttonNeedToUnselect setBackgroundImage:buttonCenterImage forState:UIControlStateNormal];
        }
        [buttonNeedToUnselect setTitleColor:kButtonGroup_TextColor forState:UIControlStateNormal];
    }
    
    if (buttonNeedToSelect) {
        if ([buttonNeedToSelect backgroundImageForState:UIControlStateNormal] == buttonLeftImage) {
            [buttonNeedToSelect setBackgroundImage:buttonLeftImage2 forState:UIControlStateNormal];
        } else if ([buttonNeedToSelect backgroundImageForState:UIControlStateNormal] == buttonRightImage) {
            [buttonNeedToSelect setBackgroundImage:buttonRightImage2 forState:UIControlStateNormal];
        } else {
            [buttonNeedToSelect setBackgroundImage:buttonCenterImage2 forState:UIControlStateNormal];
        }
       [buttonNeedToSelect setTitleColor:kButtonGroup_SelectedTextColor forState:UIControlStateNormal];
    }
    
    [buttonGroupDelegate changeSelection:self];
}

- (void)selectButton:(int)buttonIndex {
    if (buttonIndex < [buttons count]) {
        [self handleButton:[buttons objectAtIndex:buttonIndex]];
    }
}

- (int)selectedButtonIndex {
    if ([selectedButtonIndexes count] == 0)
        return -1;
    else
        return [[selectedButtonIndexes objectAtIndex:0] intValue];
}

- (UIButton*)selectedButton {
    if ([selectedButtonIndexes count] == 0)
        return nil;
    else
        return [buttons objectAtIndex:[[selectedButtonIndexes objectAtIndex:0] intValue]];
}

- (NSString*)selectedButtonText {
    return [itemTexts objectAtIndex:[[selectedButtonIndexes objectAtIndex:0] intValue]];
}

- (void)setSelectedButtonText:(NSString *)selectedButtonText {
    if ([itemTexts containsObject:selectedButtonText]) {
        [self selectButton:[itemTexts indexOfObject:selectedButtonText]];
    }
}

- (KeyValueItem*)selectedKeyValueItem {
    if ([selectedButtonIndexes count] == 0)
        return nil;
    else
        return [keyValueItems objectAtIndex:[[selectedButtonIndexes objectAtIndex:0] intValue]];
}

- (void)setSelectedKeyValueItem:(KeyValueItem *)val {
    if ([keyValueItems containsObject:val]) {
        [self selectButton:[keyValueItems indexOfObject:val]];
    }
}

- (NSMutableArray*)selectedKeys {
    NSMutableArray *ret = [[[NSMutableArray alloc] initWithCapacity:[buttons count]] autorelease];
    for (NSNumber *indexNumber in selectedButtonIndexes) {
        KeyValueItem *item = [keyValueItems objectAtIndex:[indexNumber intValue]];
        [ret addObject:item.key];
    }
    return ret;
}

- (void)selectKeyValueItem:(KeyValueItem*)item {
    if ([keyValueItems containsObject:item])
        [self selectButton:[keyValueItems indexOfObject:item]];
}

- (void)selectKeyValueItems:(NSArray*)items {
    for (KeyValueItem *item in items) {
        [self selectKeyValueItem:item];
    }
}

- (void)selectKey:(NSString*)key {
    int index = [KeyValueItem indexOfItemWithKey:key inArray:keyValueItems];
    if (index >= 0)
        [self selectButton:index];
}

- (void)selectKeys:(NSArray*)keys {
    for (NSString *key in keys) {
        [self selectKey:key];
    }
}

- (void)setButtonTexts:(NSArray*)texts {
    for (int i = 0, count = [texts count], count2 = [buttons count]; i < count && i < count2; i++) {
        [(UIButton*)[buttons objectAtIndex:i] setTitle:[texts objectAtIndex:i] forState:UIControlStateNormal];
    }
}
@end
