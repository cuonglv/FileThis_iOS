//
//  BaseDataManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "BaseDataManager.h"
#import "ThreadManager.h"

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@implementation BaseDataManager

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (NSMutableArray *)parseDataToObjects:(id)dict {
    return nil;
}

- (BOOL)hasData {
    if (self.allObjects)
        return YES;
    return NO;
}

- (NSArray*)getAllObjects {
    @synchronized(self) {
        if (!self.allObjects)
            return nil;
        return [NSArray arrayWithArray:self.allObjects];
    }
}

- (NSUInteger)countObjects {
    return self.allObjects.count;
}

- (void)clearAll {
    @synchronized(self) {
        self.allObjects = nil;
        self.findObjectByIdDictionary = nil;
    }
}

- (void)reloadAll {
}

- (void)addObject:(id)object {
    @synchronized(self) {
        [self.allObjects addObject:object];
    }
}

- (void)removeObject:(id)object {
    @synchronized(self) {
        [self.allObjects removeObject:object];
    }
}

- (id)getObjectByKey:(id)key {
    @synchronized(self) {
        return [self.findObjectByIdDictionary objectForKey:key];
    }
}

- (void)updateFindObjectByIdDictionary {
    @synchronized(self) {
        self.findObjectByIdDictionary = [[NSMutableDictionary alloc] init];
        for (BaseObject *obj in self.allObjects) {
            [self.findObjectByIdDictionary setObject:obj forKey:obj.id];
        }
    }
}

@end
