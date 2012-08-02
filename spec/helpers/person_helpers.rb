def unique_email(email='alex@example.com')
  name, domain = email.split('@')
  "#{name}_#{Time.now.to_i}@#{domain}"
end
  