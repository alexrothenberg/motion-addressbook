class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UIViewController.alloc.init
    @window.makeKeyAndVisible

    command_line

    true
  end

  def command_line
    if command = NSProcessInfo.processInfo.environment['dump']
      AddressBook::AddrBook.new do |ab|
        case command
        when 'people'
          ab.people.each do |person|
            puts BW::JSON.generate(person.attributes)
          end
        when 'groups'
          ab.groups.each do |group|
            puts BW::JSON.generate(group.attributes)
          end
        end
      end
    end
  end
end
