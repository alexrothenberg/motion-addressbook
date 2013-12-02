# These methods are intended to protect contents of the simulator
# instance from destruction when the spec suite runs. Specifically,
# the contents of the iOS Address Book, which is global to all
# applications.
#
# WARNING: Altering the simulator configuration at runtime is a risky
# practice. If we use `Kernel.system` instead of backquotes when
# invoking `mv` and `rm` below, the simulator throws a warning:
#
#    The iOS Simulator libSystem was initialized out of order.  This
#    is most often caused by running host executables or inserting
#    host dylibs.  In the future, this will cause an abort.
#

SIMULATOR_ROOT = "#{ENV['HOME']}/../.."
AB_PATH = SIMULATOR_ROOT + "/Library/AddressBook"
AB_PATH_BAK = AB_PATH + ".bak"

def protect_existing_address_book
  # Can't use ruby methods to operate on these directories because the
  # iOS layer protects them, but shelling out is still allowed so we
  # can alter the world that way.

  warn "PROTECTING EXISTING ADDRESS BOOK IN SIMULATOR"

  `rm -rf \"#{AB_PATH_BAK}\"`
  `mv \"#{AB_PATH}\" \"#{AB_PATH_BAK}\"`
  # Kernel.system "rm -rf \"#{AB_PATH_BAK}\""
  # Kernel.system "mv \"#{AB_PATH}\" \"#{AB_PATH_BAK}\""
end

at_exit do
  warn "RESTORING ORIGINAL ADDRESS BOOK IN SIMULATOR"

  Kernel.system "rm -rf \"#{AB_PATH}\""
  Kernel.system "mv \"#{AB_PATH_BAK}\" \"#{AB_PATH}\""
end

def wait_for_authorization
  @semaphore = Dispatch::Semaphore.new(0)
  AddressBook::AddrBook.new do
    @semaphore.signal
  end
  @semaphore.wait
end

protect_existing_address_book
wait_for_authorization
