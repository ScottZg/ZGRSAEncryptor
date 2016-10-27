//
//  ViewController.m
//  RSA
//
//  Created by zhanggui on 16/8/11.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import "ViewController.h"
#import "ZGRSAEncryptor.h"
#import "UIActionSheet+Block.h"
@interface ViewController ()

@property (nonatomic,strong)ZGRSAEncryptor *rsa;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextView *encrypteMessageTextView;
@property (weak, nonatomic) IBOutlet UITextView *decrypteMessageTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    _rsa = [ZGRSAEncryptor sharedInstance];
//     NSString *securityText = @"这里内容很重要，不要告诉其他人";
//    NSString *encryptedString = [self encrypteStringWithString:securityText];
//    
//    NSLog(@"加密后的文字\n%@",encryptedString);
//    
//    NSString *message = [self decryptStringWithString:encryptedString];
//    
//    NSLog(@"解密后的文字\n%@",message);
    
}
- (IBAction)chooseEncytorMethodAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"加密方式" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"RSA加密", nil];
    [actionSheet showActionSheetInView:self.view WithCompleteBlock:^(NSInteger buttonIndex) {
        NSLog(@"%ld",buttonIndex);
    }];
}
#pragma mark - button method
//加密
- (IBAction)encrypteMessageAction:(id)sender {
    if (self.messageTextView.text && self.messageTextView.text.length>0) {
        self.encrypteMessageTextView.text = [self encrypteStringWithString:self.messageTextView.text];
    }else {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请输入要加密的内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [aler show];
    }
    
}
- (IBAction)decrypteMessageAction:(id)sender {
    self.decrypteMessageTextView.text = [self decryptStringWithString:self.encrypteMessageTextView.text];
}
#pragma mark - init ui
- (void)initUI {
    NSArray *arr = @[self.messageTextView,self.encrypteMessageTextView,self.decrypteMessageTextView];
    for (UITextView *view in arr) {
        view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        view.layer.borderWidth = 1;
    }
}
#pragma mark - <#name#>
- (NSString *)decryptStringWithString:(NSString *)str {
    [_rsa loadPrivateKeyFromFile:[[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"p12"] andPassword:@"19920925"];
    return  [_rsa rsaDecryptString:str];
}
- (NSString *)encrypteStringWithString:(NSString *)str {
  
    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der" ];
    [_rsa loadPublicKeyFromFile:publicKeyPath];
    
   
    NSString *encryptedString = [_rsa rsaEncryptString:str];
    
    return encryptedString;

}
#pragma mark - 
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}










@end
