# see http://lists.apple.com/archives/xcode-users/2012/Apr/msg00064.html
# AddressBook constants are not defined until we call this function
ABAddressBookCreate()


puts [__FILE__, __LINE__, KABPersonFirstNameProperty].inspect
puts [__FILE__, __LINE__, KABPersonLastNameProperty].inspect
