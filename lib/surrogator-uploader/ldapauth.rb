require 'net/ldap'

#LDAP認証モジュール
module LdapAuth
  @@host
  @@port
  @@bae

  #ユーザークラス
  class LdapUser
    attr_reader :username, :mail, :group

    def initialize(username, mail, :group)
      @username = username
      @mail = mail
      @group = group
    end
  end

  def self.initialize(host, port, base)
    @host = host
    @port = port
    @base = base
  end

  def self.authenticate(username, password)
    conn = Net::LDAP.new :host => @@host, :port => @@port, :base => @@base,
      :auth => { :username => "#{username}",
                 :password => password, :method => :simple }

    group = Hash.new
    mail = ''
    if conn.bind
      conn.open do |ldap|
        filter = Net::LDAP::Filter.eq("cn", username)
        ldap.search(:filter => filter, :return_result => false ) do |entry|
          entry.each do |attr_name, values|
            group[attr_name] = values
          end
          #TODO get mail
        end
      end
    end

    return LdapUser.new(username, mail, group)
  end
end
