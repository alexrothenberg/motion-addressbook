module AddressBook
  module_function

  def address_book
    if Kernel.const_defined?(:NSApplication)
      ABAddressBook.addressBook
    else # iOS
      version = UIDevice.currentDevice.systemVersion.to_f
      if version < 6.0
        ios5_create
      else
        ios6_create
      end
    end
  end

  def instance
    @instance ||= AddrBook.new
  end

  def count
    if Kernel.const_defined?(:UIApplication)
      # ABAddressBookGetPersonCount(address_book)
      instance.count
    else
      address_book.count
    end
  end

  def ios6_create
    error = nil
    if authorized?
      @address_book = ABAddressBookCreateWithOptions(nil, error)
    else
      request_authorization do |rc|
        NSLog "AddressBook: access was #{rc ? 'approved' : 'denied'}"
      end
    end
    @address_book
  end

  def ios5_create
    @address_book = ABAddressBookCreate()
  end

  def request_authorization(&block)
    synchronous = !block
    access_callback = lambda { |granted, error|
      # not sure what to do with error ... so we're ignoring it
      @address_book_access_granted = granted
      block.call(@address_book_access_granted) unless block.nil?
    }

    ABAddressBookRequestAccessWithCompletion @address_book, access_callback
    if synchronous
      # Wait on the asynchronous callback before returning.
      while @address_book_access_granted.nil? do
        sleep 0.1
      end
    end
    @address_book_access_granted
  end

  def authorized?
    authorization_status == :authorized
  end

  def authorization_status
    version = UIDevice.currentDevice.systemVersion.to_f
    return :authorized unless version >= 6.0

    status_map = { KABAuthorizationStatusNotDetermined => :not_determined,
                   KABAuthorizationStatusRestricted    => :restricted,
                   KABAuthorizationStatusDenied        => :denied,
                   KABAuthorizationStatusAuthorized    => :authorized
                 }
    status_map[ABAddressBookGetAuthorizationStatus()]
  end

  def create_with_options_available?
    error = nil
    ABAddressBookCreateWithOptions(nil, error) rescue false
  end
end
