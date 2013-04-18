#import "abhack.h"

@implementation ABHack

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person
{
  return (NSDate *)ABRecordCopyValue(ab_person, property);
}

+ (NSDate *) getDateValueAtIndex: (int) index from: (ABMultiValueRef) ab_multi_value
{
  return (NSDate *)ABMultiValueCopyValueAtIndex(ab_multi_value, index);
}

@end
