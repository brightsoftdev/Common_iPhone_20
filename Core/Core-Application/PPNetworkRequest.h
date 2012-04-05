//
//  PPNetworkRequest.h
//  groupbuy
//
//  Created by qqn_pipi on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NETWORK_TIMEOUT 20      // 30 seconds for time out

enum {
    
    ERROR_SUCCESS                   = 0,
    
	ERROR_NETWORK                   = 99901,
    
    ERROR_CLIENT_URL_NULL           = 190001,
    ERROR_CLIENT_REQUEST_NULL       = 190002,
    ERROR_CLIENT_PARSE_JSON         = 190003,

};

@interface CommonNetworkOutput : NSObject
{
	int             resultCode;
	NSString*       resultMessage;
    
    NSArray*        jsonDataArray;
    NSDictionary*   jsonDataDict;
    NSString*       textData;
    NSData*         responseData;
}

@property (nonatomic, assign) int			resultCode;
@property (nonatomic, retain) NSString*		resultMessage;
@property (nonatomic, retain) NSArray*        jsonDataArray;
@property (nonatomic, retain) NSDictionary*   jsonDataDict;

// for football project
@property (nonatomic, retain) NSString*       textData;
@property (nonatomic, retain) NSArray*        arrayData;

@property (nonatomic, retain) NSData*         responseData;

- (void)resultFromJSON:(NSString*)jsonString;
- (NSDictionary*)dictionaryDataFromJSON:(NSString*)jsonString;
- (NSArray*)arrayFromJSON:(NSString*)jsonString;

@end


typedef void (^ConstructHTTPRequestBlock)();
typedef NSString* (^ConstructURLBlock)(NSString* baseURL);
typedef void (^PPNetworkResponseBlock)(NSDictionary* dict, CommonNetworkOutput* output);

@interface PPNetworkRequest : NSObject {
    
}

+ (CommonNetworkOutput*)uploadRequest:(NSString *)baseURL 
                           uploadData:(NSData*)uploadData
                  constructURLHandler:(ConstructURLBlock)constructURLHandler 
                      responseHandler:(PPNetworkResponseBlock)responseHandler 
                               output:(CommonNetworkOutput *)output;

+ (CommonNetworkOutput*)sendRequest:(NSString*)baseURL
         constructURLHandler:(ConstructURLBlock)constructURLHandler
             responseHandler:(PPNetworkResponseBlock)responseHandler
                      output:(CommonNetworkOutput*)output;



@end

