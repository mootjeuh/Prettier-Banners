//
//  interfaces.h
//  
//
//  Created by Mohamed Marbouh on 2014-12-02.
//
//

#ifndef _interfaces_h
#define _interfaces_h

@interface BBBulletin : NSObject

@property(retain, nonatomic) NSDictionary *context;

@end

@interface SBBulletinBannerItem : NSObject

- (BBBulletin*)seedBulletin;

@end

#endif
