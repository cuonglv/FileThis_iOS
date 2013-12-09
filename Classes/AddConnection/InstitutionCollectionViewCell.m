//
//  InstitutionCollectionViewCell.m
//  FileThis
//
//  Created by Drew Wilson on 12/5/12.
//
//
//## Icon sizing
//
//Add Connection
//
//iPhone
//  collection cell size=150x80
//  Institution Collection View Cell=150x80
//      image size=125x50
//
//iPad
//  collection cell size=250x100
//  Institution Collection View Cell=250x100
//      image size=200x80
//


#import "InstitutionCollectionViewCell.h"
#import "FTInstitution.h"
#import "UIKitExtensions.h"
#import "UIImageView+AFNetworking.h"

@interface InstitutionCollectionViewCell()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameView;

@end

@implementation InstitutionCollectionViewCell

-(void)prepareForReuse {
    self.imageView.image = nil;
    self.institution = nil;
}

-(void)dealloc {
    [self cancel];
}

- (void)setInstitution:(FTInstitution *)institution {
    _institution = institution;
    self.nameView.text = institution.name;
    if (institution != nil) {
        [self.imageView setImageWithURL:institution.logoURL placeholderImage:[FTInstitution placeholderImage] cached:YES];
    }
}

- (void)cancel
{
    [self.imageView cancelImageRequestOperation];
}

// For debugging of layout issues
//-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    if (self.institution.institutionId == 86)
//        NSLog(@"view hierarchy=%@", [self recursiveDescription]);
//    [super applyLayoutAttributes:layoutAttributes];
//}
//

@end
