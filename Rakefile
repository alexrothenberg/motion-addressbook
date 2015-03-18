require "bundler/gem_tasks"
$:.unshift("/Library/RubyMotion/lib")

if ENV['osx']
  require 'motion/project/template/osx'
else
  require 'motion/project/template/ios'
end

Bundler.setup
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'AddressBook'

  if ENV['osx']
    app.specs_dir = "./spec/osx"
    app.info_plist['LSUIElement'] = true
  else
    app.specs_dir = "./spec/ios"
  end
end

# The test suite may interfere with contacts already created in the
# simulator.  In order to avoid disrupting anything the existing
# simulator environment, run the test suite in its own blank simulator
# and clean up afterwards.

namespace :spec do
  task :isolate do
    system "launchctl list | grep simulator | cut -f3 | xargs -L 1 launchctl remove"

    @_protected = []
    Dir.glob("#{ENV['HOME']}/Library/Application Support/iPhone Simulator/[0-9]*").each do |dir|
      if Dir.exists?("#{dir}.backup")
        warn "*" * 70
        warn "PREVIOUS TEST RUN FAILED. RESTORING SIMULATOR BACKUP AND ABORTING."
        warn "*" * 70
        system "rm -rf \"#{dir}\""
        File.rename("#{dir}.backup", dir)
        exit 1
      else
        warn "PROTECTING EXISTING SIMULATOR IN #{dir}"
        File.rename(dir, "#{dir}.backup")
        @_protected << dir
      end
    end

    at_exit do
      system "launchctl list | grep simulator | cut -f3 | head -1 | xargs launchctl remove"

      @_protected.each do |dir|
        warn "RESTORING SIMULATOR IN #{dir}"
        system "rm -rf \"#{dir}\""
        File.rename("#{dir}.backup", dir)
      end
    end
  end

  task :simulator => :isolate
end
