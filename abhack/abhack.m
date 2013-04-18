#import "abhack.h"

@implementation ABHack

+ (NSDate *) getDateProperty: (ABPropertyID) property from: (ABRecordRef) ab_person
{
  return (NSDate *)ABRecordCopyValue(ab_person, property);
}

+ (NSDate *) getMultiValueDateItem: (int) index from: (ABMultiValueRef) ab_multi_value
{
  return (NSDate *)ABMultiValueCopyValueAtIndex(ab_multi_value, index);
}

+ (ABPropertyType) getPropertyType: (ABPropertyID) property for: (ABRecordRef) ab_person
{
  ABMultiValueRef mv = (ABMultiValueRef)ABRecordCopyValue(ab_person, property);
  return ABMultiValueGetPropertyType(mv);
}

+ (NSDate *) getDateValueFor: (ABPropertyID) property fromPerson: (ABRecordRef) ab_person atIndex: (int) index
{
  // (ABMultiValueRef)
  // ABMultiValueRef mv1 = ABRecordCopyValue(ab_person, property);
  // NSLog(@"Orig mv is %@", mv1);
  return nil;

  // ABMultiValueRef mv = ABMultiValueCreateMutableCopy(mv1);
  // NSLog(@"Copy of mv is %@", mv);
  // CFIndex i = ABMultiValueGetCount(mv);
  // NSLog(@"Count is %lu for %@", i, mv);
  // return nil;

  // NSLog(@"mv is %@", mv);
  // // NSArray *theArray = [(id)ABMultiValueCopyArrayOfAllValues(mv) autorelease];
  // NSArray *theArray = (NSArray *)ABMultiValueCopyArrayOfAllValues(mv);
  // NSLog(@"theArray is %@", theArray);
  // NSDate * d = (NSDate *)theArray[index];
  // // NSDate * d = (NSDate *)ABMultiValueCopyValueAtIndex(mv, index);
  // return d;
}

+ (ABMultiValueRef) getMulti: (ABPropertyID) property from: (ABRecordRef) ab_person
{
  return (ABMultiValueRef)ABRecordCopyValue(ab_person, property);
}

+ (ABMultiValueRef) getFirstDateFromPerson: (ABRecordRef) ab_person
{
  ABMultiValueRef mv = [ABHack getMulti:kABPersonDateProperty from:ab_person];
  NSDate * d = (NSDate *)ABMultiValueCopyValueAtIndex(mv, 0);
  return d;
}

@end
