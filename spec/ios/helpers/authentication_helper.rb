if defined?(UIATarget)
  # Refer to https://gist.github.com/Voxar/946de66777fc821a63cf5c1d6169504d
  # Automatically tap the default button on iOS system dialogs for authentication of access to Contacts
  target = UIATarget.localTarget
  target.setValue(true, forKey:"handlesAlerts")

  class UIATarget
    def _handleAlert
      target = UIATarget.localTarget
      app = target.frontMostApp
      alert = app.alert
      is_system_alert = app._isSystemApplication

      if is_system_alert
        button = alert.buttons.last
        if button
          button.tap
          return true
        end
      end
      return false
    end
  end

end