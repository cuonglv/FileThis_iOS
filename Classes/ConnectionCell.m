//
//  ConnectionCell.m
//  FileThis
//
//  Created by Cuong Le on 11/18/13.
//
//

#import "ConnectionCell.h"

#import "FTInstitution.h"
#import "QuestionsController.h"
#import "UIImageView+AFNetworking.h"
#import "UIKitExtensions.h"
#import "CommonLayout.h"


@interface ConnectionCell ()

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *refreshButton;
@property (strong, nonatomic) IBOutlet UIButton *resolveButton;
@property (strong, nonatomic) IBOutlet UIImageView *iconImage;
@property (strong, nonatomic) IBOutlet UIButton *errorButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIndicatorImageView;
@end

@implementation ConnectionCell

- (id)initWithTableView:(UITableView*)tableView reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        float width = tableView.frame.size.width;
        float cellHeight = tableView.rowHeight;
        //NSLog(@"ConnectionCell - width %.2f height %.2f",width,cellHeight);
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, width, self.contentView.frame.size.height);
        float labelOffset;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            labelOffset = 12;
        else
            labelOffset = 30;
        
        self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, cellHeight/2 - 21, 90, 42)];
        self.iconImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.iconImage];
        
        self.nameLabel = [CommonLayout createLabel:CGRectMake(98 + labelOffset, 8, width - 138 - labelOffset, 18) font:[UIFont boldSystemFontOfSize:18.0] textColor:[UIColor blackColor] backgroundColor:nil text:@"" superView:self.contentView];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.minimumScaleFactor = 0.2;
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.statusLabel = [CommonLayout createLabel:CGRectMake(98 + labelOffset, 28, width - 138 - labelOffset, cellHeight - 32) font:[UIFont systemFontOfSize:11.0] textColor:[UIColor blackColor] backgroundColor:nil text:@"" superView:self.contentView];
        self.statusLabel.textAlignment = NSTextAlignmentLeft;
        self.statusLabel.numberOfLines = 2;
        self.statusLabel.adjustsFontSizeToFitWidth = YES;
        self.statusLabel.minimumScaleFactor = 0.2;
        self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.refreshButton = [CommonLayout createImageButton:CGRectMake(width - 40, cellHeight/2 - 20, 40, 40) image:[UIImage imageNamed:@"glyphicons_081_refresh.png"] contentMode:UIViewContentModeCenter touchTarget:self touchSelector:@selector(refresh:) superView:self.contentView];
        self.refreshButton.tag = 1;
        self.refreshButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.errorButton = [CommonLayout createImageButton:self.refreshButton.frame image:[UIImage imageNamed:@"glyphicons_196_circle_exclamation_mark.png"] contentMode:UIViewContentModeCenter touchTarget:self touchSelector:@selector(explain:) superView:self.contentView];
        self.errorButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.resolveButton = [CommonLayout createImageButton:self.refreshButton.frame image:[UIImage imageNamed:@"glyphicons_194_circle_question_mark.png"] contentMode:UIViewContentModeCenter touchTarget:self touchSelector:@selector(question:) superView:self.contentView];
        self.resolveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.frame = self.refreshButton.frame;
        self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.activityIndicator];
        
        self.arrowIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width - 30, cellHeight/2 - 20, 20, 40)];
        self.arrowIndicatorImageView.image = [UIImage imageNamed:@"arrow_right_gray_medium.png"];
        self.arrowIndicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.arrowIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.arrowIndicatorImageView];
    }
    return self;
}

-(void)dealloc {
    [self.imageView cancelImageRequestOperation];
}

//- (void)prepareForReuse {
//    [super prepareForReuse];
//    // fix wierd Storyboard problem where button view isn't in cell's content view
//    if ([self.contentView viewWithTag:1] == nil)
//    {
//        UIButton *button = self.refreshButton;
//        [self.refreshButton removeFromSuperview];
//        [self.contentView addSubview:button];
//    }
//    NSAssert(self.refreshButton != nil, @"refresh still good");
//}

- (void)configureAccessoryWithEditing:(BOOL)editing {
    if (self.connection == nil)
        return;
    
    BOOL hideActivityIndicator = YES;
    BOOL hideResolveButton = YES;
    BOOL hideRefreshButton = YES;
    BOOL hideErrorButton = YES;
    
    if (self.connection.isTransitioning) {
        [self.activityIndicator startAnimating];
        hideActivityIndicator = NO;
    }
    else if (self.connection.hasQuestion) {
        if (!editing) {
            hideResolveButton = NO;
        }
    }
    else if (self.connection.hasError) {
        if (!editing) {
            hideErrorButton = NO;
        }
    }
    else {
        if (!editing) {
            if (!self.connection.isDisabled) {
                hideRefreshButton = NO;
            }
        }
    }
    
    if (hideActivityIndicator)
        [self.activityIndicator stopAnimating];
    
    self.activityIndicator.hidden = hideActivityIndicator;
    self.refreshButton.hidden = hideRefreshButton;
    self.resolveButton.hidden = hideResolveButton;
    self.errorButton.hidden = hideErrorButton;
    
    //self.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator; //removed by Cuong
    self.arrowIndicatorImageView.hidden = !editing; //Added by Cuong
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self configureAccessoryWithEditing:editing];
}

- (void)setConnection:(FTConnection *)connection {
    [self setConnection:connection withEditing:NO];
}

-(UIImage *)newImage:(UIImage*)profileImage withBadge:(UIImage *)badge {
    UIGraphicsBeginImageContextWithOptions(profileImage.size, NO, 0.0f);
    CGRect imageRect = CGRectMake(0, 0, profileImage.size.width, profileImage.size.height);
    [profileImage drawInRect:imageRect];
    CGRect badgeRect = CGRectMake(profileImage.size.width - badge.size.width, 0, badge.size.width, badge.size.height);
    [badge drawInRect:badgeRect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void) configureImageViewForConnection:(FTConnection *)connection {
    if (connection.iconURL)
        [self.iconImage setImageWithURL:connection.iconURL placeholderImage:[FTInstitution placeholderImage] cached:YES];
    else
        [self.iconImage setImage:[FTInstitution placeholderImage]];
}

- (void)setConnection:(FTConnection *)connection withEditing:(BOOL)editing {
    if (connection != _connection) {
        _connection = connection;
        
        [self configureImageViewForConnection:connection];
        
    }
    if (![self.nameLabel.text isEqualToString:connection.label])
        self.nameLabel.text = connection.label;
    
    self.statusLabel.text = connection.detailedText;
    CGFloat fontSize = self.statusLabel.font.pointSize;
    BOOL hasIssues = connection.hasError || connection.hasQuestion;
    if (hasIssues) {
        self.statusLabel.font = [UIFont italicSystemFontOfSize:fontSize];
        self.statusLabel.textColor = [UIColor redColor];
    } else {
        self.statusLabel.font = [UIFont systemFontOfSize:fontSize];
        self.statusLabel.textColor = [UIColor blackColor];
    }
    
//    float width = self.contentView.frame.size.width;
//    float cellHeight = self.tableView.rowHeight;
//    self.errorButton.frame = self.resolveButton.frame = self.activityIndicator.frame = self.refreshButton.frame = CGRectMake(width-40, cellHeight/2 - 20, 40, 40);
//    self.arrowIndicatorImageView.frame = CGRectMake(width-30, cellHeight/2 - 20, 20, 40);
//    //self.activityIndicator.autoresizingMask = self.arrowIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    self.contentView.backgroundColor = [UIColor yellowColor];
    
    [self configureAccessoryWithEditing:editing];
}

- (IBAction)question:(UIButton *)sender {
    [self.host performSelector:@selector(askQuestionsForConnectionCell:) withObject:self];
}

- (IBAction)refresh:(id)sender {
    [self.connection refetch];
}

- (IBAction)explain:(id)sender {
    [self.host performSelector:@selector(displayConnectionError:) withObject:self];
}


@end
