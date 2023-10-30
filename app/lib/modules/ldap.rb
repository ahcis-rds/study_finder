require 'net/ldap'

module Modules
  class Ldap

    ###################
    # 1. Authenicate with our departmental LDAP account
    # 2. If successful, look up the user by username in LDAP
    # 3. If found, authenticate with their LDAP username string and the password they entered into our login form
    # 4. If successful, check if the user exists in Study Finder
    # 5. If not found, create them
    # 6. If found, log them into the Study Finder
    ###################

    def authenticate(username, password)
      # initialize our return hash with some defaults
      _return = Hash.new
      _return[:ldap_user] = nil
      _return[:success] = false
      _return[:message] = ''

      # authenticate with our departmental account
      departmental_ldap = Net::LDAP.new(
        host: ENV['host'],
        encryption: ENV['encryption'].to_sym,
        port: ENV['port'],
        auth: {
          method: :simple,
          username: "cn=#{ENV['departmental_cn']},ou=Organizations,#{ENV['base']}",
          password: ENV['departmental_pw']
        }
      )

      # departmental authentication successful
      if departmental_ldap.bind

        # now search for the user logging in
        filter = Net::LDAP::Filter.eq( "uid", username ) # is this correct?
        user_search = departmental_ldap.search( base: ENV['base'], filter: filter ).first

        # departmental_ldap.search( :base => ENV['base'], :filter => filter ) do |entry|
        #   # puts "DN: #{entry.dn}"
        #   entry.each do |attribute, values|
        #     puts " #{attribute}:"
        #     puts "   #{values}"
        #     # values.each do |value|
        #       # puts "      --->#{value}"
        #     # end
        #   end
        # end

        unless user_search.nil?
          # now that we have everything ldap requires, perform user authentication
          ldap_user = Net::LDAP.new(
            host: ENV['host'],
            encryption: ENV['encryption'].to_sym,
            port: ENV['port'],
            auth: {
              method: :simple,
              username: "cn=#{user_search.cn.first.to_s},ou=People,#{ENV['base']}",
              password: password.to_s
            }
          )

          # user LDAP authenticate successful
          if ldap_user.bind
            _return[:success] = true
            _return[:ldap_user] = user_search
          else
            _return[:ldap_user] = user_search
            _return[:message] = 'User authentication with LDAP failed.'
          end
        else
          _return[:message] = 'User not found in LDAP.'
        end
      # departmental authentication failed
      else
        _return[:message] = 'Departmental authentication with LDAP failed.'
      end
      _return
    end
  end
end