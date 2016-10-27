//
//  UIActionSheet+Block.h
//  Br_xd
//
//  Created by zhanggui on 16/7/28.
//  Copyright © 2016年 魏晓赟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock)(NSInteger buttonIndex);

@interface UIActionSheet (Block)<UIActionSheetDelegate>


/**
 *  actionSheet回调，这里的代理就是自己
 *
 *  @param view  要显示的view
 *  @param block block
 */
- (void)showActionSheetInView:(UIView *)view WithCompleteBlock:(CompleteBlock)block;
@end
