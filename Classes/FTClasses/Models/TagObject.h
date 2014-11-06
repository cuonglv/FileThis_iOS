//
//  TagObject.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "NameBaseObject.h"

/*
            {
                "id":197308,
                "name":"a",
                "type":"basc",
                "canedit":true,
                "candelete":true,
                "computed":false,
                "docCount":6,
                "created":1389774611,
                "modified":1389778697,
                "applied":1389778697,
                "searched":1389774611
            }
 */

@interface TagObject : NameBaseObject

@property (nonatomic, strong) NSNumber *docCount;
@property (assign) int relatedDocCount; //calculate on client app (additional temp info)

- (void)updateDocCount;

@end
