//
//  DocumentSearchViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/18/13.
//
//

#import <UIKit/UIKit.h>
#import "TagDataManager.h"
#import "NSString+Custom.h"
#import "SearchResultDocumentListViewController.h"
#import "FTSession.h"
#import "DocumentSearchCriteriaManager.h"
#import "DocumentRecentSearchView.h"
#import "DocumentSearchTextPopup.h"
#import "CommonDataManager.h"
#import "EventManager.h"
#import "CommonVar.h"
#import "MyDetailViewController.h"
#import "CommonLayout.h"
#import "TagCollectionCell.h"
#import "LabelCollectionReusableView.h"
#import "SelectTagsView.h"
#import "SelectCabinetView.h"
#import "SearchByDateView.h"
#import "SearchCabinetAccountView.h"
#import "SearchTagsView.h"
#import "DocumentSearchCriteriaView.h"
#import "EventProtocol.h"

@interface DocumentSearchViewController : MyDetailViewController <UITextFieldDelegate, EventProtocol, SearchByDateViewDelegate, SearchCabinetAccountViewDelegate, SearchTagsViewDelegate, DocumentSearchCriteriaViewDelegate, DocumentRecentSearchViewDelegate, DocumentSearchTextPopupDelegate, SearchComponentViewDelegate>

@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) BorderView *leftPanelView;
@property (nonatomic, strong) SearchByDateView *searchByDateView;
@property (nonatomic, strong) SearchCabinetAccountView *searchCabinetAccountView;
@property (nonatomic, strong) SearchTagsView *searchTagsView;
@property (nonatomic, strong) DocumentSearchCriteriaView *searchCriteriaView;
@property (nonatomic, strong) DocumentRecentSearchView *documentRecentSearchView;
@property (nonatomic, strong) DocumentSearchTextPopup *documentSearchTextPopup;
@property (nonatomic, strong) UIView *darkenOverlayView;

@end
