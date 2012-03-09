

特别注意：目前AsyncSocket只能支持 Apple LLVM Compiler 3.0，不能使用4.2 ！！！

一、如何引入Core

1）添加Core目录到工程中

2）添加如下系统依赖库

CFNetwork
QuartzCore
CoreLocation
CoreData
SystemConfiguration
AddressBook
MapKit
MessageUI
AVFoundation
libz.1.1.3.dylib
MobileCoreService

3）添加第三方依赖库

目前暂无



二、Common_iPhone20说明


Core

    内核，涵盖70％以上应用共享代码
    
    内核必须能够简单易用，直接简单引入开发
    
3PP

    来自外部第三方SDK，一般不依赖于Core
    
Components

    各种可重用的组件，Components可依赖于Core和3PP
    
Business

    业务相关的通用组件，用于不用业务和应用自己之间互相共享
    一般依赖于Core／3PP／Components（其中的一些组件）
    
Resource

    一些可重用的资源文件
    
    
    
    
    
    
    