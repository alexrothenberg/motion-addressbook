describe AddressBook do
  describe '.list' do
    it 'returns an Enumerable' do
      AddressBook.list.is_a?(Enumerable).should == true
    end

    # It's quite common for the simulator to
    # not have any address book entries.
    if AddressBook.list.any?
      describe '.first' do
        before do
          @person = AddressBook.list.first
        end

        it 'is a hash' do
          @person.is_a?(Hash).should == true
        end

        it 'has a first name' do
          should.not.raise(Exception) do
            @person.fetch(:first_name)
          end
        end

        it 'has a last name' do
          should.not.raise(Exception) do
            @person.fetch(:last_name)
          end
        end
      end

    end
  end
end