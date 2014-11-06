//
//  LoginViewController.h
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "BaseViewController.h"
#import "LoginCenterView.h"

@interface LoginViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *bgPage;
@property (nonatomic, strong) IBOutlet LoginCenterView *centerView;

@property (nonatomic, strong) UILabel *serverNameLabel;   //Cuong

@end
