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

@interface SBLockScreenNotificationCell : UITableViewCell

@property(retain, nonatomic) UIImage *icon;
@property(readonly, assign, nonatomic) UIImageView *iconView;

@end

@interface SBAwayBulletinListItem : NSObject

@property(retain) BBBulletin *activeBulletin;

@end

@interface SBLockScreenNotificationListController : UIViewController

- (SBAwayBulletinListItem*)listItemAtIndexPath:(id)arg1;

@end

@interface SBLockScreenNotificationListView : UIView 

@end

#endif
