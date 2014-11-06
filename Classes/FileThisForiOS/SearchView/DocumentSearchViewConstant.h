//
//  DocumentSearchViewConstant.h
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//
#import "CommonLayout.h"

#ifndef FileThis_DocumentSearchViewConstant_h
#define FileThis_DocumentSearchViewConstant_h

#define kDocumentSearchView_MarginLeft                  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 10.0 : 20.0)
#define kDocumentSearchView_MarginRight                 10.0
#define kDocumentSearchView_SearchByDateViewWidth       320.0
#define kDocumentSearchView_SearchByDateViewHeight      160.0
#define kDocumentSearchView_SearchByHeaderViewHeight    52.0
#define kDocumentSearchView_SearchCabinetViewHeight     350.0
#define kDocumentSearchView_SearchByLabelWidth          100.0

#define kDocumentSearchView_Font                [CommonLayout getFont:FontSizeSmall isBold:NO]
#define kDocumentSearchView_HeaderFont          [UIFont fontWithName:kFontNameHelveticaNeue size:15.0]
#define kDocumentSearchView_TextColor   kTextGrayColor
#define kDocumentSearchView_SearchByDateViewBackColor   [UIColor colorWithRedInt:244 greenInt:243 blueInt:248]


#define kDocumentSearchView_TagCollectionCellIdentifier     @"tagCell"
#define kDocumentSearchView_CollectionCellHeight            30.0
#define kDocumentSearchView_CollectionCellMaxWidth          250.0


@protocol SearchComponentViewDelegate <NSObject>
@optional
- (void)searchComponentView_shouldClose:(id)sender;
@end

#endif
