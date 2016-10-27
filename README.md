### ZGRSAEncryptor

#####前言
* RSA，非对称密码加密算法，需要一对密钥，使用其中一个加密，使用另一个解密。在进行RSA加密通讯时，把公钥放到客户端，把私钥留到服务器。（这里面我直接将公钥和私钥都放到了客户端，便于客户端完成加密和解密功能。）     
* openssl是一个密钥生成工具，用来生成RSA需要的一对密钥
* DER和PEM是生成密钥可选择的两种文件格式，iOS客户端使用DER

#####正文
这里是在对RSA加密和解密。如果你想去跑这个程序，你首先需要用openssl来手动生成自己的公钥和私钥。脚本如下：

 
	#生成私钥
	openssl genrsa -out private_key.pem 1024  
	  
	#生成csr
	openssl req -new -key private_key.pem -out rsaCertReq.csr  
	  
	#导出crt
	openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey private_key.pem -out rsaCert.crt  
	  
	#转换成der，因为iOS识别的是der
	openssl x509 -outform der -in rsaCert.crt -out public_key.der  
	  
	#生成p12
	openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt  
	  
	#生成公钥
	openssl rsa -in private_key.pem -out rsa_public_key.pem -pubout  

	#导出pkcs8私钥，供Java使用
	openssl pkcs8 -topk8 -in private_key.pem -out pkcs8_private_key.pem -nocrypt  
	  

导出一些列文件之后，便可以进行加密解密处理了(我工程Demo里面使用的是我自己生成的密钥)。这里主要使用了ZGRSAEncryptor类。    

此外，代码中还有一份Java代码，可以跑到服务器端，这里面可以用来测试iOS客户端加密后的数据然后在Java后台解密消息是否一致。

#####演示
![RSA加密解密](https://ooo.0o0.ooo/2016/08/11/57ac40cabbfd9.gif)

例如将：    

	我的邮箱是scottzg@126.com 
进行加密。在iOS客户端加密结果如下：

	B6HtZCkPyeRdeAswu7h7P/iHqdKgpNMow0vVgsKKk32XKJlesmZ31LZkt2Gd7PoOrsWdBOBhp2D3CbBwAp6PCfQ4GeUW9jtUeijxDuSj1iUGT587FbNEXgVq2ZK68wpieuH1mDzQo0w45Cx8KEl9xyhapcaUCLcPKbS6IaE4rxw=

点击解密即可在iOS客户端进行解密。      
解密然后运行java代码解密结果如下：    

![Java解密结果](https://ooo.0o0.ooo/2016/08/11/57ac41f3ce054.png)   

完成解密！


#####使用
<b>iOS客户端</b>     
加密：

	- (NSString *)encrypteStringWithString:(NSString *)str {
	  
	    NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:@"public_key" ofType:@"der" ];
	    [_rsa loadPublicKeyFromFile:publicKeyPath];
	    
	   	   
	    NSString *encryptedString = [_rsa rsaEncryptString:str];
	    
	    return encryptedString;

	}

解密：

	- (NSString *)decryptStringWithString:(NSString *)str {
	    [_rsa loadPrivateKeyFromFile:[[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"p12"] andPassword:@"19920925"];
	    return  [_rsa rsaDecryptString:str];
	}
	
<b>Java后台</b>
解密：

		ZGEncryptor rsa = new ZGEncryptor();
		PrivateKey privateKey = rsa.readPrivateKey();
			
		String message = "B6HtZCkPyeRdeAswu7h7P/iHqdKgpNMow0vVgsKKk32XKJlesmZ31LZkt2Gd7PoOrsWdBOBhp2D3CbBwAp6PCfQ4GeUW9jtUeijxDuSj1iUGT587FbNEXgVq2ZK68wpieuH1mDzQo0w45Cx8KEl9xyhapcaUCLcPKbS6IaE4rxw=";
		
		byte[] data = rsa.encrypte(message);
			
		String text = rsa.decrypte(privateKey, data);
		System.out.println(text);

这里面只是简单的介绍，详情可以参见代码。