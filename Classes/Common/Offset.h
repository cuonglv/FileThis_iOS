//
//  Offset.h
//  TKD
//
//  Created by decuoi on 6/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>


struct Offset {
    float left, right, top, bottom;
};
typedef struct Offset Offset;

CG_INLINE Offset OffsetMake(float left, float right, float top, float bottom) {
    Offset offset;
    offset.left = left;
    offset.right = right;
    offset.top = top;
    offset.bottom = bottom;
    return offset;
}


CG_INLINE Offset OffsetZero() {
    Offset offset;
    offset.left = 0;
    offset.right = 0;
    offset.top = 0;
    offset.bottom = 0;
    return offset;
}