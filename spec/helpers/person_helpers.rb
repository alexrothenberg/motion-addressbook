def unique_email(email='alex_testy@example.com')
  name, domain = email.split('@')
  "#{name}_#{Time.now.to_i}_#{rand(1000)}@#{domain}"
end
