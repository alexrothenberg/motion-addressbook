module AddressBook
  module_function

  def address_book
    if UIDevice.currentDevice.systemVersion >= '6'
      ios6_create
    else
      ios5_create
    end
  end

  def ios6_create
    error = nil
    ABAddressBookCreateWithOptions(nil, error)
  end

  def ios5_create
    ABAddressBookCreate()
  end


  # TODO: what should we do when not authorized???
  # from https://developer.apple.com/library/ios/#documentation/AddressBook/Reference/ABAddressBookRef_iPhoneOS/Reference/reference.html#//apple_ref/doc/uid/TP40007099
  # On iOS 6.0 and later, if the caller does not have access to the Address Book database:
  #   For apps linked against iOS 6.0 and later, this function returns NULL.
  #   For apps linked against previous version of iOS, this function returns an empty read-only database.
  def authorized?
    !!address_book
  end
end
