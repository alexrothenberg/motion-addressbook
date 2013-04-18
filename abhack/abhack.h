#import <AddressBook/AddressBook.h>

@interface ABHack : NSObject

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person;
+ (NSDate *) getMultiValueDateItem: (int) index from: (ABMutableMultiValueRef) ab_multi_value;
+ (ABPropertyType) getPropertyType: (ABPropertyID) property for: (ABRecordRef) ab_person;

// + (NSDate *) getDateValueFor: (ABPropertyID) property at: (int) index from: (ABRecordRef) ab_person;
+ (NSDate *) getDateValueFor: (ABPropertyID) property fromPerson: (ABRecordRef) ab_person atIndex: (int) index ;

+ (ABMultiValueRef) getMulti: (ABPropertyID) property from: (ABRecordRef) ab_person;
+ (ABMultiValueRef) getFirstDateFromPerson: (ABRecordRef) ab_person;

@end
