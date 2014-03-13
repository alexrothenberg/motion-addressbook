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
      warn "Executing command line instruction: #{command}"
      AddressBook::AddrBook.new do |ab|
        case command
        when 'people'
          puts BW::JSON.generate(ab.people.map(&:attributes))
        when 'groups'
          puts BW::JSON.generate(ab.groups.map { |g| {name: g.name, members: g.members.map(&:uid) }})
        end
      end
    end
  end
end
