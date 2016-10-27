//
//  ZGRSAEncryptor.m
//  RSA
//
//  Created by zhanggui on 16/8/11.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import "ZGRSAEncryptor.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>

@interface ZGRSAEncryptor ()
{
    SecKeyRef publicKey;
    SecKeyRef privateKey;
}


@end

@implementation ZGRSAEncryptor

+ (instancetype)sharedInstance {
   static ZGRSAEncryptor *encryptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        encryptor = [[self alloc] init];
    });
    return encryptor;
}


#pragma mark - method
- (void)loadPublicKeyFromFile:(NSString *)filePath {
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    [self loadPublicKeyFromData:data];
}
- (void)loadPublicKeyFromData:(NSData *)data {
    publicKey = [self p_getPublicKeyRefrenceFromData:data];
}
- (void)loadPrivateKeyFromFile:(NSString *)p12FilePath andPassword:(NSString *)p12Password {
    NSData *p12Data = [NSData dataWithContentsOfFile:p12FilePath];
    [self loadPrivateKeyFromData:p12Data andPassword:p12Password];
}
- (void)loadPrivateKeyFromData:(NSData *)p12Data andPassword:(NSString *)p12Password {
    privateKey = [self p_getPrivateKeyRefrenceFromData:p12Data password:p12Password];
}
#pragma mark - Encrypt 加密
- (NSString *)rsaEncryptString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [self rsaEncriyptData:data];
    NSString *base64EncryptedString = [encryptedData base64EncodedStringWithOptions:0];
    return base64EncryptedString;
}
- (NSData *)rsaEncriyptData:(NSData *)data {
    SecKeyRef key = publicKey;
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    size_t blockSize = cipherBufferSize - 11;       // 分段加密
    size_t blockCount = (size_t)ceil([data length] / (double)blockSize);
    NSMutableData *encryptedData = [[NSMutableData alloc] init] ;
    for (int i=0; i<blockCount; i++) {
        int bufferSize = MIN(blockSize,[data length] - i * blockSize);
        NSData *buffer = [data subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1, (const uint8_t *)[buffer bytes], [buffer length], cipherBuffer, &cipherBufferSize);
        if (status == noErr){
            NSData *encryptedBytes = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
        }else{
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer){
        free(cipherBuffer);
    }
    return encryptedData;
}
#pragma mark - decrypt 解密


-(NSString*) rsaDecryptString:(NSString*)string {
    
    NSData* data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData* decryptData = [self rsaDecryptData: data];
    NSString* result = [[NSString alloc] initWithData: decryptData encoding:NSUTF8StringEncoding];
    return result;
}
- (NSData *)rsaDecryptData:(NSData *)data {
    SecKeyRef keyRef= privateKey;
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for(int idx=0; idx<srclen; idx+=src_block_size){
        size_t data_len = srclen - idx;
        if(data_len > src_block_size){
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef,
                               kSecPaddingNone,
                               srcbuf + idx,
                               data_len,
                               outbuf,
                               &outlen
                               );
        if (status != 0) {
            ret = nil;
            break;
        }else{
            //the actual decrypted data is in the middle, locate it!
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for ( int i = 0; i < outlen; i++ ) {
                if ( outbuf[i] == 0 ) {
                    if ( idxFirstZero < 0 ) {
                        idxFirstZero = i;
                    } else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}
#pragma mark - RSA verify
- (BOOL)rsaSHA1VerifyData:(NSData *)data wihtSignature:(NSData *)signature {
    size_t signedHashBytesSize = SecKeyGetBlockSize(publicKey);
    const void* signedHashBytes = [signature bytes];
    
    size_t hashBytesSize = CC_SHA1_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA1([data bytes], (CC_LONG)[data length], hashBytes)) {
        return NO;
    }
    
    OSStatus status = SecKeyRawVerify(publicKey,
                                      kSecPaddingPKCS1SHA1,
                                      hashBytes,
                                      hashBytesSize,
                                      signedHashBytes,
                                      signedHashBytesSize);
    
    return status == errSecSuccess;

}
#pragma mark - private method

- (SecKeyRef)p_getPrivateKeyRefrenceFromData:(NSData *)p12Data password:(NSString *)password {
    SecKeyRef privateKeyRef = NULL;
    NSMutableDictionary *optionsDic = [[NSMutableDictionary alloc] init];
    [optionsDic setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)p12Data, (__bridge CFDictionaryRef)optionsDic, &items);
    if (securityError == noErr && CFArrayGetCount(items)>0) {
        CFDictionaryRef identityDic = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDic, kSecImportItemIdentity);
        
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError !=noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    return privateKeyRef;
    
}

- (SecKeyRef)p_getPublicKeyRefrenceFromData:(NSData *)data {
    SecCertificateRef myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data);
    SecPolicyRef myPoliscy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(myCertificate, myPoliscy, &myTrust);
    SecTrustResultType trustResult;
    if (status==noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    SecKeyRef securityKey = SecTrustCopyPublicKey(myTrust);
  
    CFRelease(myCertificate);
    CFRelease(myPoliscy);
    CFRelease(myTrust);
    
    return securityKey;
}
- (void)dealloc {
    if (publicKey) {
        CFRelease(publicKey);
    }
    if (privateKey) {
        CFRelease(privateKey);
    }
}
@end
