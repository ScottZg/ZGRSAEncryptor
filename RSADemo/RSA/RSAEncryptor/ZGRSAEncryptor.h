//
//  ZGRSAEncryptor.h
//  RSA
//
//  Created by zhanggui on 16/8/11.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGRSAEncryptor : NSObject
/**
 *  从文件中加载公钥文件
 *
 *  @param filePath 文件所在的路径
 */
- (void)loadPublicKeyFromFile:(NSString *)filePath;
/**
 *  从dataz中加载公钥
 *
 *  @param data data
 */
- (void)loadPublicKeyFromData:(NSData *)data;

/**
 *  从文件中加载私钥
 *
 *  @param p12FilePath p12文件的路径
 *  @param p12Password p12文件的密码
 */
- (void)loadPrivateKeyFromFile:(NSString *)p12FilePath andPassword:(NSString *)p12Password;
/**
 *  从data中加载私钥
 *
 *  @param p12Data     p12Data
 *  @param p12Password p12密码
 */
- (void)loadPrivateKeyFromData:(NSData *)p12Data andPassword:(NSString *)p12Password;
/**
 *  rsa加密
 *
 *  @param string 要加密的字符串
 *
 *  @return 加密后的字符串
 */
- (NSString *)rsaEncryptString:(NSString *)string;
/**
 *  rsa加密
 *
 *  @param data 要加密的data
 *
 *  @return 加密后的data
 */
- (NSData *)rsaEncriyptData:(NSData *)data;

/**
 *  rsa解密
 *
 *  @param strig 加密的字符串
 *
 *  @return 解密后的message
 */
- (NSString *)rsaDecryptString:(NSString *)strig;
/**
 *  rsa解密
 *
 *  @param data 加密的data
 *
 *  @return 解密后的data
 */
- (NSData *)rsaDecryptData:(NSData *)data;
/**
 *  验证一个数字签名是否合法
 *
 *  @param data      data
 *  @param signature 签名
 *
 *  @return YES表示验证合法，NO表示不合法
 */
- (BOOL)rsaSHA1VerifyData:(NSData *)data wihtSignature:(NSData *)signature;



/**
 *  单例构造
 *
 *  @return 返回一个实例
 */

+ (instancetype)sharedInstance;






























@end
