//
//  QQHeader.h
//  macSubstratePluginQQ
//
//  Created by GoKu on 19/10/2017.
//  Copyright © 2017 GoKuStudio. All rights reserved.
//

#ifndef QQHeader_h
#define QQHeader_h

#import <Foundation/Foundation.h>
#include <vector>

struct RecallItem {
    unsigned int _field1;
    unsigned int _field2;
    unsigned int _field3;
    unsigned int _field4;
    unsigned int _field5;
    unsigned int _field6;
};

struct RecallModel {
    void *_field1;  // 0x0
    int _field2;    // 0x4
    _Bool _field3;  // 0x8
    std::vector<RecallItem *> _field4;  // 0xA
    _Bool _field5;  // 0xE
    unsigned long long _field6;         // 0x10
    union {
        unsigned long long _field1;
        unsigned long long _field2;
    } _field7;      // 0x18
};

@interface RecallProcessor : NSObject
- (NSString *)getRecallMessageContent:(struct RecallModel *)arg1;
@end

@interface QQMessageRevokeEngine : NSObject
- (RecallProcessor *)getProcessor;
- (void)handleRecallNotify:(struct RecallModel *)arg1 isOnline:(BOOL)arg2;
@end

#endif /* QQHeader_h */
