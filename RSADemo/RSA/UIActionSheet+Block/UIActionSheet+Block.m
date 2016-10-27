//
//  UIActionSheet+Block.m
//  Br_xd
//
//  Created by zhanggui on 16/7/28.
//  Copyright © 2016年 魏晓赟. All rights reserved.
//

#import "UIActionSheet+Block.h"
#import <objc/runtime.h>

static char key;
@implementation UIActionSheet (Block)





- (void)showActionSheetInView:(UIView *)view WithCompleteBlock:(CompleteBlock)block {
    if (block) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        self.delegate = self;
    }
    [self showInView:view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    CompleteBlock block = objc_getAssociatedObject(self, &key);
    if (block) {
        block(buttonIndex);
    }
}
@end
