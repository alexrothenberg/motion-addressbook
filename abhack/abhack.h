#import <AddressBook/AddressBook.h>

@interface ABHack : NSObject

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person;

@end
