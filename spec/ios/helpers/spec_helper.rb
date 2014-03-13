module Bacon
  class << self
    @@old_run = instance_method(:run)
    @@already_started = false

    def ab_connect
      AddressBook::AddrBook.new do |ab|
        if ab
          EM.schedule_on_main do
            Bacon.run
          end
        else
          warn "ACCESS DENIED - ABORTING"
          exit
        end
      end
    end

    def run
      if AddressBook.authorized?
        @@old_run.bind(self).call
      else
        ab_connect
      end
    end
  end
end
