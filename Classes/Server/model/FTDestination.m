//
//  FTDestination.m
//  FileThis
//
//  Created by Drew Wilson on 12/29/12.
//
//

#import "FTDestination.h"
#import "FTSession.h"
#import "UIKitExtensions.h"

@interface FTDestination() {
    NSURL *_logoUrl;
}

@property NSString *name;
@property BOOL live;
@property NSURL *url;
@property NSString *logoName;
@property NSInteger destinationId;

@end

@implementation FTDestination


- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        self.destinationId = [dictionary[@"id"] integerValue];
        self.live = [dictionary[@"state"] isEqualToString:@"live"] ? YES : NO;
        self.name = dictionary[@"name"];
        self.url = [[NSURL alloc] initWithString:dictionary[@"url"]];
        self.logoName = dictionary[@"logo"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@ destinationId=%d", [super description], self.name, self.destinationId];
}

+ (FTDestination *)destinationWithId:(NSInteger)destinationId
{
    for (FTDestination *destination in [FTSession sharedSession].destinations) {
        if (destination.destinationId == destinationId)
            return destination;
    }
    return nil;
}

- (void)configureForImageView:(UIImageView *)imageView {
    NSURL *imageUrl = [NSURL URLWithString:self.logoName relativeToURL:[FTSession logosURL]];
    UIImage *image = [[self class] placeholderImage];
    [imageView setImageWithURL:imageUrl placeholderImage:image cached:YES];
}


- (void)configureForTextLabel:(UILabel *)textLabel withImageView:(UIImageView *)imageView
{
    textLabel.text = self.name;
    [self configureForImageView:imageView];
}

+ (UIImage *)placeholderImage {
    static UIImage *_placeholderImage;
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageNamed:@"glyphicons_144_folder_open"];
    }
    return _placeholderImage;
}

-(NSURL *)logoUrl {
    if (!_logoUrl)
        _logoUrl = [NSURL URLWithString:self.logoName relativeToURL:[FTSession logosURL]];
    return  _logoUrl;
}



/*
 
 op	destinationlist
 flex	true
 json	true
 compact	true
 ticket	T5P3wklJy3X8feeq6Jn4JGnqSfv
 
 {"destinations": 
 [{"id":2, "type":"locl","state":"live",
    "name":"FileThis DeskTop","provider":"this",
    "url":"http:\/\/filethis.com\/",
    "logoPath":"logos\/Logo_FileThisDesktop.png"},
 {"id":3,"type":"conn","state":"live",
    "name":"Evernote","provider":"ever",
    "url":"https:\/\/www.evernote.com\/Home.action",
    "logoPath":"logos\/Logo_Evernote.png"},
 {"id":4,"type":"conn","state":"live",
    "name":"Dropbox","provider":"drop",
    "url":"http:\/\/www.dropbox.com\/",
    "logoPath":"logos\/Logo_Dropbox.png"},
 {"id":6,"type":"conn","state":"live",
    "name":"Box","provider":"box ",
    "url":"http:\/\/box.com\/",
    "logoPath":"logos\/Logo_Box.png"},
 {"id":7,"type":"conn","state":"live",
    "name":"Fake","provider":"fake",
    "url":"http:\/\/filethis.com\/",
    "logoPath":"logos\/Logo_FakeBox.png"},
 {"id":8,"type":"conn","state":"live",
    "name":"Google Drive","provider":"gdrv",
    "url":"https:\/\/drive.google.com\/start#home",
    "logoPath":"logos\/Logo_GoogleDrive.png"},
 {"id":11,"type":"conn","state":"live",
    "name":"Personal","provider":"pers",
    "url":"https:\/\/personal.com",
    "logoPath":"logos\/Logo_Personal.png"}]}
 
 
 
 (lldb) po jsons
 $1 = 0x097cc4c0 <__NSCFArray 0x97cc4c0>(
 {
 id = 1;
 logo = "Logo_FileThisHosted.png";
 logoPath = "logos/Logo_FileThisHosted.png";
 name = "FileThis Cloud";
 ordinal = 0;
 provider = this;
 state = live;
 type = host;
 url = "http://filethis.com/";
 },
 {
 id = 2;
 logo = "Logo_FileThisDesktop.png";
 logoPath = "logos/Logo_FileThisDesktop.png";
 name = "FileThis DeskTop";
 ordinal = 7;
 provider = this;
 state = live;
 type = locl;
 url = "http://filethis.com/";
 },
 {
 id = 3;
 logo = "Logo_Evernote.png";
 logoPath = "logos/Logo_Evernote.png";
 name = Evernote;
 ordinal = 1;
 provider = ever;
 state = live;
 type = conn;
 url = "https://www.evernote.com/Home.action";
 },
 {
 id = 4;
 logo = "Logo_Dropbox.png";
 logoPath = "logos/Logo_Dropbox.png";
 name = Dropbox;
 ordinal = 3;
 provider = drop;
 state = live;
 type = conn;
 url = "http://www.dropbox.com/";
 },
 {
 id = 6;
 logo = "Logo_Box.png";
 logoPath = "logos/Logo_Box.png";
 name = Box;
 ordinal = 5;
 provider = "box ";
 state = live;
 type = conn;
 url = "http://box.com/";
 },
 {
 id = 7;
 logo = "Logo_FakeBox.png";
 logoPath = "logos/Logo_FakeBox.png";
 name = Fake;
 ordinal = 8;
 provider = fake;
 state = live;
 type = conn;
 url = "http://filethis.com/";
 },
 {
 id = 8;
 logo = "Logo_GoogleDrive.png";
 logoPath = "logos/Logo_GoogleDrive.png";
 name = "Google Drive";
 ordinal = 6;
 provider = gdrv;
 state = live;
 type = conn;
 url = "https://drive.google.com/start#home";
 },
 {
 id = 9;
 logo = "Logo_Personal.png";
 logoPath = "logos/Logo_Personal.png";
 name = Personal;
 ordinal = 4;
 provider = pers;
 state = live;
 type = conn;
 url = "http://personal.com";
 },
 {
 id = 10;
 logo = "Logo_EvernoteBusiness.png";
 logoPath = "logos/Logo_EvernoteBusiness.png";
 name = "Evernote Business";
 ordinal = 2;
 provider = enbz;
 state = live;
 type = conn;
 url = "http://evernote.com/business/";
 }
 )
 
 */

@end
