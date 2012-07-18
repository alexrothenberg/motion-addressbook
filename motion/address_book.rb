class AddressBook

  def self.list
    ABAddressBookCopyArrayOfAllPeople(book).map do |abrecord|
      {
        :first_name => ABRecordCopyValue(abrecord, KABPersonFirstNameProperty),
        :last_name => ABRecordCopyValue(abrecord, KABPersonLastNameProperty),
      }
    end
  end

  def self.book
    @book ||= ABAddressBookCreate()
  end
end