//
//  InstitutionCollectionViewCell.h
//  FileThis
//
//  Created by Drew Wilson on 12/5/12.
//
//

#import <UIKit/UIKit.h>

@class FTInstitution;

@interface InstitutionCollectionViewCell : UICollectionViewCell

@property (readonly) FTInstitution *institution;

- (void)setInstitution:(FTInstitution *)institution;
- (void)cancel;

@end
