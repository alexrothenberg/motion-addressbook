#import <AddressBook/AddressBook.h>

@interface ABHack : NSObject

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person;
+ (NSDate *) getDateValueAtIndex: (int) index from: (ABMutableMultiValueRef) ab_multi_value;

@end
