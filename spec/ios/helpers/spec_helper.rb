# These methods are intended to protect contents of the simulator
# instance from destruction when the spec suite runs. Specifically,
# the contents of the iOS Address Book, which is global to all
# applications.

SIMULATOR_ROOT = "#{ENV['HOME']}/../.."
AB_PATH = SIMULATOR_ROOT + "/Library/AddressBook"
AB_PATH_BAK = AB_PATH + ".bak"

def protect_existing_address_book
  # Can't use ruby methods to operate on these directories because the
  # iOS layer protects them, but shelling out is still allowed so we
  # can alter the world that way.

  warn "PROTECTING EXISTING ADDRESS BOOK IN SIMULATOR"

  `mv \"#{AB_PATH}\" "#{AB_PATH_BAK}"`
end

at_exit do
  warn "RESTORING ORIGINAL ADDRESS BOOK IN SIMULATOR"

  `rm -rf \"#{AB_PATH}\"`
  `mv \"#{AB_PATH_BAK}\" "#{AB_PATH}"`
end

protect_existing_address_book
