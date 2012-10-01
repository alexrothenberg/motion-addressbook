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
    address_book = ABAddressBookCreateWithOptions(nil, error)
    request_authorization unless authorized?
    address_book
  end

  def ios5_create
    ABAddressBookCreate()
  end

  def request_authorization(&block)
    synchronous = !!block
    access_callback = lambda { |granted, error|
      # not sure what to do with error ... so we're ignoring it
      @address_book_access_granted = granted
      block.call(@address_book_access_granted) unless block.nil?
    }

    ABAddressBookRequestAccessWithCompletion address_book, access_callback
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
    return :authorized unless UIDevice.currentDevice.systemVersion >= '6'

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
