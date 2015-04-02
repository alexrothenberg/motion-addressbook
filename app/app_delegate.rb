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
          people = ab.people.map(&:attributes)
          puts NSJSONSerialization.dataWithJSONObject(people, options:0, error:nil).to_str
        when 'groups'
          groups = ab.groups.map { |g| {name: g.name, members: g.members.map(&:uid) }}
          puts NSJSONSerialization.dataWithJSONObject(groups, options:0, error:nil).to_str
        end
      end
    end
  end
end
