#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AddressBook/AddressBook.h>
#import "interfaces.h"
#import "substrate.h"

static NSArray *getABPersons()
{
	CFErrorRef error;
	NSArray *persons = nil;
	
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
	if(!addressBook) {
		NSLog(@"AddressBook creation error: %@\nContact mootjeuh@outlook.com with a copy of this log.", error);
	} else {
		persons = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
	}
	
	return persons;
}

static UIImage *getABPersonImage(ABRecordRef person)
{
	return ABPersonHasImageData(person) ? [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize)] : nil;
}

static ABRecordRef getPersonFromBulletin(BBBulletin *bulletin)
{
	ABRecordRef person = nil;
	
	for(id entry in getABPersons()) {
		if(ABRecordGetRecordID((__bridge ABRecordRef)entry) == MSHookIvar<int>(bulletin, "_addressBookRecordID")) {
			person = (__bridge ABRecordRef)entry;
			break;
		}
	}
	
	return person;
}

%hook SBBulletinBannerItem

- (UIImage*)iconImage
{
	UIImage *image = %orig;
	ABRecordRef person = getPersonFromBulletin([self seedBulletin]);
	if(person) {
		UIImage *personImage = getABPersonImage(person);
		if (personImage) {
			CGRect iconImageRect = (CGRect){CGPointZero, image.size};
			
			UIGraphicsBeginImageContextWithOptions(iconImageRect.size, NO, [UIScreen mainScreen].scale);
			CGContextRef context = UIGraphicsGetCurrentContext();

			CGContextSaveGState(context);
			CGContextAddEllipseInRect(context, iconImageRect);
			CGContextClip(context);
			CGContextClearRect(context, iconImageRect);
			[personImage drawInRect:iconImageRect];

			UIImage *circularScaledImage = UIGraphicsGetImageFromCurrentImageContext(); 
			UIGraphicsEndImageContext();
			
			return circularScaledImage;
		}
	}

	return image;
}

- (NSString*)title
{
	NSMutableArray *names = nil;
	NSString *title = %orig;
	NSDictionary *assistantContext = [NSDictionary dictionaryWithDictionary:[self seedBulletin].context[@"AssistantContext"]];
	
	if([[assistantContext allKeys] containsObject:@"msgRecipients"]) {
		NSArray *msgRecipients = [NSArray arrayWithArray:assistantContext[@"msgRecipients"]];
		names = [NSMutableArray array];
		for(NSDictionary *entry in msgRecipients) {
			NSDictionary *object = [NSDictionary dictionaryWithDictionary:entry[@"object"]];
            if([[object allKeys] containsObject:@"firstName"]) {
				[names addObject:object[@"firstName"]];
			} else {
				[names addObject:entry[@"data"]];
			}
		}
	}
	
	if(names) {
		title = [names firstObject];
		for(int i = 1; i < [names count]; i++) {
			title = [NSString stringWithFormat:@"%@, %@", title, names[i]];
		}
	}
	
	return title;
}

%end

%hook SBLockScreenNotificationListView

- (SBLockScreenNotificationCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SBLockScreenNotificationCell *cell = %orig;
    id item = [(SBLockScreenNotificationListController*)self.nextResponder listItemAtIndexPath:indexPath];
    if([NSStringFromClass([item class]) isEqualToString:@"SBAwayBulletinListItem"]) {
        BBBulletin *bulletin = [item activeBulletin];
		ABRecordRef person = getPersonFromBulletin(bulletin);
		if(person) {
            UIImage *icon = getABPersonImage(person);
            if(icon) {
                cell.icon = icon;
            }
		}
    }
    return cell;
}

%end