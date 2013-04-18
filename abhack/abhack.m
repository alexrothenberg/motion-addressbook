#import "abhack.h"

@implementation ABHack

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person
{
  return (NSDate *)ABRecordCopyValue(ab_person, property);
}

@end
