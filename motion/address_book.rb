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

  # Async way to request address book access
  # Adapted from http://stackoverflow.com/a/12533918/204044
  #
  #
  def request_access(&block)
    if UIDevice.currentDevice.systemVersion >= '6'
      error = nil
      @address_book ||= ABAddressBookCreateWithOptions(nil, error)
      @address_book_access_granted ||= nil

      access_callback = lambda { |granted, error|
        Dispatch::Queue.main.async do
          if (error)
            block.call( false, true )
          elsif(!granted)
            @address_book_access_granted = false
            block.call( false, false )
          else
            # access granted
            @address_book_access_granted = true
            block.call( true, false )
          end
        end
      }

      ABAddressBookRequestAccessWithCompletion @address_book, access_callback
    else
      error = nil
      @address_book ||= ABAddressBookCreate()
      block.call(true, false)
    end
  end

  def address_book
    @address_book
  end

  # TODO: what should we do when not authorized???
  # from https://developer.apple.com/library/ios/#documentation/AddressBook/Reference/ABAddressBookRef_iPhoneOS/Reference/reference.html#//apple_ref/doc/uid/TP40007099
  # On iOS 6.0 and later, if the caller does not have access to the Address Book database:
  #   For apps linked against iOS 6.0 and later, this function returns NULL.
  #   For apps linked against previous version of iOS, this function returns an empty read-only database.
  def authorized?
    @address_book_access_granted == true
  end

  def create_with_options_available?
    error = nil
    ABAddressBookCreateWithOptions(nil, error) rescue false
  end
end
